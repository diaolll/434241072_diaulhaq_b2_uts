-- ============================================
-- PROPER RLS FIX - Doesn't block login
-- Run this AFTER you can login successfully
-- ============================================

-- Step 1: Create helper functions with SECURITY DEFINER (bypass RLS)

-- Function to check if current user is admin
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM users
    WHERE id = auth.uid() AND role = 'admin'
  );
END;
$$;

-- Function to check if current user is admin or helpdesk
CREATE OR REPLACE FUNCTION public.is_admin_or_helpdesk()
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM users
    WHERE id = auth.uid() AND role IN ('admin', 'helpdesk')
  );
END;
$$;

-- Function to get current user's role (bypasses RLS)
CREATE OR REPLACE FUNCTION public.get_my_role()
RETURNS text
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN (
    SELECT role FROM users
    WHERE id = auth.uid()
  );
END;
$$;

-- Grant execute to authenticated users
GRANT EXECUTE ON FUNCTION public.is_admin() TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_admin_or_helpdesk() TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_my_role() TO authenticated;

-- Step 2: Create the upsert function for user creation (already exists, but let's make sure)
CREATE OR REPLACE FUNCTION public.upsert_user(
  p_id uuid,
  p_email text,
  p_name text,
  p_role text DEFAULT 'user'
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
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

GRANT EXECUTE ON FUNCTION public.upsert_user TO authenticated;

-- Step 3: Enable RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Step 4: Create RLS policies that work with the helper functions

-- Drop all existing policies first
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

-- Create new policies using helper functions

-- Policy: Users can view their own profile
CREATE POLICY "Users can view own profile"
  ON users FOR SELECT
  USING (auth.uid() = id);

-- Policy: Users can update their own profile
CREATE POLICY "Users can update own profile"
  ON users FOR UPDATE
  USING (auth.uid() = id);

-- Policy: Admin can view all users
CREATE POLICY "Admin can view all users"
  ON users FOR SELECT
  USING (public.is_admin());

-- Policy: Admin can insert new users
CREATE POLICY "Admin can insert users"
  ON users FOR INSERT
  WITH CHECK (public.is_admin());

-- Policy: Admin can update any user
CREATE POLICY "Admin can update any user"
  ON users FOR UPDATE
  USING (public.is_admin());

-- Policy: Admin can delete users (not themselves)
CREATE POLICY "Admin can delete users"
  ON users FOR DELETE
  USING (public.is_admin() AND id <> auth.uid());

-- Step 5: Verify everything works
SELECT '=== Policies created ===' as info;
SELECT policyname FROM pg_policies WHERE tablename = 'users';

SELECT '=== Test query ===' as info;
SELECT COUNT(*) FROM users;

SELECT '=== All users ===' as info;
SELECT id, email, name, role FROM users ORDER BY created_at;
