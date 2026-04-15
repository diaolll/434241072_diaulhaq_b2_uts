-- ============================================
-- E-TICKETING HELPSKET - SUPABASE DATABASE SCHEMA
-- ============================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- 1. USERS TABLE (dengan role management)
-- ============================================
CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'user' CHECK (role IN ('admin', 'helpdesk', 'user')),
    avatar_url TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Constraints
    CONSTRAINT users_email_check CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_users_email ON public.users(email);
CREATE INDEX IF NOT EXISTS idx_users_role ON public.users(role);

-- ============================================
-- 2. TICKETS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.tickets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    ticket_no VARCHAR(50) UNIQUE NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    category VARCHAR(100),
    priority VARCHAR(20) NOT NULL DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high', 'critical')),
    status VARCHAR(20) NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'in_progress', 'resolved', 'closed')),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    assigned_to UUID REFERENCES public.users(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Generated ticket number format: TKT-YYYYMMDD-XXXX
    CONSTRAINT tickets_ticket_no_format CHECK (ticket_no ~* '^TKT-\d{8}-\d{4}$')
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_tickets_user_id ON public.tickets(user_id);
CREATE INDEX IF NOT EXISTS idx_tickets_assigned_to ON public.tickets(assigned_to);
CREATE INDEX IF NOT EXISTS idx_tickets_status ON public.tickets(status);
CREATE INDEX IF NOT EXISTS idx_tickets_priority ON public.tickets(priority);
CREATE INDEX IF NOT EXISTS idx_tickets_category ON public.tickets(category);
CREATE INDEX IF NOT EXISTS idx_tickets_created_at ON public.tickets(created_at DESC);

-- ============================================
-- 3. TICKET ATTACHMENTS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.ticket_attachments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    ticket_id UUID NOT NULL REFERENCES public.tickets(id) ON DELETE CASCADE,
    file_url TEXT NOT NULL,
    file_name VARCHAR(255) NOT NULL,
    file_type VARCHAR(100),
    file_size BIGINT,
    uploaded_by UUID REFERENCES public.users(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_ticket_attachments_ticket_id ON public.ticket_attachments(ticket_id);
CREATE INDEX IF NOT EXISTS idx_ticket_attachments_uploaded_by ON public.ticket_attachments(uploaded_by);

-- ============================================
-- 4. COMMENTS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.comments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    ticket_id UUID NOT NULL REFERENCES public.tickets(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    is_internal BOOLEAN DEFAULT false, -- True = hanya terlihat oleh admin/helpdesk
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    CONSTRAINT comments_content_check CHECK (LENGTH(TRIM(content)) > 0)
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_comments_ticket_id ON public.comments(ticket_id);
CREATE INDEX IF NOT EXISTS idx_comments_user_id ON public.comments(user_id);
CREATE INDEX IF NOT EXISTS idx_comments_created_at ON public.comments(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_comments_is_internal ON public.comments(is_internal);

-- ============================================
-- 5. TICKET HISTORY TABLE (untuk tracking status changes)
-- ============================================
CREATE TABLE IF NOT EXISTS public.ticket_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    ticket_id UUID NOT NULL REFERENCES public.tickets(id) ON DELETE CASCADE,
    changed_by UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    old_status VARCHAR(20),
    new_status VARCHAR(20) NOT NULL,
    note TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_ticket_history_ticket_id ON public.ticket_history(ticket_id);
CREATE INDEX IF NOT EXISTS idx_ticket_history_changed_by ON public.ticket_history(changed_by);
CREATE INDEX IF NOT EXISTS idx_ticket_history_created_at ON public.ticket_history(created_at DESC);

-- ============================================
-- 6. NOTIFICATIONS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    ticket_id UUID REFERENCES public.tickets(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    body TEXT NOT NULL,
    type VARCHAR(50) DEFAULT 'status_update', -- status_update, comment, assigned, etc.
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON public.notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_ticket_id ON public.notifications(ticket_id);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON public.notifications(is_read);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON public.notifications(created_at DESC);

-- ============================================
-- 7. USER PROFILES TABLE (opsional - untuk data tambahan user)
-- ============================================
CREATE TABLE IF NOT EXISTS public.user_profiles (
    id UUID PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
    phone VARCHAR(20),
    department VARCHAR(100),
    location VARCHAR(255),
    avatar_url TEXT,
    preferences JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- FUNCTIONS & TRIGGERS
-- ============================================

-- Function to generate ticket number
CREATE OR REPLACE FUNCTION generate_ticket_no()
RETURNS VARCHAR(50) AS $$
DECLARE
    v_date TEXT := TO_CHAR(CURRENT_DATE, 'YYYYMMDD');
    v_count INTEGER;
    v_seq TEXT;
BEGIN
    -- Count tickets for today
    SELECT COUNT(*) INTO v_count
    FROM public.tickets
    WHERE created_at::DATE = CURRENT_DATE;

    -- Generate sequence (4 digits with leading zeros)
    v_seq := LPAD((v_count + 1)::TEXT, 4, '0');

    RETURN 'TKT-' || v_date || '-' || v_seq;
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-generate ticket number
CREATE OR REPLACE FUNCTION set_ticket_no()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.ticket_no IS NULL OR NEW.ticket_no = '' THEN
        NEW.ticket_no := generate_ticket_no();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for tickets
DROP TRIGGER IF EXISTS set_ticket_no_trigger ON public.tickets;
CREATE TRIGGER set_ticket_no_trigger
    BEFORE INSERT ON public.tickets
    FOR EACH ROW
    EXECUTE FUNCTION set_ticket_no();

-- Function to update updated_at
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Add updated_at triggers
DROP TRIGGER IF EXISTS update_users_updated_at ON public.users;
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON public.users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

DROP TRIGGER IF EXISTS update_tickets_updated_at ON public.tickets;
CREATE TRIGGER update_tickets_updated_at
    BEFORE UPDATE ON public.tickets
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

DROP TRIGGER IF EXISTS update_user_profiles_updated_at ON public.user_profiles;
CREATE TRIGGER update_user_profiles_updated_at
    BEFORE UPDATE ON public.user_profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

-- ============================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================

ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tickets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ticket_attachments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ticket_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;

-- Users: Users can only see their own profile
CREATE POLICY "Users can view own profile" ON public.users
    FOR SELECT
    USING (auth.uid()::text = id::text);

CREATE POLICY "Users can update own profile" ON public.users
    FOR UPDATE
    USING (auth.uid()::text = id::text);

CREATE POLICY "Users can insert own profile" ON public.users
    FOR INSERT
    WITH CHECK (auth.uid()::text = id::text);

-- Tickets: Users can view all tickets, helpdesk/admin can view all
CREATE POLICY "Tickets are viewable by everyone" ON public.tickets
    FOR SELECT
    USING (true);

CREATE POLICY "Users can create tickets" ON public.tickets
    FOR INSERT
    WITH CHECK (auth.uid()::text = user_id::text);

CREATE POLICY "Users can update own tickets" ON public.tickets
    FOR UPDATE
    USING (auth.uid()::text = user_id::text);

CREATE POLICY "Helpdesk and Admin can update any ticket" ON public.tickets
    FOR UPDATE
    USING (
        auth.uid()::text IN (
            SELECT id::text FROM public.users WHERE role IN ('helpdesk', 'admin')
        )
    );

-- Comments: Everyone can view comments, users can create
CREATE POLICY "Comments are viewable by everyone" ON public.comments
    FOR SELECT
    USING (true);

CREATE POLICY "Users can create comments" ON public.comments
    FOR INSERT
    WITH CHECK (auth.uid()::text = user_id::text);

CREATE POLICY "Users can update own comments" ON public.comments
    FOR UPDATE
    USING (auth.uid()::text = user_id::text);

CREATE POLICY "Helpdesk and Admin can update any comment" ON public.comments
    FOR UPDATE
    USING (
        auth.uid()::text IN (
            SELECT id::text FROM public.users WHERE role IN ('helpdesk', 'admin')
        )
    );

-- Attachments: Read-only based on ticket access
CREATE POLICY "Attachments viewable via tickets" ON public.ticket_attachments
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.tickets t
            JOIN public.users u ON u.id = t.user_id
            WHERE t.id = ticket_attachments.ticket_id
            AND (
                u.id::text = auth.uid()::text
                OR u.role IN ('helpdesk', 'admin')
            )
        )
    );

CREATE POLICY "Users can upload attachments" ON public.ticket_attachments
    FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.tickets
            WHERE id = ticket_attachments.ticket_id
            AND user_id::text = auth.uid()::text
        )
    );

-- Ticket History: Viewable by everyone
CREATE POLICY "History is viewable by everyone" ON public.ticket_history
    FOR SELECT
    USING (true);

-- Only helpdesk/admin can create history entries
CREATE POLICY "Helpdesk and Admin can create history" ON public.ticket_history
    FOR INSERT
    WITH CHECK (
        auth.uid()::text IN (
            SELECT id::text FROM public.users WHERE role IN ('helpdesk', 'admin')
        )
    );

-- Notifications: Users can only see their own notifications
CREATE POLICY "Users can view own notifications" ON public.notifications
    FOR SELECT
    USING (user_id::text = auth.uid()::text);

CREATE POLICY "Notifications can be inserted by system" ON public.notifications
    FOR INSERT
    WITH CHECK (true);

CREATE POLICY "Users can update own notifications" ON public.notifications
    FOR UPDATE
    USING (user_id::text = auth.uid()::text);

-- User Profiles
CREATE POLICY "Profiles are viewable by everyone" ON public.user_profiles
    FOR SELECT
    USING (true);

CREATE POLICY "Users can update own profile" ON public.user_profiles
    FOR UPDATE
    USING (id::text = auth.uid()::text);

CREATE POLICY "Users can insert own profile" ON public.user_profiles
    FOR INSERT
    WITH CHECK (id::text = auth.uid()::text);

-- ============================================
-- STORAGE BUCKETS (perlu dibuat manual di Supabase)
-- ============================================
-- 1. 'ticket-attachments' - Untuk upload file lampiran tiket
-- 2. 'avatars' - Untuk upload foto profil

-- ============================================
-- SAMPLE DATA (opsional - untuk testing)
-- ============================================

-- Insert admin user (password: 12345678)
INSERT INTO public.users (id, email, password_hash, name, role) VALUES
    ('123e4567-e89b-12d3-a456-426614174000',
     'admin@eticketing.com',
     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
     'Administrator',
     'admin')
ON CONFLICT (email) DO NOTHING;

-- Insert sample helpdesk users (password: 12345678)
INSERT INTO public.users (id, email, password_hash, name, role) VALUES
    ('123e4567-e89b-12d3-a456-426614174001',
     'helpdesk1@eticketing.com',
     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
     'Helpdesk 1',
     'helpdesk'),
    ('123e4567-e89b-12d3-a456-426614174002',
     'helpdesk2@eticketing.com',
     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
     'Helpdesk 2',
     'helpdesk')
ON CONFLICT (email) DO NOTHING;

-- Insert sample regular user (password: 12345678)
INSERT INTO public.users (id, email, password_hash, name, role) VALUES
    ('123e4567-e89b-12d3-a456-426614174003',
     'user@eticketing.com',
     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
     'Regular User',
     'user')
ON CONFLICT (email) DO NOTHING;
