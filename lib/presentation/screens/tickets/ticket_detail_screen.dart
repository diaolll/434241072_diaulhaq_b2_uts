import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/supabase_service.dart';
import '../../../data/models/ticket_model.dart';
import '../../../data/repositories/ticket_repository.dart';

class TicketDetailScreen extends StatefulWidget {
  final String ticketId;
  const TicketDetailScreen({super.key, required this.ticketId});

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  final _repo = TicketRepository();
  final _commentCtrl = TextEditingController();
  TicketModel? _ticket;
  bool _loading = true;
  bool _submitting = false;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final t = await _repo.getTicketById(widget.ticketId);

      // Ambil role dari SharedPreferences (prioritas, karena sync dari tabel users)
      final prefs = await SharedPreferences.getInstance();
      String? role = prefs.getString('user_role');

      // Fallback ke auth metadata jika SharedPreferences kosong
      if (role == null || role.isEmpty) {
        role = SupabaseService.currentUser?.userMetadata?['role'];
      }

      // Default ke 'user' jika masih kosong
      role ??= 'user';

      // Debug: print role
      print('📋 Ticket loaded: ${t.title}');
      print('👤 User role: $role');
      print('🔧 Is admin/helpdesk: ${role == 'admin' || role == 'helpdesk'}');

      if (mounted) setState(() { _ticket = t; _userRole = role; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool get _isAdmin => _userRole == 'admin' || _userRole == 'helpdesk';

  Future<void> _addComment() async {
    if (_commentCtrl.text.trim().isEmpty) return;
    setState(() => _submitting = true);
    try {
      await _repo.addComment(widget.ticketId, _commentCtrl.text.trim());
      _commentCtrl.clear();
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _updateStatus(String status) async {
    final isDark = context.isDark;
    final noteCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppTheme.dark1 : AppTheme.surface0,
        title: Text('Update ke ${AppTheme.statusLabel(status)}',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: isDark ? AppTheme.white : AppTheme.black)),
        content: TextField(
          controller: noteCtrl,
          style: TextStyle(color: isDark ? AppTheme.white : AppTheme.black, fontSize: 14),
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Catatan (opsional)',
            filled: true,
            fillColor: isDark ? AppTheme.dark2 : AppTheme.surface1,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: isDark ? AppTheme.dark3 : AppTheme.surface2, width: 0.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: isDark ? AppTheme.dark3 : AppTheme.surface2, width: 0.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: isDark ? AppTheme.white : AppTheme.black, width: 1),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal', style: TextStyle(color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Simpan', style: TextStyle(fontWeight: FontWeight.w700, color: isDark ? AppTheme.white : AppTheme.black)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await _repo.updateStatus(widget.ticketId, status, noteCtrl.text.trim());
      await _load();
    }
    noteCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.dark0 : AppTheme.surface1,
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.dark0 : AppTheme.surface1,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, size: 18, color: isDark ? AppTheme.white : AppTheme.black),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _ticket?.ticketNo ?? 'Detail Tiket',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: isDark ? AppTheme.white : AppTheme.black,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, size: 20, color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary),
            onPressed: _load,
          ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: isDark ? AppTheme.white : AppTheme.black, strokeWidth: 2))
          : _ticket == null
              ? Center(child: Text('Tiket tidak ditemukan', style: TextStyle(color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary)))
              : _buildBody(isDark),
    );
  }

  Widget _buildBody(bool isDark) {
    final t = _ticket!;
    return RefreshIndicator(
      onRefresh: _load,
      color: isDark ? AppTheme.white : AppTheme.black,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
        children: [
          // ── Status + Priority badges ──────────────────────────────────
          const SizedBox(height: 12),
          Row(
            children: [
              _Badge(label: AppTheme.statusLabel(t.status), color: AppTheme.statusColor(t.status), bg: AppTheme.statusBgColor(t.status, isDark: isDark)),
              const SizedBox(width: 8),
              _Badge(label: AppTheme.priorityLabel(t.priority), color: AppTheme.priorityColor(t.priority), bg: AppTheme.priorityBgColor(t.priority, isDark: isDark)),
              if (t.category != null) ...[
                const SizedBox(width: 8),
                _Badge(label: t.category!, color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary, bg: isDark ? AppTheme.dark2 : AppTheme.surface2),
              ],
            ],
          ),

          // ── Title ─────────────────────────────────────────────────────
          const SizedBox(height: 16),
          _Card(
            isDark: isDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Judul', style: _subLabel(isDark)),
                const SizedBox(height: 6),
                Text(t.title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: isDark ? AppTheme.white : AppTheme.black, height: 1.3)),
              ],
            ),
          ),

          // ── Description ───────────────────────────────────────────────
          const SizedBox(height: 10),
          _Card(
            isDark: isDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Deskripsi', style: _subLabel(isDark)),
                const SizedBox(height: 6),
                Text(t.description, style: TextStyle(fontSize: 14, color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary, height: 1.6)),
              ],
            ),
          ),

          // ── Info ──────────────────────────────────────────────────────
          const SizedBox(height: 10),
          _Card(
            isDark: isDark,
            child: Column(
              children: [
                _InfoRow('Kategori', t.category ?? '-', isDark),
                Divider(height: 20, color: isDark ? AppTheme.dark3 : AppTheme.surface2, thickness: 0.5),
                _InfoRow('Prioritas', AppTheme.priorityLabel(t.priority), isDark),
                Divider(height: 20, color: isDark ? AppTheme.dark3 : AppTheme.surface2, thickness: 0.5),
                _InfoRow('Dibuat', DateFormat('dd MMM yyyy, HH:mm').format(t.createdAt), isDark),
                Divider(height: 20, color: isDark ? AppTheme.dark3 : AppTheme.surface2, thickness: 0.5),
                _InfoRow('Diperbarui', DateFormat('dd MMM yyyy, HH:mm').format(t.updatedAt), isDark),
              ],
            ),
          ),

          // ── Admin Actions ─────────────────────────────────────────────
          if (_isAdmin) ...[
            const SizedBox(height: 16),
            Text('Update Status', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['open', 'in_progress', 'resolved', 'closed'].map((s) {
                final isCurrent = t.status == s;
                return GestureDetector(
                  onTap: isCurrent ? null : () => _updateStatus(s),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isCurrent ? AppTheme.statusColor(s) : AppTheme.statusBgColor(s, isDark: isDark),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.statusColor(s),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      AppTheme.statusLabel(s),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isCurrent ? AppTheme.white : AppTheme.statusColor(s),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          // ── Attachments ───────────────────────────────────────────────
          if (t.attachments.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text('Lampiran', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary)),
            const SizedBox(height: 10),
            ...t.attachments.map((a) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _AttachmentCard(attachment: a, isDark: isDark),
            )),
          ],

          // ── History / Riwayat ──────────────────────────────────────────
          if (t.history.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text('Riwayat', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary)),
            const SizedBox(height: 10),
            ...t.history.map((h) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _HistoryCard(history: h, isDark: isDark),
            )),
          ],

          // ── Comments ──────────────────────────────────────────────────
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                'Komentar',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.dark2 : AppTheme.surface2,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  '${t.comments.length}',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Comment Input
          _Card(
            isDark: isDark,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentCtrl,
                    maxLines: 4,
                    minLines: 1,
                    style: TextStyle(fontSize: 14, color: isDark ? AppTheme.white : AppTheme.black, height: 1.5),
                    decoration: InputDecoration(
                      hintText: 'Tulis komentar...',
                      hintStyle: TextStyle(fontSize: 14, color: isDark ? AppTheme.textTertiaryDark : AppTheme.textTertiary),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _submitting ? null : _addComment,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.white : AppTheme.black,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: _submitting
                        ? Padding(
                            padding: const EdgeInsets.all(9),
                            child: CircularProgressIndicator(strokeWidth: 2, color: isDark ? AppTheme.black : AppTheme.white),
                          )
                        : Icon(Icons.send_rounded, size: 18, color: isDark ? AppTheme.black : AppTheme.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Comment List
          if (t.comments.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Belum ada komentar',
                  style: TextStyle(fontSize: 13, color: isDark ? AppTheme.textTertiaryDark : AppTheme.textTertiary),
                ),
              ),
            )
          else
            ...t.comments.map((c) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _Card(
                isDark: isDark,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: isDark ? AppTheme.dark3 : AppTheme.surface2,
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Center(
                            child: Text(
                              (c.user?.name.isNotEmpty == true ? c.user!.name[0] : '?').toUpperCase(),
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: isDark ? AppTheme.white : AppTheme.black),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c.user?.name ?? 'Unknown',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: isDark ? AppTheme.white : AppTheme.black),
                              ),
                              Text(
                                DateFormat('dd MMM, HH:mm').format(c.createdAt),
                                style: TextStyle(fontSize: 10, color: isDark ? AppTheme.textTertiaryDark : AppTheme.textTertiary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(c.content, style: TextStyle(fontSize: 13, color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary, height: 1.5)),
                  ],
                ),
              ),
            )),
        ],
      ),
    );
  }

  TextStyle _subLabel(bool isDark) => TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: isDark ? AppTheme.textTertiaryDark : AppTheme.textTertiary,
    letterSpacing: 0.3,
  );
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  final bool isDark;
  const _Card({required this.child, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.dark1 : AppTheme.surface0,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppTheme.dark3 : AppTheme.surface2, width: 0.5),
      ),
      child: child,
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final Color bg;
  const _Badge({required this.label, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  const _InfoRow(this.label, this.value, this.isDark);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary)),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? AppTheme.white : AppTheme.black)),
      ],
    );
  }
}

class _AttachmentCard extends StatelessWidget {
  final dynamic attachment;
  final bool isDark;

  const _AttachmentCard({required this.attachment, required this.isDark});

  bool get _isImage {
    final type = attachment.fileType?.toLowerCase() ?? '';
    return type.startsWith('image/');
  }

  String get _fileName => attachment.fileName ?? 'Attachment';
  String get _fileUrl => attachment.fileUrl ?? '';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (_fileUrl.isNotEmpty) {
          final uri = Uri.parse(_fileUrl);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.dark1 : AppTheme.surface0,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isDark ? AppTheme.dark3 : AppTheme.surface2, width: 0.5),
        ),
        child: Row(
          children: [
            // Thumbnail or icon
            if (_isImage && _fileUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  _fileUrl,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildIcon(),
                ),
              )
            else
              _buildIcon(),
            const SizedBox(width: 12),
            // File info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _fileName,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? AppTheme.white : AppTheme.black),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _isImage ? 'Gambar' : 'Dokumen',
                    style: TextStyle(fontSize: 11, color: isDark ? AppTheme.textTertiaryDark : AppTheme.textTertiary),
                  ),
                ],
              ),
            ),
            Icon(Icons.download_outlined, size: 18, color: isDark ? AppTheme.textTertiaryDark : AppTheme.textTertiary),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.dark2 : AppTheme.surface1,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        _isImage ? Icons.image_outlined : Icons.insert_drive_file_outlined,
        size: 22,
        color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final dynamic history;
  final bool isDark;

  const _HistoryCard({required this.history, required this.isDark});

  @override
  Widget build(BuildContext context) {
    // Handle both Map and HistoryModel
    final oldStatus = history is Map
        ? (history as Map)['old_status'] as String? ?? ''
        : history.oldStatus ?? '';
    final newStatus = history is Map
        ? (history as Map)['new_status'] as String? ?? ''
        : history.newStatus ?? '';
    final note = history is Map
        ? (history as Map)['note'] as String? ?? ''
        : history.note ?? '';
    final user = history is Map
        ? (history as Map)['user']
        : history.user;
    final userName = user is Map
        ? (user as Map)['name'] as String? ?? 'Unknown'
        : (user as dynamic)?.name ?? 'Unknown';
    final createdAt = history is Map
        ? (history as Map)['created_at'] != null
            ? DateTime.parse((history as Map)['created_at'])
            : DateTime.now()
        : history.createdAt ?? DateTime.now();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.dark1 : AppTheme.surface0,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppTheme.dark3 : AppTheme.surface2, width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppTheme.statusBgColor(newStatus, isDark: isDark),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Icon(
                _getStatusIcon(newStatus),
                size: 12,
                color: AppTheme.statusColor(newStatus),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      userName,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? AppTheme.white : AppTheme.black),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatDate(createdAt),
                      style: TextStyle(fontSize: 10, color: isDark ? AppTheme.textTertiaryDark : AppTheme.textTertiary),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (oldStatus.isNotEmpty)
                  Text(
                    'Status: ${AppTheme.statusLabel(oldStatus)} → ${AppTheme.statusLabel(newStatus)}',
                    style: TextStyle(fontSize: 11, color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary),
                  )
                else
                  Text(
                    'Status: ${AppTheme.statusLabel(newStatus)}',
                    style: TextStyle(fontSize: 11, color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary),
                  ),
                if (note.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    note,
                    style: TextStyle(fontSize: 11, color: isDark ? AppTheme.textTertiaryDark : AppTheme.textTertiary, fontStyle: FontStyle.italic),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'resolved': return Icons.check_rounded;
      case 'in_progress': return Icons.pending_rounded;
      case 'closed': return Icons.lock_outline_rounded;
      default: return Icons.inbox_rounded;
    }
  }

  String _formatDate(DateTime d) {
    final now = DateTime.now();
    final diff = now.difference(d);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m lalu';
    if (diff.inHours < 24) return '${diff.inHours}j lalu';
    if (diff.inDays < 7) return '${diff.inDays}h lalu';
    return '${d.day}/${d.month}/${d.year}';
  }
}