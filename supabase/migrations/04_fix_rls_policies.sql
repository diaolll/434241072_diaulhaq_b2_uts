-- ============================================
-- Fixed RLS Policies for Supabase Auth
-- ============================================

-- Drop existing policies
DROP POLICY IF EXISTS "Users can view own profile" ON users;
DROP POLICY IF EXISTS "Users can update own profile" ON users;
DROP POLICY IF EXISTS "Admin can view all users" ON users;

DROP POLICY IF EXISTS "Users can view own tickets" ON tickets;
DROP POLICY IF EXISTS "Users can create tickets" ON tickets;
DROP POLICY IF EXISTS "Users can update own tickets" ON tickets;
DROP POLICY IF EXISTS "Helpdesk can view all tickets" ON tickets;
DROP POLICY IF EXISTS "Helpdesk can update any ticket" ON tickets;

DROP POLICY IF EXISTS "Users can view relevant comments" ON comments;
DROP POLICY IF EXISTS "Users can create comments" ON comments;
DROP POLICY IF EXISTS "Helpdesk can create comments" ON comments;

DROP POLICY IF EXISTS "Users can view own notifications" ON notifications;
DROP POLICY IF EXISTS "Users can update own notifications" ON notifications;
DROP POLICY IF EXISTS "Users can insert own profile" ON users;
DROP POLICY IF EXISTS "Helpdesk can comment on any ticket" ON comments;

-- ============================================
-- USERS TABLE POLICIES (Fixed)
-- ============================================

-- Users can view their own profile
CREATE POLICY "Users can view own profile"
  ON users FOR SELECT
  USING (auth.uid() = id);

-- Users can update their own profile
CREATE POLICY "Users can update own profile"
  ON users FOR UPDATE
  USING (auth.uid() = id);

-- Users can insert their own profile (for new signups)
CREATE POLICY "Users can insert own profile"
  ON users FOR INSERT
  WITH CHECK (auth.uid() = id);

-- Admin/Helpdesk can view all users
CREATE POLICY "Admin can view all users"
  ON users FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid() AND role IN ('admin', 'helpdesk')
    )
  );

-- ============================================
-- TICKETS TABLE POLICIES (Fixed)
-- ============================================

-- Users can view their own tickets
CREATE POLICY "Users can view own tickets"
  ON tickets FOR SELECT
  USING (user_id = auth.uid());

-- Users can create tickets
CREATE POLICY "Users can create tickets"
  ON tickets FOR INSERT
  WITH CHECK (user_id = auth.uid());

-- Users can update their own tickets
CREATE POLICY "Users can update own tickets"
  ON tickets FOR UPDATE
  USING (user_id = auth.uid());

-- Helpdesk/Admin can view all tickets
CREATE POLICY "Helpdesk can view all tickets"
  ON tickets FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid() AND role IN ('admin', 'helpdesk')
    )
  );

-- Helpdesk/Admin can update any ticket
CREATE POLICY "Helpdesk can update any ticket"
  ON tickets FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid() AND role IN ('admin', 'helpdesk')
    )
  );

-- ============================================
-- COMMENTS TABLE POLICIES (Fixed)
-- ============================================

-- Users can view comments on their tickets or assigned tickets
CREATE POLICY "Users can view relevant comments"
  ON comments FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM tickets
      WHERE tickets.id = comments.ticket_id
      AND (tickets.user_id = auth.uid() OR tickets.assigned_to = auth.uid())
    )
  );

-- Users can create comments on their tickets
CREATE POLICY "Users can create comments"
  ON comments FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM tickets
      WHERE tickets.id = ticket_id
      AND tickets.user_id = auth.uid()
    )
  );

-- Helpdesk can create comments on any ticket
CREATE POLICY "Helpdesk can create comments"
  ON comments FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid() AND role IN ('admin', 'helpdesk')
    )
  );

-- ============================================
-- NOTIFICATIONS TABLE POLICIES (Fixed)
-- ============================================

-- Users can view their own notifications
CREATE POLICY "Users can view own notifications"
  ON notifications FOR SELECT
  USING (user_id = auth.uid());

-- Users can update their own notifications (mark as read)
CREATE POLICY "Users can update own notifications"
  ON notifications FOR UPDATE
  USING (user_id = auth.uid());

-- Service role (triggers) can insert notifications
-- This is handled by Postgres security model (triggers run with definer rights)

-- ============================================
-- COMMENTS TABLE - Extra policy for helpdesk to comment on any ticket
-- ============================================

CREATE POLICY "Helpdesk can comment on any ticket"
  ON comments FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid() AND role IN ('admin', 'helpdesk')
    )
  );
