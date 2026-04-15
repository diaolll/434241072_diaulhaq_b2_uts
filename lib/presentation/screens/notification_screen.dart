import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../data/repositories/ticket_repository.dart';
import '../../../core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final _ticketRepo = TicketRepository();
  List<dynamic> _notifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final notifs = await _ticketRepo.getNotifications();
      setState(() {
        _notifications = notifs;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _markAsRead(String id, String? ticketId) async {
    try {
      await _ticketRepo.markNotifRead(id);
      if (ticketId != null && mounted) {
        context.push('/tickets/$ticketId');
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        actions: [
          if (_notifications.isNotEmpty)
            TextButton(
              onPressed: () async {
                // Mark all as read
                for (final notif in _notifications) {
                  if (!notif['is_read']) {
                    await _ticketRepo.markNotifRead(notif['id']);
                  }
                }
                _loadNotifications();
              },
              child: const Text('Tandai Semua'),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadNotifications,
              child: _notifications.isEmpty
                  ? _EmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _notifications.length,
                      itemBuilder: (_, i) {
                        final notif = _notifications[i];
                        return _NotificationTile(
                          id: notif['id'] ?? '',
                          title: notif['title'] ?? '',
                          body: notif['body'] ?? '',
                          isRead: notif['is_read'] ?? false,
                          createdAt: notif['created_at'] != null
                              ? DateTime.parse(notif['created_at'])
                              : DateTime.now(),
                          ticketId: notif['ticket_id'],
                          onTap: () => _markAsRead(
                            notif['id'] ?? '',
                            notif['ticket_id'],
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final String id;
  final String title;
  final String body;
  final bool isRead;
  final DateTime createdAt;
  final String? ticketId;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.id,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
    this.ticketId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isRead ? null : AppTheme.primary.withValues(alpha: 0.05),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isRead ? Colors.grey[300] : AppTheme.primary,
          child: Icon(
            _getIcon(title),
            color: isRead ? Colors.grey[600] : Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
            color: isRead ? AppTheme.textSecondaryColor : AppTheme.textPrimaryColor,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(body, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(
              DateFormat('dd MMM yyyy, HH:mm').format(createdAt),
              style: const TextStyle(fontSize: 11, color: AppTheme.textSecondaryColor),
            ),
          ],
        ),
        trailing: ticketId != null
            ? const Icon(Icons.chevron_right, color: AppTheme.textSecondaryColor)
            : null,
        onTap: onTap,
      ),
    );
  }

  IconData _getIcon(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('tiket') || lower.contains('ticket')) return Icons.confirmation_number;
    if (lower.contains('komen') || lower.contains('comment')) return Icons.comment;
    if (lower.contains('update') || lower.contains('status')) return Icons.update;
    if (lower.contains('assign')) return Icons.person_add;
    return Icons.notifications;
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Belum ada notifikasi',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
