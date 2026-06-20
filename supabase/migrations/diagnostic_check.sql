-- ============================================
-- Diagnostic Check - Run this in Supabase SQL Editor
-- ============================================

-- 1. Check current RLS status
SELECT
  tablename,
  rowsecurity as rls_enabled
FROM pg_tables
WHERE schemaname = 'public' AND tablename = 'users';

-- 2. Check all current policies on users table
SELECT
  policyname,
  cmd as command_type,
  qual as using_expression,
  with_check,
  roles
FROM pg_policies
WHERE tablename = 'users'
ORDER BY policyname;

-- 3. Check current users data
SELECT id, email, name, role, created_at
FROM users
ORDER BY created_at DESC;

-- 4. Check if the upsert_user function exists
SELECT
  routine_name,
  routine_type,
  security_type
FROM information_schema.routines
WHERE routine_schema = 'public'
AND routine_name LIKE '%user%';

-- 5. Check if the trigger exists on auth.users
-- (This queries the auth schema)
SELECT
  trigger_name,
  event_manipulation,
  action_statement,
  action_timing
FROM information_schema.triggers
WHERE event_object_schema = 'auth'
  AND event_object_table = 'users'
  AND trigger_name = 'on_auth_user_created';

-- 6. Sample check of auth users vs public users
SELECT
  au.id,
  au.email,
  au.raw_user_meta_data->>'name' as meta_name,
  au.raw_user_meta_data->>'role' as meta_role,
  pu.name as public_name,
  pu.role as public_role
FROM auth.users au
LEFT JOIN public.users pu ON pu.id = au.id
ORDER BY au.created_at DESC
LIMIT 5;
