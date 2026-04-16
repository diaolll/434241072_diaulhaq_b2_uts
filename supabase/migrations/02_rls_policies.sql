-- ============================================
-- Row Level Security (RLS) Policies
-- ============================================

-- Enable RLS on all tables
alter table users enable row level security;
alter table tickets enable row level security;
alter table comments enable row level security;
alter table notifications enable row level security;

-- ============================================
-- USERS TABLE POLICIES
-- ============================================

-- Users can view their own profile
create policy "Users can view own profile"
  on users for select
  using (auth.uid() = id);

-- Users can update their own profile
create policy "Users can update own profile"
  on users for update
  using (auth.uid() = id);

-- Admin/Helpdesk can view all users
create policy "Admin can view all users"
  on users for select
  using (
    exists (
      select 1 from users
      where id = auth.uid() and role in ('admin', 'helpdesk')
    )
  );

-- ============================================
-- TICKETS TABLE POLICIES
-- ============================================

-- Users can view their own tickets
create policy "Users can view own tickets"
  on tickets for select
  using (user_id = auth.uid());

-- Users can create tickets
create policy "Users can create tickets"
  on tickets for insert
  with check (user_id = auth.uid());

-- Users can update their own tickets
create policy "Users can update own tickets"
  on tickets for update
  using (user_id = auth.uid());

-- Helpdesk/Admin can view all tickets
create policy "Helpdesk can view all tickets"
  on tickets for select
  using (
    exists (
      select 1 from users
      where id = auth.uid() and role in ('admin', 'helpdesk')
    )
  );

-- Helpdesk/Admin can update any ticket
create policy "Helpdesk can update any ticket"
  on tickets for update
  using (
    exists (
      select 1 from users
      where id = auth.uid() and role in ('admin', 'helpdesk')
    )
  );

-- ============================================
-- COMMENTS TABLE POLICIES
-- ============================================

-- Users can view comments on their tickets or assigned tickets
create policy "Users can view relevant comments"
  on comments for select
  using (
    exists (
      select 1 from tickets
      where tickets.id = comments.ticket_id
      and (tickets.user_id = auth.uid() or tickets.assigned_to = auth.uid())
    )
  );

-- Users can create comments on their tickets
create policy "Users can create comments"
  on comments for insert
  with check (
    exists (
      select 1 from tickets
      where tickets.id = ticket_id
      and tickets.user_id = auth.uid()
    )
  );

-- Helpdesk can create comments on any ticket
create policy "Helpdesk can create comments"
  on comments for insert
  with check (
    exists (
      select 1 from users
      where id = auth.uid() and role in ('admin', 'helpdesk')
    )
  );

-- ============================================
-- NOTIFICATIONS TABLE POLICIES
-- ============================================

-- Users can view their own notifications
create policy "Users can view own notifications"
  on notifications for select
  using (user_id = auth.uid());

-- Users can update their own notifications (mark as read)
create policy "Users can update own notifications"
  on notifications for update
  using (user_id = auth.uid());

-- ============================================
-- DISABLE RLS FOR DEVELOPMENT (OPTIONAL)
-- ============================================
-- Uncomment below to disable RLS during development
-- alter table users disable row level security;
-- alter table tickets disable row level security;
-- alter table comments disable row level security;
-- alter table notifications disable row level security;
