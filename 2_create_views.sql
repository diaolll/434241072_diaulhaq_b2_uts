-- ============================================
-- USEFUL VIEWS FOR E-TICKETING APPLICATION
-- ============================================

-- ============================================
-- VIEW: TICKETS WITH USER INFO
-- ============================================
CREATE OR REPLACE VIEW vw_tickets_details AS
SELECT
    t.id,
    t.ticket_no,
    t.title,
    t.description,
    t.category,
    t.priority,
    t.status,
    t.user_id,
    u_user.name AS user_name,
    u_user.email AS user_email,
    u_user.avatar_url AS user_avatar_url,
    t.assigned_to,
    u_assigned.name AS assigned_to_name,
    u_assigned.email AS assigned_to_email,
    t.created_at,
    t.updated_at,
    -- Counts
    (SELECT COUNT(*) FROM public.comments c WHERE c.ticket_id = t.id) AS comment_count,
    (SELECT COUNT(*) FROM public.ticket_attachments a WHERE a.ticket_id = t.id) AS attachment_count,
    -- Latest status
    (SELECT new_status FROM public.ticket_history th
     WHERE th.ticket_id = t.id
     ORDER BY th.created_at DESC LIMIT 1) AS latest_status
FROM public.tickets t
LEFT JOIN public.users u_user ON t.user_id = u_user.id
LEFT JOIN public.users u_assigned ON t.assigned_to = u_assigned.id;

-- ============================================
-- VIEW: TICKET STATS FOR DASHBOARD
-- ============================================
CREATE OR REPLACE VIEW vw_ticket_stats AS
SELECT
    COUNT(*) AS total_tickets,
    COUNT(*) FILTER (WHERE status = 'open') AS open_tickets,
    COUNT(*) FILTER (WHERE status = 'in_progress') AS in_progress_tickets,
    COUNT(*) FILTER (WHERE status = 'resolved') AS resolved_tickets,
    COUNT(*) FILTER (WHERE status = 'closed') AS closed_tickets,
    COUNT(*) FILTER (WHERE priority = 'critical') AS critical_tickets,
    COUNT(*) FILTER (WHERE priority = 'high') AS high_tickets,
    COUNT(*) FILTER (WHERE priority = 'medium') AS medium_tickets,
    COUNT(*) FILTER (WHERE priority = 'low') AS low_tickets
FROM public.tickets;

-- ============================================
-- VIEW: USER TICKET STATS (per user)
-- ============================================
CREATE OR REPLACE VIEW vw_user_ticket_stats AS
SELECT
    u.id AS user_id,
    u.name AS user_name,
    u.role,
    COUNT(*) AS total_tickets,
    COUNT(*) FILTER (WHERE t.status = 'open') AS open_tickets,
    COUNT(*) FILTER (WHERE t.status = 'in_progress') AS in_progress_tickets,
    COUNT(*) FILTER (WHERE t.status = 'resolved') AS resolved_tickets,
    COUNT(*) FILTER (WHERE t.status = 'closed') AS closed_tickets
FROM public.users u
LEFT JOIN public.tickets t ON t.user_id = u.id
GROUP BY u.id, u.name, u.role;

-- ============================================
-- VIEW: HELPDESK WORKLOAD
-- ============================================
CREATE OR REPLACE VIEW vw_helpdesk_workload AS
SELECT
    u.id AS helpdesk_id,
    u.name AS helpdesk_name,
    COUNT(*) FILTER (WHERE t.status IN ('open', 'in_progress')) AS active_tickets,
    COUNT(*) FILTER (WHERE t.assigned_to = u.id AND t.status = 'resolved') AS resolved_tickets,
    COUNT(*) FILTER (WHERE t.assigned_to = u.id AND t.status = 'closed') AS closed_tickets
FROM public.users u
LEFT JOIN public.tickets t ON t.assigned_to = u.id
WHERE u.role IN ('helpdesk', 'admin')
GROUP BY u.id, u.name;

-- ============================================
-- VIEW: NOTIFICATIONS WITH TICKET INFO
-- ============================================
CREATE OR REPLACE VIEW vw_notifications_details AS
SELECT
    n.id,
    n.user_id,
    n.ticket_id,
    t.ticket_no,
    t.title AS ticket_title,
    t.status AS ticket_status,
    n.title AS notification_title,
    n.body,
    n.type,
    n.is_read,
    n.created_at
FROM public.notifications n
LEFT JOIN public.tickets t ON n.ticket_id = t.id
ORDER BY n.created_at DESC;

-- ============================================
-- VIEW: TICKET TIMELINE (history + comments combined)
-- ============================================
CREATE OR REPLACE VIEW vw_ticket_timeline AS
SELECT
    'history' AS type,
    th.id,
    th.ticket_id,
    th.created_at,
    th.changed_by,
    u_changed.name AS changed_by_name,
    'Status' AS action_type,
    th.old_status || ' → ' || th.new_status AS description,
    th.note
FROM public.ticket_history th
LEFT JOIN public.users u_changed ON th.changed_by = u_changed.id

UNION ALL

SELECT
    'comment' AS type,
    c.id,
    c.ticket_id,
    c.created_at,
    c.user_id AS changed_by,
    u.name AS changed_by_name,
    'Comment' AS action_type,
    c.content AS description,
    NULL AS note
FROM public.comments c
LEFT JOIN public.users u ON c.user_id = u.id
WHERE NOT c.is_internal -- Exclude internal comments

ORDER BY created_at DESC;
