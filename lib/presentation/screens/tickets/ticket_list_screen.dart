import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/ticket_model.dart';
import '../../../data/providers/providers.dart';

class TicketListScreen extends ConsumerStatefulWidget {
  const TicketListScreen({super.key});

  @override
  ConsumerState<TicketListScreen> createState() => _TicketListScreenState();
}

class _TicketListScreenState extends ConsumerState<TicketListScreen> {
  final _search = TextEditingController();
  String? _filterStatus;
  String? _filterPriority;
  bool _showFilter = false;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('user_role') ?? 'user';
    if (mounted) setState(() => _userRole = role);
  }

  // Hanya user biasa yang bisa buat tiket
  bool get canCreateTicket => _userRole == 'user';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<TicketModel> _filtered(List<TicketModel> all) {
    var list = all;
    final q = _search.text.toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((t) =>
        t.title.toLowerCase().contains(q) ||
        t.ticketNo.toLowerCase().contains(q) ||
        t.description.toLowerCase().contains(q)
      ).toList();
    }
    if (_filterStatus != null) list = list.where((t) => t.status == _filterStatus).toList();
    if (_filterPriority != null) list = list.where((t) => t.priority == _filterPriority).toList();
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final state = ref.watch(ticketsProvider);
    final list = _filtered(state.tickets);

    return Scaffold(
      backgroundColor: isDark ? AppTheme.dark0 : AppTheme.surface1,
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.dark0 : AppTheme.surface1,
        elevation: 0,
        title: Text(
          'Tiket',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: isDark ? AppTheme.white : AppTheme.black,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, size: 18, color: isDark ? AppTheme.white : AppTheme.black),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showFilter ? Icons.filter_list_off_rounded : Icons.tune_rounded,
              size: 20,
              color: _showFilter
                  ? (isDark ? AppTheme.white : AppTheme.black)
                  : (isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary),
            ),
            onPressed: () => setState(() => _showFilter = !_showFilter),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: _SearchBar(
              controller: _search,
              isDark: isDark,
              onChanged: (_) => setState(() {}),
              onClear: () => setState(() => _search.clear()),
            ),
          ),

          // Filter Panel with smooth animation
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _showFilter
                ? _FilterPanel(
                    isDark: isDark,
                    filterStatus: _filterStatus,
                    filterPriority: _filterPriority,
                    onStatusChanged: (v) => setState(() => _filterStatus = v),
                    onPriorityChanged: (v) => setState(() => _filterPriority = v),
                    onReset: () => setState(() { _filterStatus = null; _filterPriority = null; }),
                  )
                : const SizedBox.shrink(),
          ),

          // List
          Expanded(
            child: state.isLoading
                ? _buildShimmer(isDark)
                : list.isEmpty
                    ? _buildEmpty(isDark)
                    : RefreshIndicator(
                        onRefresh: () => ref.read(ticketsProvider.notifier).refresh(),
                        color: isDark ? AppTheme.white : AppTheme.black,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                          itemCount: list.length,
                          itemBuilder: (_, i) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _TicketCard(
                              ticket: list[i],
                              isDark: isDark,
                              onTap: () => context.push('/tickets/${list[i].id}'),
                            ),
                          ),
                        ),
                      ),
          ),
        ],
      ),
      // FAB hanya untuk role user
      floatingActionButton: canCreateTicket
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/tickets/create'),
              backgroundColor: isDark ? AppTheme.white : AppTheme.black,
              foregroundColor: isDark ? AppTheme.black : AppTheme.white,
              elevation: 0,
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text('Buat Tiket', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            )
          : null,
    );
  }

  Widget _buildShimmer(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      itemCount: 5,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Container(
          height: 86,
          decoration: BoxDecoration(
            color: isDark ? AppTheme.dark1 : AppTheme.surface0,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined, size: 40, color: isDark ? AppTheme.textTertiaryDark : AppTheme.textTertiary),
          const SizedBox(height: 12),
          Text(
            _filterStatus != null || _filterPriority != null || _search.text.isNotEmpty
                ? 'Tidak ada tiket ditemukan'
                : 'Belum ada tiket',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDark ? AppTheme.white : AppTheme.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Buat tiket pertama Anda',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Search Bar ────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  const _SearchBar({required this.controller, required this.isDark, required this.onChanged, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: TextStyle(fontSize: 14, color: isDark ? AppTheme.white : AppTheme.black),
      decoration: InputDecoration(
        hintText: 'Cari tiket...',
        hintStyle: TextStyle(fontSize: 14, color: isDark ? AppTheme.textTertiaryDark : AppTheme.textTertiary),
        prefixIcon: Icon(Icons.search_rounded, size: 18, color: isDark ? AppTheme.textTertiaryDark : AppTheme.textTertiary),
        suffixIcon: controller.text.isNotEmpty
            ? GestureDetector(
                onTap: onClear,
                child: Icon(Icons.close_rounded, size: 16, color: isDark ? AppTheme.textTertiaryDark : AppTheme.textTertiary),
              )
            : null,
        filled: true,
        fillColor: isDark ? AppTheme.dark2 : AppTheme.surface0,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? AppTheme.dark3 : AppTheme.surface2, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? AppTheme.dark3 : AppTheme.surface2, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? AppTheme.white : AppTheme.black, width: 1),
        ),
      ),
    );
  }
}

// ── Filter Panel ──────────────────────────────────────────────────────────────

class _FilterPanel extends StatelessWidget {
  final bool isDark;
  final String? filterStatus;
  final String? filterPriority;
  final ValueChanged<String?> onStatusChanged;
  final ValueChanged<String?> onPriorityChanged;
  final VoidCallback onReset;
  const _FilterPanel({
    required this.isDark,
    required this.filterStatus,
    required this.filterPriority,
    required this.onStatusChanged,
    required this.onPriorityChanged,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.dark1 : AppTheme.surface0,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppTheme.dark3 : AppTheme.surface2, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Filter', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? AppTheme.white : AppTheme.black)),
              GestureDetector(
                onTap: onReset,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.dark2 : AppTheme.surface1,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('Reset', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Status Chips
          Text('Status', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['open', 'in_progress', 'closed'].map((s) {
              final sel = filterStatus == s;
              return _FilterChip(
                label: AppTheme.statusLabel(s),
                isSelected: sel,
                selectedColor: AppTheme.statusColor(s),
                isDark: isDark,
                onTap: () => onStatusChanged(sel ? null : s),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          // Priority Chips
          Text('Prioritas', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['low', 'medium', 'high', 'critical'].map((p) {
              final sel = filterPriority == p;
              return _FilterChip(
                label: AppTheme.priorityLabel(p),
                isSelected: sel,
                selectedColor: AppTheme.priorityColor(p),
                isDark: isDark,
                onTap: () => onPriorityChanged(sel ? null : p),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ── Animated Filter Chip ────────────────────────────────────────────────────────

class _FilterChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final Color selectedColor;
  final bool isDark;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.selectedColor,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_FilterChip> createState() => _FilterChipState();
}

class _FilterChipState extends State<_FilterChip> with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _scaleController.forward().then((_) {
      _scaleController.reverse();
    });
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? widget.selectedColor
                : (widget.isDark ? AppTheme.dark2 : AppTheme.surface1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isSelected
                  ? widget.selectedColor
                  : (widget.isDark ? AppTheme.dark3 : AppTheme.surface2),
              width: widget.isSelected ? 1 : 0.5,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: widget.selectedColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: widget.isSelected
                  ? AppTheme.white
                  : (widget.isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Ticket Card ───────────────────────────────────────────────────────────────

class _TicketCard extends StatelessWidget {
  final TicketModel ticket;
  final bool isDark;
  final VoidCallback? onTap;
  const _TicketCard({required this.ticket, required this.isDark, this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusColor = AppTheme.statusColor(ticket.status);
    final priorityColor = AppTheme.priorityColor(ticket.priority);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.dark1 : AppTheme.surface0,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isDark ? AppTheme.dark3 : AppTheme.surface2, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '#${ticket.ticketNo}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppTheme.textTertiaryDark : AppTheme.textTertiary,
                    letterSpacing: 0.2,
                  ),
                ),
                const Spacer(),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.statusBgColor(ticket.status, isDark: isDark),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    AppTheme.statusLabel(ticket.status),
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: statusColor),
                  ),
                ),
                const SizedBox(width: 6),
                // Priority dot
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(color: priorityColor, shape: BoxShape.circle),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              ticket.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? AppTheme.white : AppTheme.black,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (ticket.category != null) ...[
                  Text(
                    ticket.category!,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppTheme.textTertiaryDark : AppTheme.textTertiary,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: 3,
                    height: 3,
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.textTertiaryDark : AppTheme.textTertiary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
                Text(
                  _ago(ticket.createdAt),
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppTheme.textTertiaryDark : AppTheme.textTertiary,
                  ),
                ),
                const Spacer(),
                if (ticket.comments.isNotEmpty) ...[
                  Icon(Icons.chat_bubble_outline_rounded, size: 11, color: isDark ? AppTheme.textTertiaryDark : AppTheme.textTertiary),
                  const SizedBox(width: 3),
                  Text(
                    '${ticket.comments.length}',
                    style: TextStyle(fontSize: 11, color: isDark ? AppTheme.textTertiaryDark : AppTheme.textTertiary),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _ago(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m lalu';
    if (diff.inHours < 24) return '${diff.inHours}j lalu';
    if (diff.inDays < 7) return '${diff.inDays}h lalu';
    return '${d.day}/${d.month}/${d.year}';
  }
}