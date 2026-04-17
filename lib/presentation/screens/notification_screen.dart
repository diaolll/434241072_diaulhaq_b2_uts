import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/ticket_repository.dart';
import '../../../data/providers/providers.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  final _repo = TicketRepository();
  List<dynamic> _notifs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final n = await _repo.getNotifications();
      setState(() { _notifs = n; _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _read(String id, String? ticketId) async {
    try {
      await _repo.markNotifRead(id);
      setState(() {
        final i = _notifs.indexWhere((n) => n['id'] == id);
        if (i >= 0) _notifs[i]['is_read'] = true;
      });
      // Refresh unread count
      ref.read(notificationNotifierProvider.notifier).refresh();
      if (ticketId != null && mounted) context.push('/tickets/$ticketId');
    } catch (_) {}
  }

  Future<void> _readAll() async {
    for (final n in _notifs) {
      if (!(n['is_read'] ?? false)) await _repo.markNotifRead(n['id']);
    }
    await _load();
    // Refresh unread count
    ref.read(notificationNotifierProvider.notifier).refresh();
  }

  String _fmt(String? raw) {
    if (raw == null) return '';
    final d = DateTime.tryParse(raw) ?? DateTime.now();
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m lalu';
    if (diff.inHours < 24) return '${diff.inHours}j lalu';
    if (diff.inDays == 1) return 'Kemarin';
    return DateFormat('dd MMM, HH:mm').format(d);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final unread = _notifs.where((n) => !(n['is_read'] ?? false)).length;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.dark0 : AppTheme.surface1,
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.dark0 : AppTheme.surface1,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, size: 18, color: isDark ? AppTheme.white : AppTheme.black),
          onPressed: () => context.pop(),
        ),
        title: Text('Notifikasi', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: isDark ? AppTheme.white : AppTheme.black)),
        actions: [
          if (unread > 0)
            TextButton(
              onPressed: _readAll,
              child: Text(
                'Baca Semua',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary),
              ),
            ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(strokeWidth: 2, color: isDark ? AppTheme.white : AppTheme.black))
          : _notifs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.notifications_none_outlined, size: 40, color: isDark ? AppTheme.textTertiaryDark : AppTheme.textTertiary),
                      const SizedBox(height: 12),
                      Text('Belum ada notifikasi', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isDark ? AppTheme.white : AppTheme.black)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  color: isDark ? AppTheme.white : AppTheme.black,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                    itemCount: _notifs.length,
                    itemBuilder: (_, i) {
                      final n = _notifs[i];
                      final isRead = n['is_read'] ?? false;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: GestureDetector(
                          onTap: () => _read(n['id'] ?? '', n['ticket_id']),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isDark ? AppTheme.dark1 : AppTheme.surface0,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isRead
                                    ? (isDark ? AppTheme.dark3 : AppTheme.surface2)
                                    : (isDark ? AppTheme.dark4 : AppTheme.surface3),
                                width: isRead ? 0.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: isRead ? (isDark ? AppTheme.dark2 : AppTheme.surface1) : (isDark ? AppTheme.dark3 : AppTheme.surface2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    _icon(n['title'] ?? ''),
                                    size: 18,
                                    color: isRead ? (isDark ? AppTheme.textTertiaryDark : AppTheme.textTertiary) : (isDark ? AppTheme.white : AppTheme.black),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        n['title'] ?? '',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                                          color: isDark ? AppTheme.white : AppTheme.black,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        n['message'] ?? '',
                                        style: TextStyle(fontSize: 12, color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary, height: 1.4),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _fmt(n['created_at']),
                                        style: TextStyle(fontSize: 10, color: isDark ? AppTheme.textTertiaryDark : AppTheme.textTertiary),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (!isRead)
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: BoxDecoration(
                                      color: isDark ? AppTheme.white : AppTheme.black,
                                      shape: BoxShape.circle,
                                    ),
                                  )
                                else if (n['ticket_id'] != null)
                                  Icon(Icons.chevron_right_rounded, size: 16, color: isDark ? AppTheme.textTertiaryDark : AppTheme.textTertiary),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  IconData _icon(String title) {
    final l = title.toLowerCase();
    if (l.contains('tiket') || l.contains('ticket')) return Icons.confirmation_number_outlined;
    if (l.contains('komen') || l.contains('balas')) return Icons.chat_bubble_outline_rounded;
    if (l.contains('status') || l.contains('update')) return Icons.update_rounded;
    if (l.contains('assign')) return Icons.person_add_outlined;
    if (l.contains('selesai') || l.contains('resolved')) return Icons.check_circle_outline_rounded;
    return Icons.notifications_outlined;
  }
}