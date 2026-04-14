import 'package:flutter/material.dart';
import '../../../data/models/ticket_model.dart';
import '../../../data/repositories/ticket_repository.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../core/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class TicketDetailScreen extends StatefulWidget {
  final String ticketId;
  const TicketDetailScreen({super.key, required this.ticketId});

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  final _repo = TicketRepository();
  final _authRepo = AuthRepository();
  final _commentCtrl = TextEditingController();
  TicketModel? _ticket;
  bool _loading = true;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final ticket = await _repo.getTicketById(widget.ticketId);
      final role = await _authRepo.getRole();
      setState(() { _ticket = ticket; _userRole = role; _loading = false; });
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
    await showDialog(
      context: context,
      builder: (ctx) {
        final noteCtrl = TextEditingController();
        return AlertDialog(
          title: const Text('Update Status'),
          content: TextField(
            controller: noteCtrl,
            decoration: const InputDecoration(labelText: 'Catatan (opsional)'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await _repo.updateStatus(widget.ticketId, status, noteCtrl.text);
                _load();
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickAndUpload() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    try {
      await _repo.uploadAttachment(widget.ticketId, file.path, file.name);
      _load();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_ticket == null) return const Scaffold(body: Center(child: Text('Tiket tidak ditemukan')));

    final t = _ticket!;
    final isStaff = _userRole == 'admin' || _userRole == 'helpdesk';

    return Scaffold(
      appBar: AppBar(
        title: Text(t.ticketNo),
        actions: [
          if (isStaff)
            PopupMenuButton<String>(
              onSelected: _updateStatus,
              itemBuilder: (_) => ['open', 'in_progress', 'resolved', 'closed']
                  .map((s) => PopupMenuItem(value: s, child: Text(s.replaceAll('_', ' ').toUpperCase())))
                  .toList(),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Row(children: [Text('Update Status'), Icon(Icons.arrow_drop_down)]),
              ),
            ),
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
                  Row(
                    children: [
                      _Badge(t.status, AppTheme.statusColor(t.status)),
                      const SizedBox(width: 8),
                      _Badge(t.priority, AppTheme.priorityColor(t.priority)),
                    ],
                  ),
                  const Divider(height: 24),
                  Text(t.description, style: TextStyle(color: Colors.grey[700])),
                  if (t.category != null) ...[
                    const SizedBox(height: 12),
                    Text('Kategori: ${t.category}', style: const TextStyle(fontWeight: FontWeight.w500)),
                  ],
                  const SizedBox(height: 12),
                  Text(
                    'Dibuat: ${DateFormat('dd MMMM yyyy HH:mm').format(t.createdAt)}',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                  if (t.assignee != null) ...[
                    const SizedBox(height: 4),
                    Text('Ditangani: ${t.assignee!.name}', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  ],
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

          // Timeline/History
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
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge(this.label, this.color);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
        child: Text(label.toUpperCase(), style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
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
                Container(width: 2, height: 30, color: Colors.grey[300]),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    history.newStatus.replaceAll('_', ' ').toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  if (history.note.isNotEmpty)
                    Text(history.note, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  Text(
                    'oleh ${history.user?.name ?? '-'} · ${DateFormat('dd MMM yyyy HH:mm').format(history.createdAt)}',
                    style: TextStyle(color: Colors.grey[500], fontSize: 11),
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
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  child: Text(comment.user?.name[0] ?? '?'),
                ),
                const SizedBox(width: 8),
                Text(comment.user?.name ?? '-', style: const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                Text(
                  DateFormat('dd MMM HH:mm').format(comment.createdAt),
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(comment.content),
          ],
        ),
      );
}