-- ============================================
-- Cek & Fix Schema Notifications
-- ============================================

-- 1. Cek schema notifications yang sekarang
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'notifications'
  AND table_schema = 'public';

-- 2. Cek isi notifications
SELECT * FROM notifications LIMIT 5;

-- ============================================
-- FIX: Drop semua trigger yang bermasalah dulu
-- ============================================

DROP TRIGGER IF EXISTS trigger_notify_new_ticket ON tickets;
DROP TRIGGER IF EXISTS trigger_notify_new_comment ON comments;
DROP TRIGGER IF EXISTS trigger_notify_status_change ON tickets;
DROP TRIGGER IF EXISTS trigger_notify_ticket_assign ON tickets;

DROP FUNCTION IF EXISTS notify_on_new_ticket();
DROP FUNCTION IF EXISTS notify_on_new_comment();
DROP FUNCTION IF EXISTS notify_on_status_change();
DROP FUNCTION IF EXISTS notify_on_ticket_assign();

-- ============================================
-- RECREATE notifications table jika perlu
-- ============================================

-- Drop dan recreate dengan schema yang benar
DROP TABLE IF EXISTS notifications CASCADE;

CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  ticket_id UUID,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  type TEXT DEFAULT 'info' CHECK (type IN ('info', 'success', 'warning', 'error')),
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Matikan RLS
ALTER TABLE notifications DISABLE ROW LEVEL SECURITY;

-- Index untuk performance
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_ticket_id ON notifications(ticket_id);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);

-- 3. Cek hasil
SELECT '=== NOTIFICATIONS SCEMA FIXED ===' as info;
SELECT * FROM notifications LIMIT 5;
