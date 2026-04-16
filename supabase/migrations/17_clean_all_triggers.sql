-- ============================================
-- Bersihkan SEMUA trigger untuk development
-- ============================================

-- Drop semua trigger
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP TRIGGER IF EXISTS on_auth_user_created_trigger ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();
DROP FUNCTION IF EXISTS public.auto_confirm_email();

-- Matikan email confirmation requirement
UPDATE auth.users SET email_confirmed_at = now() WHERE email_confirmed_at IS NULL;

-- Cek hasil
SELECT '=== Triggers removed ===' as info;
