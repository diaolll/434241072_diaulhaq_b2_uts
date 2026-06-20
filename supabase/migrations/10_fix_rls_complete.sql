-- ============================================
-- COMPLETE RLS FIX for Users Table
-- Run this in Supabase Dashboard SQL Editor
-- ============================================

-- First, let's verify the admin user
SELECT '=== Current admin user ===' as info;
SELECT id, email, name, role FROM users WHERE email = 'admin@gmail.com';

-- Drop ALL existing policies on users table
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

-- Make sure RLS is enabled
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Create policies from scratch with proper logic

-- Policy 1: Users can view their own profile
CREATE POLICY "Users can view own profile"
  ON users FOR SELECT
  USING (auth.uid() = id);

-- Policy 2: Users can update their own profile
CREATE POLICY "Users can update own profile"
  ON users FOR UPDATE
  USING (auth.uid() = id);

-- Policy 3: Admin can view all users
-- Uses a helper function to check admin role
CREATE POLICY "Admin can view all users"
  ON users FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- Policy 4: Admin can insert new users
CREATE POLICY "Admin can insert users"
  ON users FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- Policy 5: Admin can update any user
CREATE POLICY "Admin can update any user"
  ON users FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- Policy 6: Admin can delete users (but not themselves)
CREATE POLICY "Admin can delete users"
  ON users FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid() AND role = 'admin'
    )
    AND id <> auth.uid()
  );

-- Verify the policies
SELECT '=== Current policies after fix ===' as info;
SELECT policyname, cmd FROM pg_policies WHERE tablename = 'users';

-- Test query as admin (simulate)
SELECT '=== Test: Can admin see all users? ===' as info;
-- This will show all users if the policy works
SELECT COUNT(*) as user_count FROM users;

-- Show all users
SELECT '=== All users in database ===' as info;
SELECT id, email, name, role FROM users ORDER BY created_at;
