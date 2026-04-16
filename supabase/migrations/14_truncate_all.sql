-- ============================================
-- TRUNCATE SEMUA DATA (RESET DATABASE)
-- Jalankan di Supabase SQL Editor
-- ============================================

-- 1. Truncate semua tabel (urutan benar karena foreign key)
TRUNCATE TABLE ticket_history CASCADE;
TRUNCATE TABLE comments CASCADE;
TRUNCATE TABLE ticket_attachments CASCADE;
TRUNCATE TABLE notifications CASCADE;
TRUNCATE TABLE tickets CASCADE;
TRUNCATE TABLE users CASCADE;

-- 2. Reset auto-increment sequences kalau ada
-- ALTER SEQUENCE users_id_seq RESTART WITH 1;

-- 3. Cek hasil (harus kosong)
SELECT '=== USERS (should be 0) ===' as info;
SELECT COUNT(*) FROM users;

SELECT '=== TICKETS (should be 0) ===' as info;
SELECT COUNT(*) FROM tickets;

SELECT '=== COMMENTS (should be 0) ===' as info;
SELECT COUNT(*) FROM comments;

SELECT '=== NOTIFICATIONS (should be 0) ===' as info;
SELECT COUNT(*) FROM notifications;

-- ============================================
-- Setelah truncate, jalankan ini untuk buat user admin:
-- ============================================

-- Cara 1: Signup via app dengan email admin@example.com
-- Lalu jalankan SQL ini untuk jadikan admin:

-- UPDATE users SET role = 'admin' WHERE email = 'admin@example.com';

-- Atau Cara 2: Insert manual (harus pakai UUID yang sama dengan Supabase Auth)
-- Pertama signup via app, lalu copy user_id-nya dan jalankan:

-- UPDATE users SET role = 'admin' WHERE id = 'USER_ID_DARI_SUPABASE_AUTH';
