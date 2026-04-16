-- ============================================
-- COMPLETE FIX - Jalankan semuanya di Supabase SQL Editor
-- ============================================

-- 1. Buat tabel yang belum ada
CREATE TABLE IF NOT EXISTS ticket_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ticket_id UUID NOT NULL REFERENCES tickets(id) ON DELETE CASCADE,
  changed_by UUID REFERENCES users(id) ON DELETE SET NULL,
  old_status TEXT,
  new_status TEXT NOT NULL,
  note TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE TABLE IF NOT EXISTS ticket_attachments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ticket_id UUID NOT NULL REFERENCES tickets(id) ON DELETE CASCADE,
  file_url TEXT NOT NULL,
  file_name TEXT NOT NULL,
  file_type TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 2. Matikan RLS untuk semua tabel (development mode)
ALTER TABLE users DISABLE ROW LEVEL SECURITY;
ALTER TABLE tickets DISABLE ROW LEVEL SECURITY;
ALTER TABLE comments DISABLE ROW LEVEL SECURITY;
ALTER TABLE notifications DISABLE ROW LEVEL SECURITY;
ALTER TABLE ticket_history DISABLE ROW LEVEL SECURITY;
ALTER TABLE ticket_attachments DISABLE ROW LEVEL SECURITY;

-- 3. Cek tabel
SELECT '=== USERS ===' as info;
SELECT COUNT(*) as total_users FROM users;

SELECT '=== TICKETS ===' as info;
SELECT COUNT(*) as total_tickets FROM tickets;

SELECT '=== COMMENTS ===' as info;
SELECT COUNT(*) as total_comments FROM comments;

-- 4. Pastikan minimal ada 1 user (jika kosong, insert dummy)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM users LIMIT 1) THEN
    INSERT INTO users (id, email, name, role)
    VALUES (
      gen_random_uuid(),
      'test@example.com',
      'Test User',
      'admin'
    );
    RAISE NOTICE 'Created dummy user for testing';
  END IF;
END $$;

-- 5. Cek hasil
SELECT '=== SETELAH FIX ===' as info;
SELECT id, email, name, role FROM users LIMIT 5;
