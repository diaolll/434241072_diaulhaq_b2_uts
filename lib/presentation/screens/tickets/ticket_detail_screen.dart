import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/models/ticket_model.dart';
import '../../../data/repositories/ticket_repository.dart';
import '../../../core/theme/app_theme.dart';

class TicketDetailScreen extends StatefulWidget {
  final String ticketId;
  const TicketDetailScreen({super.key, required this.ticketId});

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  final _repo = TicketRepository();
  final _commentCtrl = TextEditingController();
  final _picker = ImagePicker();
  TicketModel? _ticket;
  bool _loading = true;
  String? _userRole;

  // Available helpdesk users for assignment
  final List<Map<String, String>> _helpdeskUsers = [
    {'id': '1', 'name': 'Helpdesk 1'},
    {'id': '2', 'name': 'Helpdesk 2'},
    {'id': '3', 'name': 'Helpdesk 3'},
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final ticket = await _repo.getTicketById(widget.ticketId);
      final role = Supabase.instance.client.auth.currentUser?.userMetadata?['role'];
      setState(() {
        _ticket = ticket;
        _userRole = role;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _submitComment() async {
    if (_commentCtrl.text.isEmpty) return;
    try {
      await _repo.addComment(widget.ticketId, _commentCtrl.text);
      _commentCtrl.clear();
      _load();
    } catch (_) {}
  }

  Future<void> _updateStatus(String status) async {
    final noteCtrl = TextEditingController();
    await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Update ke ${status.replaceAll('_', ' ').toUpperCase()}'),
        content: TextField(
          controller: noteCtrl,
          decoration: const InputDecoration(labelText: 'Catatan (opsional)'),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx, true);
              await _repo.updateStatus(widget.ticketId, status, noteCtrl.text);
              _load();
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> _assignTicket() async {
    final selectedUserId = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Assign Tiket'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _helpdeskUsers.map((user) => ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(user['name']!),
            onTap: () => Navigator.pop(ctx, user['id']),
          )).toList(),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
        ],
      ),
    );

    if (selectedUserId != null) {
      await _repo.assignTicket(widget.ticketId, selectedUserId);
      _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tiket berhasil diassign')),
        );
      }
    }
  }

  Future<void> _pickAndUpload() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    try {
      await _repo.uploadAttachment(widget.ticketId, file.path, file.name);
      _load();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengupload lampiran'), backgroundColor: Colors.red),
        );
      }
    }
  }

  bool get _isAdminOrHelpdesk => _userRole == 'admin' || _userRole == 'helpdesk';

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_ticket == null) return const Scaffold(body: Center(child: Text('Tiket tidak ditemukan')));

    final t = _ticket!;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.ticketNo),
        actions: [
          if (_isAdminOrHelpdesk) ...[
            IconButton(
              icon: const Icon(Icons.person_add),
              onPressed: _assignTicket,
              tooltip: 'Assign Tiket',
            ),
            PopupMenuButton<String>(
              onSelected: _updateStatus,
              icon: const Icon(Icons.more_vert),
              tooltip: 'Update Status',
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'open', child: Text('OPEN')),
                const PopupMenuItem(value: 'in_progress', child: Text('IN PROGRESS')),
                const PopupMenuItem(value: 'resolved', child: Text('RESOLVED')),
                const PopupMenuItem(value: 'closed', child: Text('CLOSED')),
              ],
            ),
          ],
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Ticket info card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _Badge(t.status, AppTheme.statusColor(t.status)),
                      _Badge(t.priority, AppTheme.priorityColor(t.priority)),
                      if (t.category != null) _Badge(t.category!, Colors.grey),
                    ],
                  ),
                  const Divider(height: 24),
                  Text(t.description, style: TextStyle(color: Colors.grey[700])),
                  const SizedBox(height: 12),
                  _InfoRow(Icons.category, t.category ?? 'General'),
                  _InfoRow(Icons.person, t.user?.name ?? 'Unknown'),
                  if (t.assignee != null) _InfoRow(Icons.assignment, t.assignee!.name),
                  _InfoRow(
                    Icons.access_time,
                    DateFormat('dd MMMM yyyy, HH:mm').format(t.createdAt),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Attachments
          if (t.attachments.isNotEmpty) ...[
            const Text('Lampiran', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: t.attachments.length,
                itemBuilder: (_, i) => Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(t.attachments[i].fileUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Timeline/History (FR-010)
          const Text('Riwayat', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...t.history.map((h) => _TimelineItem(history: h)),

          const SizedBox(height: 16),

          // Comments
          const Text('Komentar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (t.comments.isEmpty) Text('Belum ada komentar', style: TextStyle(color: Colors.grey[500])),
          ...t.comments.map((c) => _CommentItem(comment: c)),
          const SizedBox(height: 16),

          // Add comment & upload
          if (_isAdminOrHelpdesk) ...[
            Row(
              children: [
                IconButton(
                  onPressed: _pickAndUpload,
                  icon: const Icon(Icons.attach_file),
                  tooltip: 'Upload lampiran',
                ),
                Expanded(
                  child: TextField(
                    controller: _commentCtrl,
                    decoration: InputDecoration(
                      hintText: 'Tulis komentar...',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send, color: AppTheme.primary),
                        onPressed: _submitComment,
                      ),
                    ),
                    maxLines: 3,
                    minLines: 1,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge(this.label, this.color);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
        child: Text(label.toUpperCase(), style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
      );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow(this.icon, this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [Icon(icon, size: 16, color: Colors.grey[600]), const SizedBox(width: 8), Expanded(child: Text(text, style: TextStyle(color: Colors.grey[700], fontSize: 13)))],
        ),
      );
}

class _TimelineItem extends StatelessWidget {
  final HistoryModel history;
  const _TimelineItem({required this.history});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 12, height: 12,
                  decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                ),
                if (history.note.isNotEmpty) Container(width: 2, height: 40, color: Colors.grey[300]),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${history.oldStatus.toUpperCase()} → ${history.newStatus.toUpperCase()}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  if (history.note.isNotEmpty) Text(history.note, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  Text(
                    DateFormat('dd MMM, HH:mm').format(history.createdAt),
                    style: TextStyle(color: Colors.grey[400], fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _CommentItem extends StatelessWidget {
  final CommentModel comment;
  const _CommentItem({required this.comment});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
              child: Text(
                comment.user?.name.substring(0, 2).toUpperCase() ?? 'U',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(comment.user?.name ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const Spacer(),
                        Text(DateFormat('dd MMM, HH:mm').format(comment.createdAt), style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(comment.content, style: const TextStyle(fontSize: 13)),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
}
