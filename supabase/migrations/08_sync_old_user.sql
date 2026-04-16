-- ============================================
-- Sync User Lama ke Supabase Auth
-- ============================================

-- Cek user lama
SELECT * FROM users WHERE id = 'cd4e9b28-3ca6-4769-abdc-f950a6ab11e7';

-- Cek apakah ada di auth.users
SELECT id, email FROM auth.users WHERE id = 'cd4e9b28-3ca6-4769-abdc-f950a6ab11e7';

-- ============================================
-- SOLUSI: Buat user di auth.users dengan ID yang sama
-- ============================================

-- Tapi auth.users tidak bisa langsung insert id manual
-- Solusi: Signup dengan email yang sama, lalu UPDATE tiket ke user_id baru

-- Atau: Update semua tiket ke user_id baru setelah signup
-- UPDATE tickets SET user_id = 'new_user_id_here' WHERE user_id = 'cd4e9b28-3ca6-4769-abdc-f950a6ab11e7';

-- ============================================
-- SOLUSI PRAKTIS: Matikan RLS untuk tickets
-- ============================================

-- Matikan RLS sementara
ALTER TABLE tickets DISABLE ROW LEVEL SECURITY;
ALTER TABLE comments DISABLE ROW LEVEL SECURITY;
ALTER TABLE notifications DISABLE ROW LEVEL SECURITY;

-- Untuk enable kembali nanti:
-- ALTER TABLE tickets ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE comments ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- ============================================
-- Atau: Update tiket yang user_id-nya null/invalid
-- ============================================

-- Cek tiket dengan user_id yang tidak ada di users
SELECT t.id, t.ticket_no, t.user_id, u.email
FROM tickets t
LEFT JOIN users u ON t.user_id = u.id
WHERE u.id IS NULL;
