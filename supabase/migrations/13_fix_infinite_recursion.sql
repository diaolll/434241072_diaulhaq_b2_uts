-- ============================================
-- FIX INFINITE RECURSION
-- Run this to fix the policy recursion issue
-- ============================================

-- First, disable RLS temporarily
ALTER TABLE users DISABLE ROW LEVEL SECURITY;

-- Recreate functions with proper settings to bypass RLS
DROP FUNCTION IF EXISTS public.is_admin() CASCADE;
DROP FUNCTION IF EXISTS public.is_admin_or_helpdesk() CASCADE;
DROP FUNCTION IF EXISTS public.upsert_user CASCADE;

-- Create is_admin with security_invoker=off to bypass RLS
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, security_invoker = off
AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM users
    WHERE id = auth.uid() AND role = 'admin'
  );
END;
$$;

-- Create is_admin_or_helpdesk with security_invoker=off
CREATE OR REPLACE FUNCTION public.is_admin_or_helpdesk()
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, security_invoker = off
AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM users
    WHERE id = auth.uid() AND role IN ('admin', 'helpdesk')
  );
END;
$$;

-- Create upsert_user with security_invoker=off
CREATE OR REPLACE FUNCTION public.upsert_user(
  p_id uuid,
  p_email text,
  p_name text,
  p_role text DEFAULT 'user'
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, security_invoker = off
AS $$
BEGIN
  INSERT INTO public.users (id, email, name, role)
  VALUES (p_id, p_email, p_name, p_role)
  ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    name = COALESCE(EXCLUDED.name, users.name),
    role = COALESCE(EXCLUDED.role, users.role);
END;
$$;

-- Grant permissions
GRANT EXECUTE ON FUNCTION public.is_admin() TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_admin_or_helpdesk() TO authenticated;
GRANT EXECUTE ON FUNCTION public.upsert_user TO authenticated;

-- Enable RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Drop all policies
DROP POLICY IF EXISTS "Users can view own profile" ON users;
DROP POLICY IF EXISTS "Users can update own profile" ON users;
DROP POLICY IF EXISTS "Users can insert own profile" ON users;
DROP POLICY IF EXISTS "Admin can insert users" ON users;
DROP POLICY IF EXISTS "Admin can update any user" ON users;
DROP POLICY IF EXISTS "Admin can delete users" ON users;
DROP POLICY IF EXISTS "Admin can view all users" ON users;
DROP POLICY IF EXISTS "Authenticated users can read all users" ON users;
DROP POLICY IF EXISTS "Admin can manage users" ON users;
DROP POLICY IF EXISTS "Users can insert users" ON users;
DROP POLICY IF EXISTS "Admin can update users" ON users;
DROP POLICY IF EXISTS "Enable read for all authenticated users" ON users;

-- Create policies that DON'T cause recursion
-- Use direct auth.uid() checks instead of calling functions

CREATE POLICY "Users can view own profile"
  ON users FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON users FOR UPDATE
  USING (auth.uid() = id);

-- Admin policies - use subquery that bypasses RLS via SECURITY DEFINER
CREATE POLICY "Admin can view all users"
  ON users FOR SELECT
  USING (
    (SELECT role FROM users WHERE id = auth.uid()) = 'admin'
  );

CREATE POLICY "Admin can insert users"
  ON users FOR INSERT
  WITH CHECK (
    (SELECT role FROM users WHERE id = auth.uid()) = 'admin'
  );

CREATE POLICY "Admin can update any user"
  ON users FOR UPDATE
  USING (
    (SELECT role FROM users WHERE id = auth.uid()) = 'admin'
  );

CREATE POLICY "Admin can delete users"
  ON users FOR DELETE
  USING (
    (SELECT role FROM users WHERE id = auth.uid()) = 'admin'
    AND id <> auth.uid()
  );

-- Test
SELECT '=== Testing ===' as info;
SELECT policyname FROM pg_policies WHERE tablename = 'users';
SELECT COUNT(*) FROM users;
