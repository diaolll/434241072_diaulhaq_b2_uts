-- ============================================
-- E-Ticketing Helpdesk - Database Schema
-- ============================================

-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- ============================================
-- TABLE: users
-- ============================================
create table users (
  id uuid primary key default gen_random_uuid(),
  email text unique not null,
  password text not null,
  name text not null,
  role text not null default 'user' check (role in ('user', 'helpdesk', 'admin')),
  avatar_url text,
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

-- ============================================
-- TABLE: tickets
-- ============================================
create table tickets (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references users(id) on delete cascade,
  title text not null,
  description text not null,
  category text not null,
  priority text not null default 'medium' check (priority in ('low', 'medium', 'high', 'critical')),
  status text not null default 'open' check (status in ('open', 'in_progress', 'resolved', 'closed')),
  assigned_to uuid references users(id) on delete set null,
  location text,
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

-- ============================================
-- TABLE: comments
-- ============================================
create table comments (
  id uuid primary key default gen_random_uuid(),
  ticket_id uuid not null references tickets(id) on delete cascade,
  user_id uuid not null references users(id) on delete cascade,
  content text not null,
  created_at timestamp with time zone default now()
);

-- ============================================
-- TABLE: notifications
-- ============================================
create table notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references users(id) on delete cascade,
  ticket_id uuid references tickets(id) on delete cascade,
  title text not null,
  message text not null,
  type text not null default 'info' check (type in ('info', 'success', 'warning', 'error')),
  is_read boolean default false,
  created_at timestamp with time zone default now()
);

-- ============================================
-- INDEXES for better performance
-- ============================================
create index idx_tickets_user_id on tickets(user_id);
create index idx_tickets_status on tickets(status);
create index idx_tickets_priority on tickets(priority);
create index idx_tickets_assigned_to on tickets(assigned_to);
create index idx_comments_ticket_id on comments(ticket_id);
create index idx_notifications_user_id on notifications(user_id);
create index idx_notifications_is_read on notifications(is_read);

-- ============================================
-- INSERT sample admin user (password: admin123)
-- ============================================
insert into users (email, password, name, role) values
('admin@eticketing.com', '$2a$10$YourHashedPasswordHere', 'Admin', 'admin'),
('helpdesk@eticketing.com', '$2a$10$YourHashedPasswordHere', 'Helpdesk Team', 'helpdesk');
