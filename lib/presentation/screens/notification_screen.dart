import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../data/repositories/ticket_repository.dart';
import '../../../core/theme/modern_theme.dart';
import '../widgets/common/loading_shimmer.dart';
import '../widgets/common/empty_state.dart';

/// Modern Notification Screen
/// Features:
/// - Clean notification list
/// - Unread indicators
/// - Mark as read functionality
/// - Navigate to ticket detail
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
      // Update local state
      setState(() {
        final index = _notifications.indexWhere((n) => n['id'] == id);
        if (index >= 0) {
          _notifications[index]['is_read'] = true;
        }
      });
      if (ticketId != null && mounted) {
        context.push('/tickets/$ticketId');
      }
    } catch (_) {}
  }

  Future<void> _markAllAsRead() async {
    for (final notif in _notifications) {
      if (!notif['is_read']) {
        await _ticketRepo.markNotifRead(notif['id']);
      }
    }
    _loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Notifikasi',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: ModernTheme.heroGradient,
                ),
              ),
            ),
            actions: [
              if (_notifications.isNotEmpty)
                TextButton.icon(
                  onPressed: _markAllAsRead,
                  icon: const Icon(Icons.done_all_rounded, color: Colors.white),
                  label: Text(
                    'Tandai Semua',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),

          // Content
          SliverFillRemaining(
            child: _loading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppLoadingIndicator(size: 40, color: ModernTheme.primary),
                        const SizedBox(height: 16),
                        Text(
                          'Memuat notifikasi...',
                          style: GoogleFonts.plusJakartaSans(
                            color: ModernTheme.stone500,
                          ),
                        ),
                      ],
                    ),
                  )
                : _notifications.isEmpty
                    ? EmptyState(
                        title: 'Belum ada notifikasi',
                        subtitle: 'Anda akan menerima notifikasi untuk update tiket',
                        type: EmptyStateType.noNotifications,
                        actionLabel: 'Kembali',
                        onAction: () => context.pop(),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadNotifications,
                        color: ModernTheme.primary,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(20),
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
          ),
        ],
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
    final isDark = context.isDarkMode;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isRead
            ? (isDark ? ModernTheme.surfaceDarkElevated : Colors.white)
            : ModernTheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRead
              ? (isDark ? ModernTheme.stone700.withValues(alpha: 0.5) : ModernTheme.stone200)
              : ModernTheme.primary.withValues(alpha: 0.2),
          width: isRead ? 1 : 2,
        ),
        boxShadow: isRead ? null : ModernTheme.lightShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: isRead
                        ? LinearGradient(
                            colors: [
                              ModernTheme.stone200,
                              ModernTheme.stone100,
                            ],
                          )
                        : ModernTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: isRead
                        ? null
                        : [
                            BoxShadow(
                              color: ModernTheme.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                  child: Icon(
                    _getIcon(title),
                    color: isRead ? ModernTheme.stone600 : Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: isRead ? FontWeight.w600 : FontWeight.w700,
                          fontSize: 15,
                          color: isDark ? ModernTheme.stone100 : ModernTheme.stone800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        body,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: ModernTheme.stone500,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatDate(createdAt),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: ModernTheme.stone400,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Unread indicator
                if (!isRead) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: ModernTheme.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: ModernTheme.primary.withValues(alpha: 0.4),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ],

                // Arrow
                if (ticketId != null) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: ModernTheme.stone400,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIcon(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('tiket') || lower.contains('ticket')) {
      return Icons.confirmation_number_rounded;
    }
    if (lower.contains('komen') || lower.contains('comment') || lower.contains('balas')) {
      return Icons.comment_rounded;
    }
    if (lower.contains('update') || lower.contains('status')) {
      return Icons.update_rounded;
    }
    if (lower.contains('assign') || lower.contains('ditugaskan')) {
      return Icons.person_add_rounded;
    }
    if (lower.contains('selesai') || lower.contains('resolved')) {
      return Icons.check_circle_rounded;
    }
    return Icons.notifications_rounded;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) {
      return 'Baru saja';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} menit lalu';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} jam lalu';
    } else if (diff.inDays == 1) {
      return 'Kemarin, ${DateFormat('HH:mm').format(date)}';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} hari lalu';
    } else {
      return DateFormat('dd MMM yyyy, HH:mm').format(date);
    }
  }
}
