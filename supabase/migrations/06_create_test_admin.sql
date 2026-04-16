-- ============================================
-- Create Test Admin User (for testing)
-- ============================================

-- Cara 1: Insert langsung ke auth.users (perlu service role)
-- Ini harus lewat Supabase Dashboard SQL Editor dengan service role

-- Cara 2: Manual signup lewat Flutter/App, lalu set role jadi admin:
-- Jalankan SQL ini setelah signup:

-- Update user jadi admin (ganti email dengan email yang sudah signup)
UPDATE users
SET role = 'admin'
WHERE email = 'admin@eticketing.com';

-- Atau buat admin user baru (sesuaikan email)
-- Pertama signup lewat app, lalu jalankan:
UPDATE users
SET role = 'admin'
WHERE email = 'your_admin_email@example.com';

-- Cek user yang ada
SELECT id, email, name, role, created_at FROM users;

-- ============================================
-- Alternative: Create user via SQL (Service Role only)
-- ============================================

-- Hanya bisa dijalankan dengan service role key:
-- INSERT INTO auth.users (instance_id, id, email, encrypted_password, email_confirmed_at, raw_user_meta_data, created_at, updated_at)
-- VALUES ...

-- Untuk development, lebih mudah signup lewat app lalu update role
