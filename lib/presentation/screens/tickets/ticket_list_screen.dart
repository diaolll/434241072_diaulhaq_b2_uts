import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/ticket_model.dart';
import '../../../data/repositories/ticket_repository.dart';
import '../../../core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class TicketListScreen extends StatefulWidget {
  const TicketListScreen({super.key});

  @override
  State<TicketListScreen> createState() => _TicketListScreenState();
}

class _TicketListScreenState extends State<TicketListScreen> {
  final _repo = TicketRepository();
  final _scrollCtrl = ScrollController();
  final List<TicketModel> _tickets = [];
  bool _loading = true;
  bool _loadingMore = false;
  int _page = 1;
  int _total = 0;
  static const _limit = 10;

  // Filter options
  String? _filterStatus;
  String? _filterPriority;
  String? _filterCategory;
  bool _showFilters = false;

  // User role
  String? _userRole;

  final List<String> _statusOptions = ['open', 'in_progress', 'resolved', 'closed'];
  final List<String> _priorityOptions = ['low', 'medium', 'high', 'critical'];
  final List<String> _categoryOptions = ['Hardware', 'Software', 'Network', 'Email', 'Access', 'Facility', 'HR', 'Finance', 'Lainnya'];

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    _loadTickets();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUserRole() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      // Get user role from user metadata or profiles table
      final role = user.userMetadata?['role'];
      setState(() => _userRole = role);
    }
  }

  bool get _isAdminOrHelpdesk => _userRole == 'admin' || _userRole == 'helpdesk';

  void _onScroll() {
    if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
      if (!_loadingMore && _tickets.length < _total) {
        _loadMore();
      }
    }
  }

  Future<void> _loadTickets() async {
    setState(() { _loading = true; _page = 1; _tickets.clear(); });
    try {
      final res = await _repo.getTickets(page: 1, limit: _limit);
      setState(() {
        _tickets.addAll(res['tickets'] as List<TicketModel>);
        _total = res['total'];
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _loadMore() async {
    setState(() => _loadingMore = true);
    _page++;
    try {
      final res = await _repo.getTickets(page: _page, limit: _limit);
      setState(() {
        _tickets.addAll(res['tickets'] as List<TicketModel>);
        _loadingMore = false;
      });
    } catch (_) {
      setState(() { _loadingMore = false; _page--; });
    }
  }

  void _clearFilters() {
    setState(() {
      _filterStatus = null;
      _filterPriority = null;
      _filterCategory = null;
    });
    _loadTickets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Tiket'),
        actions: [
          if (_isAdminOrHelpdesk)
            IconButton(
              icon: Icon(_showFilters ? Icons.filter_list_off : Icons.filter_list),
              onPressed: () => setState(() => _showFilters = !_showFilters),
              tooltip: 'Filter',
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter Panel
          if (_showFilters && _isAdminOrHelpdesk)
            Container(
              padding: const EdgeInsets.all(16),
              color: AppTheme.primary.withValues(alpha: 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Filter Tiket', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: _clearFilters,
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Status Filter
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      const Text('Status: ', style: TextStyle(fontWeight: FontWeight.w500)),
                      ..._statusOptions.map((status) => FilterChip(
                        label: Text(status.replaceAll('_', ' ').toUpperCase()),
                        selected: _filterStatus == status,
                        onSelected: (v) => setState(() => _filterStatus = v ? status : null),
                        selectedColor: AppTheme.statusColor(status).withValues(alpha: 0.3),
                        checkmarkColor: AppTheme.statusColor(status),
                      )),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Priority Filter
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      const Text('Prioritas: ', style: TextStyle(fontWeight: FontWeight.w500)),
                      ..._priorityOptions.map((priority) => FilterChip(
                        label: Text(priority.toUpperCase()),
                        selected: _filterPriority == priority,
                        onSelected: (v) => setState(() => _filterPriority = v ? priority : null),
                        selectedColor: AppTheme.priorityColor(priority).withValues(alpha: 0.3),
                        checkmarkColor: AppTheme.priorityColor(priority),
                      )),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Category Filter
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      const Text('Kategori: ', style: TextStyle(fontWeight: FontWeight.w500)),
                      ..._categoryOptions.map((category) => FilterChip(
                        label: Text(category),
                        selected: _filterCategory == category,
                        onSelected: (v) => setState(() => _filterCategory = v ? category : null),
                        selectedColor: AppTheme.primary.withValues(alpha: 0.3),
                        checkmarkColor: AppTheme.primary,
                      )),
                    ],
                  ),
                ],
              ),
            ),
          // Ticket List
          Expanded(
            child: _loading
                ? _buildShimmer()
                : RefreshIndicator(
                    onRefresh: _loadTickets,
                    child: _tickets.isEmpty
                        ? _EmptyState(onClear: _filterStatus != null || _filterPriority != null || _filterCategory != null ? _clearFilters : null)
                        : ListView.builder(
                            controller: _scrollCtrl,
                            padding: const EdgeInsets.all(16),
                            itemCount: _tickets.length + (_loadingMore ? 1 : 0),
                            itemBuilder: (ctx, i) {
                              if (i == _tickets.length) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              return _TicketCard(ticket: _tickets[i]);
                            },
                          ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/tickets/create'),
        icon: const Icon(Icons.add),
        label: const Text('Buat Tiket'),
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (_, __) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback? onClear;
  const _EmptyState({this.onClear});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            onClear != null ? 'Tidak ada tiket dengan filter ini' : 'Belum ada tiket',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          if (onClear != null) ...[
            const SizedBox(height: 8),
            TextButton(onPressed: onClear, child: const Text('Hapus Filter')),
          ],
        ],
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final TicketModel ticket;
  const _TicketCard({required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/tickets/${ticket.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      ticket.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _StatusBadge(ticket.status),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                ticket.description,
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(ticket.ticketNo, style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: Colors.blue)),
                  const SizedBox(width: 8),
                  if (ticket.category != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        ticket.category!,
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ),
                  const Spacer(),
                  _PriorityBadge(ticket.priority),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('dd MMM yyyy').format(ticket.createdAt),
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge(this.status);

  String get _label => status.replaceAll('_', ' ').toUpperCase();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.statusColor(status).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _label,
        style: TextStyle(color: AppTheme.statusColor(status), fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  final String priority;
  const _PriorityBadge(this.priority);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.priorityColor(priority).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        priority.toUpperCase(),
        style: TextStyle(color: AppTheme.priorityColor(priority), fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
