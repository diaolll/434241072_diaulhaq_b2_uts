-- ============================================
-- SYNC DATA MYSQL LAMA → SUPABASE
-- Jalankan di Supabase SQL Editor
-- ============================================

-- 1. Update tiket lama ke user baru (setelah login dengan email yang sama)
-- Misal: setelah login sebagai heh@gmail.com, jalankan:

-- Cek user_id baru dari auth
-- SELECT id, email FROM auth.users;

-- Update tiket yang user_id-nya lama ke user_id baru
-- Ganti OLD_USER_ID dengan user_id dari MySQL, dan NEW_USER_ID dari Supabase Auth
-- UPDATE tickets SET user_id = 'NEW_USER_ID_FROM_SUPABASE' WHERE user_id = 'OLD_USER_ID_FROM_MYSQL';
-- UPDATE comments SET user_id = 'NEW_USER_ID_FROM_SUPABASE' WHERE user_id = 'OLD_USER_ID_FROM_MYSQL';
-- UPDATE notifications SET user_id = 'NEW_USER_ID_FROM_SUPABASE' WHERE user_id = 'OLD_USER_ID_FROM_MYSQL';

-- ============================================
-- ALTERNATIF: Sync berdasarkan email (lebih gampang)
-- ============================================

-- 1. Pastikan sudah login di Supabase dengan email yang sama
-- 2. Jalankan query ini untuk sync otomatis berdasarkan email

-- Update tickets - cari user_id dari users table berdasarkan email yang cocok
-- (Perlu mapping email lama ke user_id baru)

-- Contoh: Sync tiket untuk email tertentu
-- UPDATE tickets t
-- SET user_id = (
--   SELECT u.id FROM users u
--   WHERE u.email = 'heh@gmail.com'
-- )
-- WHERE t.user_id IN (
--   SELECT old_id FROM (SELECT 'cd4e9b28-3ca6-4769-abdc-f950a6ab11e7' as old_id) as old_ids
-- );

-- ============================================
-- CARA PALING GAMPANG:
-- 1. Login dengan email yang dulu dipakai di MySQL
-- 2. Jalankan query di bawah untuk update semua tiket ke user_id baru
-- ============================================

-- Login dulu, lalu jalankan ini:
UPDATE tickets
SET user_id = auth.uid()
WHERE user_id = 'cd4e9b28-3ca6-4769-abdc-f950a6ab11e7';

UPDATE comments
SET user_id = auth.uid()
WHERE user_id = 'cd4e9b28-3ca6-4769-abdc-f950a6ab11e7';

-- Untuk multiple users dari MySQL, sync manual:
-- UPDATE tickets SET user_id = 'SUPABASE_USER_ID' WHERE user_id = 'MYSQL_USER_ID';
