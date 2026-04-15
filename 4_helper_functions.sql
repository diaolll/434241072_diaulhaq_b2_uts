-- ============================================
-- HELPER FUNCTIONS FOR E-TICKETING APPLICATION
-- ============================================

-- ============================================
-- FUNCTION: CREATE TICKET WITH HISTORY ENTRY
-- ============================================
CREATE OR REPLACE FUNCTION create_ticket_with_history(
    p_user_id UUID,
    p_title VARCHAR,
    p_description TEXT,
    p_category VARCHAR DEFAULT NULL,
    p_priority VARCHAR DEFAULT 'medium',
    p_assigned_to UUID DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
    v_ticket_id UUID;
BEGIN
    -- Insert ticket
    INSERT INTO public.tickets (
        user_id,
        title,
        description,
        category,
        priority,
        assigned_to
    )
    VALUES (
        p_user_id,
        p_title,
        p_description,
        p_category,
        p_priority,
        p_assigned_to
    )
    RETURNING id INTO v_ticket_id;

    -- Create initial history entry
    INSERT INTO public.ticket_history (
        ticket_id,
        changed_by,
        old_status,
        new_status,
        note
    )
    VALUES (
        v_ticket_id,
        p_user_id,
        NULL,
        'open',
        'Tiket dibuat'
    );

    RETURN v_ticket_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- FUNCTION: UPDATE TICKET STATUS WITH HISTORY
-- ============================================
CREATE OR REPLACE FUNCTION update_ticket_status(
    p_ticket_id UUID,
    p_new_status VARCHAR,
    p_changed_by UUID,
    p_note TEXT DEFAULT NULL
)
RETURNS BOOLEAN AS $$
DECLARE
    v_current_status VARCHAR(20);
BEGIN
    -- Get current status
    SELECT status INTO v_current_status
    FROM public.tickets
    WHERE id = p_ticket_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Ticket not found';

    -- Update ticket status
    UPDATE public.tickets
    SET status = p_new_status
    WHERE id = p_ticket_id;

    -- Create history entry
    INSERT INTO public.ticket_history (
        ticket_id,
        changed_by,
        old_status,
        new_status,
        note
    )
    VALUES (
        p_ticket_id,
        p_changed_by,
        v_current_status,
        p_new_status,
        p_note_note
    );

    -- Create notification for ticket owner
    INSERT INTO public.notifications (
        user_id,
        ticket_id,
        title,
        body,
        type
    )
    SELECT
        user_id,
        p_ticket_id,
        'Status Updated',
        'Tiket Anda: ' || p_new_status,
        'status_update'
    FROM public.tickets
    WHERE id = p_ticket_id;

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- FUNCTION: ASSIGN TICKET
-- ============================================
CREATE OR REPLACE FUNCTION assign_ticket(
    p_ticket_id UUID,
    p_assigned_to UUID,
    p_changed_by UUID
)
RETURNS BOOLEAN AS $$
DECLARE
    v_old_assigned_to UUID;
BEGIN
    -- Get current assignee
    SELECT assigned_to INTO v_old_assigned_to
    FROM public.tickets
    WHERE id = p_ticket_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Ticket not found';

    -- Update ticket
    UPDATE public.tickets
    SET assigned_to = p_assigned_to
    WHERE id = p_ticket_id;

    -- Create history entry
    INSERT INTO public.ticket_history (
        ticket_id,
        changed_by,
        old_status,
        new_status,
        note
    )
    VALUES (
        p_ticket_id,
        p_changed_by,
        status,
        status,
        CASE
            WHEN v_old_assigned_to IS NULL THEN 'Unassigned → ' || (
                SELECT name FROM public.users WHERE id = p_assigned_to
            )
            ELSE (
                SELECT name FROM public.users WHERE id = v_old_assigned_to
            ) || ' → ' ||
            (SELECT name FROM public.users WHERE id = p_assigned_to)
        END
    );

    -- Create notification for new assignee
    INSERT INTO public.notifications (
        user_id,
        ticket_id,
        title,
        body,
        type
    )
    VALUES (
        p_assigned_to,
        p_ticket_id,
        'Tiket Ditugaskan',
        'Anda ditugaskan untuk menangani tiket ini',
        'assigned'
    );

    -- Create notification for ticket owner
    INSERT INTO public.notifications (
        user_id,
        ticket_id,
        title,
        body,
        type
    )
    SELECT
        user_id,
        p_ticket_id,
        'Tiket Ditugaskan',
        'Tiket Anda ditugaskan ke ' || (SELECT name FROM public.users WHERE id = p_assigned_to),
        'assigned'
    FROM public.tickets
    WHERE id = p_ticket_id;

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- FUNCTION: ADD COMMENT WITH NOTIFICATION
-- ============================================
CREATE OR REPLACE FUNCTION add_ticket_comment(
    p_ticket_id UUID,
    p_user_id UUID,
    p_content TEXT,
    p_is_internal BOOLEAN DEFAULT false
)
RETURNS UUID AS $$
DECLARE
    v_comment_id UUID;
BEGIN
    -- Insert comment
    INSERT INTO public.comments (
        ticket_id,
        user_id,
        content,
        is_internal
    )
    VALUES (
        p_ticket_id,
        p_user_id,
        p_content,
        p_is_internal
    )
    RETURNING id INTO v_comment_id;

    -- Create notification for ticket owner (not for internal comments)
    IF NOT p_is_internal THEN
        INSERT INTO public.notifications (
            user_id,
            ticket_id,
            title,
            body,
            type
        )
        SELECT
            user_id,
            p_ticket_id,
            'Komentar Baru',
            LEFT(p_content, 100) || '...',
            'comment'
        FROM public.tickets
        WHERE id = p_ticket_id
        AND user_id != p_user_id; -- Don't notify if comment is by owner
    END IF;

    RETURN v_comment_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- FUNCTION: GET USER DASHBOARD STATS
-- ============================================
CREATE OR REPLACE FUNCTION get_dashboard_stats(p_user_id UUID DEFAULT NULL)
RETURNS JSON AS $$
DECLARE
    v_result JSON;
BEGIN
    SELECT json_build_object(
        'total_tickets', COUNT(*)::INT,
        'open_tickets', COUNT(*) FILTER (WHERE status = 'open')::INT,
        'in_progress_tickets', COUNT(*) FILTER (WHERE status = 'in_progress')::INT,
        'resolved_tickets', COUNT(*) FILTER (WHERE status = 'resolved')::INT,
        'closed_tickets', COUNT(*) FILTER (WHERE status = 'closed')::INT,
        'critical_tickets', COUNT(*) FILTER (WHERE priority = 'critical')::INT,
        'high_tickets', COUNT(*) FILTER (WHERE priority = 'high')::INT,
        'medium_tickets', COUNT(*) FILTER (WHERE priority = 'medium')::INT,
        'low_tickets', COUNT(*) FILTER (WHERE priority = 'low')::INT,
        'my_tickets', COUNT(*) FILTER (WHERE user_id = p_user_id)::INT
    ) INTO v_result
    FROM public.tickets;

    RETURN v_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permissions
GRANT EXECUTE ON FUNCTION create_ticket_with_history TO authenticated;
GRANT EXECUTE ON FUNCTION update_ticket_status TO authenticated;
GRANT EXECUTE ON FUNCTION assign_ticket TO authenticated;
GRANT EXECUTE ON FUNCTION add_ticket_comment TO authenticated;
GRANT EXECUTE ON FUNCTION get_dashboard_stats TO authenticated;

-- ============================================
-- TRIGGER: Auto-create notification on status change
-- ============================================
CREATE OR REPLACE FUNCTION notify_status_change()
RETURNS TRIGGER AS $$
DECLARE
    v_ticket_no VARCHAR(50);
    v_user_id UUID;
    v_new_status VARCHAR(20);
BEGIN
    NEW.ticket_no := OLD.ticket_no;
    v_user_id := OLD.user_id;
    v_new_status := NEW.status;

    -- Only notify if status actually changed
    IF OLD.status IS DISTINCT FROM NEW.status THEN
        INSERT INTO public.notifications (
            user_id,
            ticket_id,
            title,
            body,
            type
        )
        VALUES
        (
            v_user_id,
            NEW.id,
            'Status Diperbarui',
            'Tiket ' || v_ticket_no || ': ' ||
            UPPER(OLD.status) || ' → ' || UPPER(v_new_status),
            'status_update'
        );

        -- Also notify assigned helpdesk if ticket is assigned
        IF NEW.assigned_to IS NOT NULL THEN
            INSERT INTO public.notifications (
                user_id,
                ticket_id,
                title,
                body,
                type
            )
            VALUES
            (
                NEW.assigned_to,
                NEW.id,
                'Status Tiket Diubah',
                'Tiket ' || v_ticket_no || ': ' ||
                UPPER(OLD.status) || ' → ' || UPPER(v_new_status),
                'status_update'
            );
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger for automatic notifications
DROP TRIGGER IF EXISTS notify_status_change_trigger ON public.tickets;
CREATE TRIGGER notify_status_change_trigger
    AFTER UPDATE OF status ON public.tickets
    FOR EACH ROW
    WHEN (OLD.status IS DISTINCT FROM NEW.status)
    EXECUTE FUNCTION notify_status_change();

-- ============================================
-- GRANT PERMISSIONS
-- ============================================

-- Grant access to views
GRANT SELECT ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO anon;

-- Grant usage on sequences
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO authenticated;

-- Grant execute on functions
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO authenticated;
