-- ============================================
-- Fix remaining user issues
-- Run this in Supabase Dashboard SQL Editor
-- ============================================

-- Check the auth metadata for labubu@gmail.com
SELECT
  au.id,
  au.email,
  au.raw_user_meta_data->>'name' as meta_name,
  au.raw_user_meta_data->>'role' as meta_role,
  au.raw_user_meta_data as full_metadata,
  pu.name as public_name,
  pu.role as public_role
FROM auth.users au
LEFT JOIN public.users pu ON pu.id = au.id
WHERE au.email = 'labubu@gmail.com';

-- Force update this specific user from auth metadata
UPDATE public.users
SET
  name = (
    SELECT raw_user_meta_data->>'name'
    FROM auth.users
    WHERE id = public.users.id
  ),
  role = (
    SELECT raw_user_meta_data->>'role'
    FROM auth.users
    WHERE id = public.users.id
  )
WHERE id = (
  SELECT id FROM auth.users WHERE email = 'labubu@gmail.com'
);

-- Verify the fix
SELECT id, email, name, role
FROM public.users
WHERE email = 'labubu@gmail.com';

-- Also check if there are any other users with null names
SELECT id, email, name, role
FROM public.users
WHERE name IS NULL OR role IS NULL;
