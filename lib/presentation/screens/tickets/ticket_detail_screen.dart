import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/models/ticket_model.dart';
import '../../../data/repositories/ticket_repository.dart';
import '../../../core/theme/modern_theme.dart';
import '../../../core/services/supabase_service.dart';
import '../../widgets/common/widgets.dart';
import '../../widgets/common/app_input.dart';

/// Modern Ticket Detail Screen
/// Features:
/// - Complete ticket information display
/// - Status and priority badges
/// - Comment system
/// - Admin actions (update status, assign)
/// - Attachments display
class TicketDetailScreen extends StatefulWidget {
  final String ticketId;
  const TicketDetailScreen({super.key, required this.ticketId});

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen>
    with SingleTickerProviderStateMixin {
  final _repo = TicketRepository();
  final _commentCtrl = TextEditingController();
  final _focusNode = FocusNode();
  TicketModel? _ticket;
  bool _loading = true;
  bool _submittingComment = false;
  String? _userRole;

  late AnimationController _fabController;
  late Animation<double> _fabAnimation;

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

    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.easeOut),
    );
    _fabController.forward();
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    _focusNode.dispose();
    _fabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final ticket = await _repo.getTicketById(widget.ticketId);

      // Try to get role from Supabase first
      final supabaseUser = SupabaseService.currentUser;
      String? role = supabaseUser?.userMetadata?['role'];

      // Fallback to shared preferences
      if (role == null) {
        final prefs = await SharedPreferences.getInstance();
        role = prefs.getString('user_role');
      }

      setState(() {
        _ticket = ticket;
        _userRole = role;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _submitComment() async {
    if (_commentCtrl.text.trim().isEmpty) return;
    setState(() => _submittingComment = true);

    try {
      await _repo.addComment(widget.ticketId, _commentCtrl.text.trim());
      _commentCtrl.clear();
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  'Komentar berhasil ditambahkan',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            backgroundColor: ModernTheme.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Gagal: $e',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: ModernTheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _submittingComment = false);
    }
  }

  Future<void> _updateStatus(String status) async {
    final noteCtrl = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Update Status',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ubah status tiket menjadi ${ModernTheme.getStatusLabel(status)}?',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: ModernTheme.stone600,
              ),
            ),
            const SizedBox(height: 16),
            AppInput(
              controller: noteCtrl,
              label: 'Catatan (opsional)',
              hint: 'Tambahkan catatan untuk perubahan ini',
              type: AppInputType.multiline,
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Batal',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: ModernTheme.stone600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: ModernTheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Simpan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        await _repo.updateStatus(widget.ticketId, status, noteCtrl.text.trim());
        await _load();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(
                    'Status berhasil diperbarui',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              backgroundColor: ModernTheme.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Gagal: $e',
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              backgroundColor: ModernTheme.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      }
    }
    noteCtrl.dispose();
  }

  Future<void> _assignTicket() async {
    final selectedUserId = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Assign Tiket',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _helpdeskUsers.map((user) => ListTile(
            leading: CircleAvatar(
              backgroundColor: ModernTheme.primary.withValues(alpha: 0.1),
              child: Text(
                user['name']![0],
                style: TextStyle(
                  color: ModernTheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            title: Text(user['name']!),
            onTap: () => Navigator.pop(ctx, user['id']),
          )).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Batal',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                color: ModernTheme.stone600,
              ),
            ),
          ),
        ],
      ),
    );

    if (selectedUserId != null) {
      await _repo.assignTicket(widget.ticketId, selectedUserId);
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  'Tiket berhasil diassign',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            backgroundColor: ModernTheme.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  bool get _isAdminOrHelpdesk => _userRole == 'admin' || _userRole == 'helpdesk';

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    if (_loading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppLoadingIndicator(size: 40, color: ModernTheme.primary),
              const SizedBox(height: 16),
              Text(
                'Memuat tiket...',
                style: GoogleFonts.plusJakartaSans(
                  color: ModernTheme.stone500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_ticket == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: ModernTheme.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 48,
                  color: ModernTheme.error,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Tiket tidak ditemukan',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: ModernTheme.stone800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tiket yang Anda cari mungkin telah dihapus',
                style: GoogleFonts.plusJakartaSans(
                  color: ModernTheme.stone500,
                ),
              ),
              const SizedBox(height: 24),
              AppButton(
                text: 'Kembali',
                onPressed: () => context.pop(),
                isFullWidth: false,
              ),
            ],
          ),
        ),
      );
    }

    final t = _ticket!;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _load,
        color: ModernTheme.primary,
        child: CustomScrollView(
          slivers: [
            // Header
            SliverAppBar(
              expandedHeight: 160,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  t.ticketNo,
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
                if (_isAdminOrHelpdesk)
                  IconButton(
                    icon: const Icon(Icons.person_add_rounded, color: Colors.white),
                    onPressed: _assignTicket,
                    tooltip: 'Assign Tiket',
                  ),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                  onPressed: _load,
                  tooltip: 'Refresh',
                ),
              ],
            ),

            // Content
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status & Priority Badges
                    TicketBadges(
                      status: t.status,
                      priority: t.priority,
                      category: t.category,
                    ),
                    const SizedBox(height: 20),

                    // Title Card
                    _buildSectionCard(
                      title: 'Judul Tiket',
                      child: Text(
                        t.title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isDark ? ModernTheme.stone100 : ModernTheme.stone800,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Description Card
                    _buildSectionCard(
                      title: 'Deskripsi',
                      child: Text(
                        t.description,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          color: isDark ? ModernTheme.stone200 : ModernTheme.stone700,
                          height: 1.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Info Grid
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? ModernTheme.surfaceDarkElevated : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark ? ModernTheme.stone700.withValues(alpha: 0.5) : ModernTheme.stone200,
                          width: 1,
                        ),
                        boxShadow: ModernTheme.lightShadow,
                      ),
                      child: Column(
                        children: [
                          _buildInfoRow('Kategori', t.category ?? '-'),
                          const Divider(height: 24),
                          _buildInfoRow('Prioritas', ModernTheme.getPriorityLabel(t.priority)),
                          const Divider(height: 24),
                          _buildInfoRow('Dibuat', DateFormat('dd MMM yyyy, HH:mm').format(t.createdAt)),
                          const Divider(height: 24),
                          _buildInfoRow('Updated', DateFormat('dd MMM yyyy, HH:mm').format(t.updatedAt)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Admin Actions
                    if (_isAdminOrHelpdesk) ...[
                      Row(
                        children: [
                          Text(
                            'Update Status',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: isDark ? ModernTheme.stone100 : ModernTheme.stone800,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.admin_panel_settings_rounded,
                            color: ModernTheme.primary,
                            size: 20,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _buildStatusActionChip('Open', t.status != 'open', ModernTheme.info),
                          _buildStatusActionChip('In Progress', t.status != 'in_progress', ModernTheme.warning),
                          _buildStatusActionChip('Resolved', t.status != 'resolved', ModernTheme.success),
                          _buildStatusActionChip('Closed', t.status != 'closed', ModernTheme.stone400),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Attachments
                    if (t.attachments.isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.attach_file_rounded,
                            color: ModernTheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Lampiran',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: isDark ? ModernTheme.stone100 : ModernTheme.stone800,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: ModernTheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${t.attachments.length}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: ModernTheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...List.generate(t.attachments.length, (i) {
                        final att = t.attachments[i];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? ModernTheme.surfaceDarkElevated : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark ? ModernTheme.stone700.withValues(alpha: 0.5) : ModernTheme.stone200,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: ModernTheme.info.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  _getFileIcon(att.fileName),
                                  color: ModernTheme.info,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      att.fileName,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? ModernTheme.stone100 : ModernTheme.stone800,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      att.fileType.toUpperCase(),
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        color: ModernTheme.stone500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.download_rounded,
                                color: ModernTheme.primary,
                                size: 20,
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 20),
                    ],

                    // Comments Section
                    Row(
                      children: [
                        Icon(
                          Icons.comment_rounded,
                          color: ModernTheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Komentar & Diskusi',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: isDark ? ModernTheme.stone100 : ModernTheme.stone800,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: ModernTheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${t.comments.length}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: ModernTheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Comment Input
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? ModernTheme.surfaceDarkElevated : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _focusNode.hasFocus
                              ? ModernTheme.primary
                              : (isDark ? ModernTheme.stone700.withValues(alpha: 0.5) : ModernTheme.stone200),
                          width: _focusNode.hasFocus ? 2 : 1,
                        ),
                        boxShadow: _focusNode.hasFocus ? ModernTheme.primaryGlow : null,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _commentCtrl,
                              focusNode: _focusNode,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                color: isDark ? ModernTheme.stone100 : ModernTheme.stone800,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Tulis komentar...',
                                hintStyle: GoogleFonts.plusJakartaSans(
                                  color: ModernTheme.stone400,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              maxLines: 4,
                              minLines: 1,
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: _submittingComment ? null : _submitComment,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: _submittingComment
                                    ? null
                                    : ModernTheme.primaryGradient,
                                color: _submittingComment ? ModernTheme.stone300 : null,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: _submittingComment
                                    ? null
                                    : ModernTheme.primaryGlow,
                              ),
                              child: _submittingComment
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.send_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Comments List
                    if (t.comments.isNotEmpty)
                      ...List.generate(t.comments.length, (i) {
                        final comment = t.comments[i];
                        return _CommentTile(comment: comment);
                      })
                    else
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: isDark ? ModernTheme.surfaceDarkElevated : ModernTheme.stone100.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark ? ModernTheme.stone700.withValues(alpha: 0.5) : ModernTheme.stone200,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.comment_outlined,
                              size: 40,
                              color: ModernTheme.stone400,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Belum ada komentar',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                color: ModernTheme.stone500,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Jadilah yang pertama berkomentar',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: ModernTheme.stone400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    final isDark = context.isDarkMode;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? ModernTheme.surfaceDarkElevated : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? ModernTheme.stone700.withValues(alpha: 0.5) : ModernTheme.stone200,
          width: 1,
        ),
        boxShadow: ModernTheme.lightShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: ModernTheme.stone500,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final isDark = context.isDarkMode;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: ModernTheme.stone500,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? ModernTheme.stone100 : ModernTheme.stone800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusActionChip(String label, bool enabled, Color color) {
    final isDark = context.isDarkMode;

    return GestureDetector(
      onTap: enabled ? () => _updateStatus(label.toLowerCase().replaceAll(' ', '_')) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: enabled ? LinearGradient(colors: [color, color.withValues(alpha: 0.8)]) : null,
          color: enabled ? null : (isDark ? ModernTheme.stone700 : ModernTheme.stone200),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: enabled ? color : (isDark ? ModernTheme.stone700 : ModernTheme.stone300),
            width: enabled ? 0 : 1,
          ),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: enabled ? Colors.white : ModernTheme.stone500,
          ),
        ),
      ),
    );
  }

  IconData _getFileIcon(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'doc':
      case 'docx':
        return Icons.description_rounded;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart_rounded;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image_rounded;
      default:
        return Icons.attach_file_rounded;
    }
  }
}

class _CommentTile extends StatelessWidget {
  final CommentModel comment;
  const _CommentTile({required this.comment});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final authorName = comment.user?.name ?? 'Unknown';
    final initial = authorName.isNotEmpty ? authorName[0].toUpperCase() : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? ModernTheme.surfaceDarkElevated : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? ModernTheme.stone700.withValues(alpha: 0.5) : ModernTheme.stone200,
          width: 1,
        ),
        boxShadow: ModernTheme.lightShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: ModernTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      authorName,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: isDark ? ModernTheme.stone100 : ModernTheme.stone800,
                      ),
                    ),
                    Text(
                      DateFormat('dd MMM yyyy, HH:mm').format(comment.createdAt),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: ModernTheme.stone400,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (comment.content.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              comment.content,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: isDark ? ModernTheme.stone200 : ModernTheme.stone700,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
