import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/ticket_model.dart';
import '../../../data/providers/providers.dart';
import '../../../core/theme/modern_theme.dart';
import '../../widgets/common/widgets.dart';

class TicketListScreen extends ConsumerStatefulWidget {
  const TicketListScreen({super.key});

  @override
  ConsumerState<TicketListScreen> createState() => _TicketListScreenState();
}

class _TicketListScreenState extends ConsumerState<TicketListScreen> {
  final _scrollCtrl = ScrollController();
  final _searchCtrl = TextEditingController();

  // Filter options
  String? _filterStatus;
  String? _filterPriority;
  bool _showFilters = false;

  final List<String> _statusOptions = ['open', 'in_progress', 'resolved', 'closed'];
  final List<String> _priorityOptions = ['low', 'medium', 'high', 'critical'];

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Infinite scroll can be implemented here
  }

  void _clearFilters() {
    setState(() {
      _filterStatus = null;
      _filterPriority = null;
      _searchCtrl.clear();
    });
    ref.read(searchQueryProvider.notifier).state = '';
  }

  bool get _hasActiveFilter => _filterStatus != null || _filterPriority != null || _searchCtrl.text.isNotEmpty;

  List<TicketModel> _getFilteredTickets(List<TicketModel> allTickets) {
    var filtered = allTickets;

    if (_filterStatus != null) {
      filtered = filtered.where((t) => t.status == _filterStatus).toList();
    }

    if (_filterPriority != null) {
      filtered = filtered.where((t) => t.priority == _filterPriority).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final ticketsState = ref.watch(ticketsProvider);
    final allTickets = ticketsState.tickets;
    final filteredTickets = _getFilteredTickets(allTickets);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Tiket'),
        actions: [
          IconButton(
            icon: Icon(_showFilters ? Icons.filter_list_off : Icons.filter_list_rounded),
            onPressed: () => setState(() => _showFilters = !_showFilters),
            tooltip: 'Filter',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Panel
          if (_showFilters)
            _buildFilterPanel()
          else
            _buildSearchBar(),

          // Ticket List
          Expanded(
            child: ticketsState.isLoading
                ? _buildShimmer()
                : RefreshIndicator(
                    onRefresh: () => ref.read(ticketsProvider.notifier).refresh(),
                    color: ModernTheme.primary,
                    backgroundColor: context.isDarkMode ? ModernTheme.surfaceDarkElevated : Colors.white,
                    child: filteredTickets.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            controller: _scrollCtrl,
                            padding: const EdgeInsets.only(bottom: 80),
                            itemCount: filteredTickets.length,
                            itemBuilder: (ctx, i) {
                              return TicketCard(
                                ticketId: filteredTickets[i].ticketNo,
                                title: filteredTickets[i].title,
                                status: filteredTickets[i].status,
                                priority: filteredTickets[i].priority,
                                category: filteredTickets[i].category,
                                createdAt: filteredTickets[i].createdAt,
                                onTap: () => context.push('/tickets/${filteredTickets[i].id}'),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/tickets/create'),
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'Buat Tiket',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: ModernTheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildSearchBar() {
    final isDark = context.isDarkMode;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _searchCtrl,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          color: isDark ? ModernTheme.stone100 : ModernTheme.stone800,
        ),
        decoration: InputDecoration(
          hintText: 'Cari tiket...',
          hintStyle: GoogleFonts.plusJakartaSans(
            color: ModernTheme.stone400,
            fontSize: 15,
          ),
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchCtrl.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchCtrl.clear();
                    _clearFilters();
                  },
                )
              : null,
          filled: true,
          fillColor: isDark ? const Color(0xFF292524) : ModernTheme.stone100.withValues(alpha: 0.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
        onChanged: (value) {
          ref.read(searchQueryProvider.notifier).state = value;
        },
      ),
    );
  }

  Widget _buildFilterPanel() {
    final isDark = context.isDarkMode;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernTheme.primary.withValues(alpha: 0.05),
        border: Border(
          bottom: BorderSide(color: ModernTheme.stone200, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter Tiket',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: isDark ? ModernTheme.stone100 : ModernTheme.stone800,
                ),
              ),
              if (_hasActiveFilter)
                TextButton(
                  onPressed: _clearFilters,
                  child: Text(
                    'Reset Semua',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w600,
                      color: ModernTheme.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Status Filter
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Status',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: isDark ? ModernTheme.stone400 : ModernTheme.stone600,
              ),
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _statusOptions.map((status) {
              final isSelected = _filterStatus == status;
              final statusColor = ModernTheme.getStatusColor(status);
              return InkWell(
                onTap: () => setState(() => _filterStatus = isSelected ? null : status),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? statusColor : (isDark ? ModernTheme.surfaceDarkElevated : Colors.white),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? statusColor : ModernTheme.stone300,
                    ),
                  ),
                  child: Text(
                    ModernTheme.getStatusLabel(status),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : ModernTheme.stone600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          // Priority Filter
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Prioritas',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: isDark ? ModernTheme.stone400 : ModernTheme.stone600,
              ),
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _priorityOptions.map((priority) {
              final isSelected = _filterPriority == priority;
              final priorityColor = ModernTheme.getPriorityColor(priority);
              return InkWell(
                onTap: () => setState(() => _filterPriority = isSelected ? null : priority),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? priorityColor : (isDark ? ModernTheme.surfaceDarkElevated : Colors.white),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? priorityColor : ModernTheme.stone300,
                    ),
                  ),
                  child: Text(
                    ModernTheme.getPriorityLabel(priority),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : ModernTheme.stone600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (_, __) => const TicketCardShimmer(),
    );
  }

  Widget _buildEmptyState() {
    return EmptyState(
      title: _hasActiveFilter ? 'Tidak ada tiket dengan filter ini' : 'Belum ada tiket',
      subtitle: _hasActiveFilter ? 'Coba ubah atau hapus filter' : 'Buat tiket pertama Anda sekarang',
      icon: _hasActiveFilter ? Icons.filter_list_off : Icons.confirmation_number_outlined,
      actionLabel: _hasActiveFilter ? 'Hapus Filter' : 'Buat Tiket',
      onAction: _hasActiveFilter ? _clearFilters : () => context.push('/tickets/create'),
      type: _hasActiveFilter ? EmptyStateType.noSearchResults : EmptyStateType.noTickets,
    );
  }
}
