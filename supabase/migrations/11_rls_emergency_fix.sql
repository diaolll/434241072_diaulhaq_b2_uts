-- ============================================
-- EMERGENCY FIX: Disable RLS temporarily
-- Run this immediately to restore login
-- ============================================

-- Disable RLS temporarily so you can login
ALTER TABLE users DISABLE ROW LEVEL SECURITY;

-- Verify you can see users
SELECT id, email, name, role FROM users WHERE email = 'admin@gmail.com';

-- Once you can login, we'll re-enable RLS with proper policies
