-- ============================================
-- Debug RLS & User Data
-- ============================================

-- 1. Cek semua user di tabel public.users
SELECT id, email, name, role, created_at FROM users;

-- 2. Cek user di auth.users
SELECT id, email, email_confirmed_at, created_at
FROM auth.users
ORDER BY created_at DESC;

-- 3. Cek tiket yang ada
SELECT id, ticket_no, title, user_id, status, created_at
FROM tickets
ORDER BY created_at DESC;

-- 4. Cek apakah RLS enabled
SELECT tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN ('users', 'tickets', 'comments', 'notifications');

-- 5. Test query dengan auth.uid() (akan return NULL jika tidak ada session)
-- Jalankan ini via client bukan SQL editor
-- SELECT auth.uid();

-- ============================================
-- Fix: Jika user tidak ada di public.users
-- ============================================

-- Sync user dari auth.users ke public.users
INSERT INTO public.users (id, email, name, role)
SELECT
  u.id,
  u.email,
  COALESCE(u.raw_user_meta_data->>'name', split_part(u.email, '@', 1)),
  COALESCE(u.raw_user_meta_data->>'role', 'user')
FROM auth.users u
WHERE NOT EXISTS (
  SELECT 1 FROM public.users p WHERE p.id = u.id
);

-- ============================================
-- Fix: Matikan RLS sementara untuk testing
-- ============================================

-- Uncomment ini untuk DISABLE RLS (testing only)
-- ALTER TABLE tickets DISABLE ROW LEVEL SECURITY;
-- ALTER TABLE comments DISABLE ROW LEVEL SECURITY;
-- ALTER TABLE notifications DISABLE ROW LEVEL SECURITY;

-- Uncomment ini untuk ENABLE RLS kembali
-- ALTER TABLE tickets ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE comments ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- ============================================
-- Fix: Policy debugging - tambahkan policy宽松
-- ============================================

-- Tambah policy yang lebih宽松 untuk testing
DROP POLICY IF EXISTS "Enable all for testing" ON tickets;
CREATE POLICY "Enable all for testing"
  ON tickets FOR ALL
  USING (true)
  WITH CHECK (true);

-- Hapus policy testing ini setelah selesai
-- DROP POLICY "Enable all for testing" ON tickets;
