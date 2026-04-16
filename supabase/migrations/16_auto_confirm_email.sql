-- ============================================
-- Auto-Confirm Email (No need to verify)
-- ============================================

-- Cara 1: Update user yang sudah ada
UPDATE auth.users
SET email_confirmed_at = now()
WHERE email_confirmed_at IS NULL;

-- Cara 2: Buat trigger untuk auto-confirm new users
CREATE OR REPLACE FUNCTION public.auto_confirm_email()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE auth.users
  SET email_confirmed_at = now()
  WHERE id = NEW.id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop trigger lama jika ada
DROP TRIGGER IF EXISTS on_auth_user_created_trigger ON auth.users;

-- Buat trigger baru
CREATE TRIGGER on_auth_user_created_trigger
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.auto_confirm_email();

-- 3. Cek hasil
SELECT id, email, email_confirmed_at
FROM auth.users
ORDER BY created_at DESC
LIMIT 5;
