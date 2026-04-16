-- ============================================
-- Notification Triggers
-- Auto-create notifications for events
-- ============================================

-- Function: Create notification when ticket is created
CREATE OR REPLACE FUNCTION notify_on_new_ticket()
RETURNS TRIGGER AS $$
BEGIN
  -- Notify all admin and helpdesk users
  INSERT INTO notifications (user_id, ticket_id, title, message, type)
  SELECT
    u.id,
    NEW.id,
    'Tiket Baru',
    'Tiket #' || COALESCE(NEW.ticket_no, 'N/A') || ': ' || NEW.title,
    'info'
  FROM users u
  WHERE u.role IN ('admin', 'helpdesk')
    AND u.id != NEW.user_id;  -- Don't notify creator

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger: Call function on ticket insert
DROP TRIGGER IF EXISTS trigger_notify_new_ticket ON tickets;
CREATE TRIGGER trigger_notify_new_ticket
  AFTER INSERT ON tickets
  FOR EACH ROW
  EXECUTE FUNCTION notify_on_new_ticket();

-- ============================================
-- Function: Create notification when comment is added
CREATE OR REPLACE FUNCTION notify_on_new_comment()
RETURNS TRIGGER AS $$
DECLARE
  ticket_user_id UUID;
  ticket_assigned_to UUID;
  ticket_no TEXT;
BEGIN
  -- Get ticket details
  SELECT user_id, assigned_to, ticket_no
  INTO ticket_user_id, ticket_assigned_to, ticket_no
  FROM tickets
  WHERE id = NEW.ticket_id;

  -- Notify ticket creator if comment not from creator
  IF ticket_user_id IS NOT NULL AND ticket_user_id != NEW.user_id THEN
    INSERT INTO notifications (user_id, ticket_id, title, message, type)
    VALUES (
      ticket_user_id,
      NEW.ticket_id,
      'Komentar Baru',
      'Ada komentar baru pada tiket #' || COALESCE(ticket_no, 'N/A'),
      'info'
    );
  END IF;

  -- Notify assigned user if different
  IF ticket_assigned_to IS NOT NULL
     AND ticket_assigned_to != NEW.user_id
     AND ticket_assigned_to != ticket_user_id
  THEN
    INSERT INTO notifications (user_id, ticket_id, title, message, type)
    VALUES (
      ticket_assigned_to,
      NEW.ticket_id,
      'Komentar Baru',
      'Ada komentar baru pada tiket #' || COALESCE(ticket_no, 'N/A'),
      'info'
    );
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger: Call function on comment insert
DROP TRIGGER IF EXISTS trigger_notify_new_comment ON comments;
CREATE TRIGGER trigger_notify_new_comment
  AFTER INSERT ON comments
  FOR EACH ROW
  EXECUTE FUNCTION notify_on_new_comment();

-- ============================================
-- Function: Create notification when ticket status changes
CREATE OR REPLACE FUNCTION notify_on_status_change()
RETURNS TRIGGER AS $$
DECLARE
  ticket_user_id UUID;
  ticket_no TEXT;
  ticket_title TEXT;
BEGIN
  -- Only notify if status actually changed
  IF OLD.status IS DISTINCT FROM NEW.status THEN
    -- Get ticket details
    SELECT user_id, ticket_no, title
    INTO ticket_user_id, ticket_no, ticket_title
    FROM tickets
    WHERE id = NEW.id;

    -- Notify ticket creator
    IF ticket_user_id IS NOT NULL THEN
      INSERT INTO notifications (user_id, ticket_id, title, message, type)
      VALUES (
        ticket_user_id,
        NEW.id,
        'Status Tiket Diubah',
        'Tiket #' || COALESCE(ticket_no, 'N/A') || ': ' || ticket_title || ' - Status sekarang: ' || NEW.status,
        CASE
          WHEN NEW.status = 'resolved' THEN 'success'
          WHEN NEW.status = 'closed' THEN 'info'
          ELSE 'info'
        END
      );
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger: Call function on ticket update
DROP TRIGGER IF EXISTS trigger_notify_status_change ON tickets;
CREATE TRIGGER trigger_notify_status_change
  AFTER UPDATE ON tickets
  FOR EACH ROW
  EXECUTE FUNCTION notify_on_status_change();

-- ============================================
-- Function: Create notification when ticket is assigned
CREATE OR REPLACE FUNCTION notify_on_ticket_assign()
RETURNS TRIGGER AS $$
DECLARE
  ticket_no TEXT;
BEGIN
  -- Only notify if assigned_to changed and is not null
  IF NEW.assigned_to IS NOT NULL AND (OLD.assigned_to IS DISTINCT FROM NEW.assigned_to) THEN
    -- Get ticket number
    SELECT ticket_no INTO ticket_no
    FROM tickets
    WHERE id = NEW.id;

    -- Notify the assigned user
    INSERT INTO notifications (user_id, ticket_id, title, message, type)
    VALUES (
      NEW.assigned_to,
      NEW.id,
      'Tiket Ditugaskan',
      'Anda telah ditugaskan untuk tiket #' || COALESCE(ticket_no, 'N/A'),
      'info'
    );
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger: Call function on ticket update
DROP TRIGGER IF EXISTS trigger_notify_ticket_assign ON tickets;
CREATE TRIGGER trigger_notify_ticket_assign
  AFTER UPDATE OF assigned_to ON tickets
  FOR EACH ROW
  EXECUTE FUNCTION notify_on_ticket_assign();
