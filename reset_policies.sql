-- ============================================
-- RESET ALL ROW LEVEL SECURITY POLICIES
-- Jalankan ini dulu kalau mau refresh dari awal
-- ============================================

-- Drop all existing policies
DROP POLICY IF EXISTS "Users can view own profile" ON public.users;
DROP POLICY IF EXISTS "Users can update own profile" ON public.users;
DROP POLICY IF EXISTS "Users can insert own profile" ON public.users;
DROP POLICY IF EXISTS "Tickets are viewable by everyone" ON public.tickets;
DROP POLICY IF EXISTS "Users can create tickets" ON public.tickets;
DROP POLICY IF EXISTS "Users can update own tickets" ON public.tickets;
DROP POLICY IF EXISTS "Helpdesk and Admin can update any ticket" ON public.tickets;
DROP POLICY IF EXISTS "Comments are viewable by everyone" ON public.comments;
DROP POLICY IF EXISTS "Users can create comments" ON public.comments;
DROP POLICY IF EXISTS "Users can update own comments" ON public.comments;
DROP POLICY IF EXISTS "Helpdesk and Admin can update any comment" ON public.comments;
DROP POLICY IF EXISTS "Attachments viewable via tickets" ON public.ticket_attachments;
DROP POLICY IF EXISTS "Users can upload attachments" ON public.ticket_attachments;
DROP POLICY IF EXISTS "History is viewable by everyone" ON public.ticket_history;
DROP POLICY IF EXISTS "Helpdesk and Admin can create history" ON public.ticket_history;
DROP POLICY IF EXISTS "Users can view own notifications" ON public.notifications;
DROP POLICY IF EXISTS "Notifications can be inserted by system" ON public.notifications;
DROP POLICY IF EXISTS "Users can update own notifications" ON public.notifications;
DROP POLICY IF EXISTS "Profiles are viewable by everyone" ON public.user_profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON public.user_profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON public.user_profiles;

-- Drop existing triggers
DROP TRIGGER IF EXISTS set_ticket_no_trigger ON public.tickets;
DROP TRIGGER IF EXISTS update_users_updated_at ON public.users;
DROP TRIGGER IF EXISTS update_tickets_updated_at ON public.tickets;
DROP TRIGGER IF EXISTS update_user_profiles_updated_at ON public.user_profiles;

-- Drop existing functions
DROP FUNCTION IF EXISTS set_ticket_no();
DROP FUNCTION IF EXISTS update_updated_at();
DROP FUNCTION IF EXISTS generate_ticket_no();
