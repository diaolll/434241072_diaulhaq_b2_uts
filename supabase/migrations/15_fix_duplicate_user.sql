-- ============================================
-- Fix Duplicate User Insert
-- ============================================

-- 1. Hapus trigger yang bentrok
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();

-- 2. Sekarang user insert hanya dari Flutter (auth_repository.dart)
-- Trigger sudah dihapus, jadi tidak ada duplicate

-- 3. Cek hasil
SELECT '=== Trigger removed ===' as info;
