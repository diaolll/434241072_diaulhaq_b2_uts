-- ============================================
-- Fix Semua Tabel untuk Development
-- ============================================

-- 1. Buat tabel ticket_history yang belum ada
CREATE TABLE IF NOT EXISTS ticket_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ticket_id UUID NOT NULL REFERENCES tickets(id) ON DELETE CASCADE,
  changed_by UUID REFERENCES users(id) ON DELETE SET NULL,
  old_status TEXT,
  new_status TEXT NOT NULL,
  note TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 2. Disable RLS untuk semua tabel (development)
ALTER TABLE tickets DISABLE ROW LEVEL SECURITY;
ALTER TABLE comments DISABLE ROW LEVEL SECURITY;
ALTER TABLE notifications DISABLE ROW LEVEL SECURITY;
ALTER TABLE ticket_history DISABLE ROW LEVEL SECURITY;
ALTER TABLE ticket_attachments DISABLE ROW LEVEL SECURITY;

-- 3. Cek apakah tabel users ada dan ada data
SELECT '=== USERS ===' as info;
SELECT id, email, name, role FROM users;

-- 4. Cek apakah tabel tickets ada dan ada data
SELECT '=== TICKETS ===' as info;
SELECT id, ticket_no, title, status, user_id FROM tickets LIMIT 5;

-- 5. Enable RLS kembali jika sudah selesai testing (uncomment below)
-- ALTER TABLE tickets ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE comments ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE ticket_history ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE ticket_attachments ENABLE ROW LEVEL SECURITY;
