-- ============================================
-- Hapus user dari auth.users (Supabase Auth)
-- ============================================

-- Cek user yang ada di auth.users
SELECT id, email, email_confirmed_at, created_at
FROM auth.users
ORDER BY created_at DESC;

-- Hapus user tertentu berdasarkan email
-- DELETE FROM auth.users WHERE email = 'user@gmail.com';

-- Atau hapus SEMUA user ( TESTING ONLY)
-- DELETE FROM auth.users WHERE email != 'admin@eticketing.com';

-- Hapus semua user untuk fresh start
DELETE FROM auth.users;

-- Cek hasil
SELECT '=== auth.users after delete ===' as info;
SELECT COUNT(*) as total FROM auth.users;
