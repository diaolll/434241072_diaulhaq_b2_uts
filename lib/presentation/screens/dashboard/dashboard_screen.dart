import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../data/repositories/ticket_repository.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../core/theme/app_theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _ticketRepo = TicketRepository();
  final _authRepo = AuthRepository();
  Map<String, int> _stats = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final stats = await _ticketRepo.getDashboardStats();
      setState(() { _stats = stats; _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.person_outlined),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStats,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Greeting
                  const Text('Selamat Datang 👋', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Ringkasan tiket Anda hari ini', style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(height: 20),

                  // Stats Cards
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: [
                      _StatCard('Total', _stats['total'] ?? 0, Icons.confirmation_number, AppTheme.primary),
                      _StatCard('Open', _stats['open'] ?? 0, Icons.inbox, AppTheme.info),
                      _StatCard('In Progress', _stats['in_progress'] ?? 0, Icons.pending, AppTheme.warning),
                      _StatCard('Resolved', _stats['resolved'] ?? 0, Icons.check_circle, AppTheme.success),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Chart
                  if (_stats.isNotEmpty) ...[
                    const Text('Distribusi Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sections: [
                            PieChartSectionData(value: (_stats['open'] ?? 0).toDouble(), color: AppTheme.info, title: 'Open', radius: 60),
                            PieChartSectionData(value: (_stats['in_progress'] ?? 0).toDouble(), color: AppTheme.warning, title: 'Progress', radius: 60),
                            PieChartSectionData(value: (_stats['resolved'] ?? 0).toDouble(), color: AppTheme.success, title: 'Done', radius: 60),
                            PieChartSectionData(value: (_stats['closed'] ?? 0).toDouble(), color: Colors.grey, title: 'Closed', radius: 60),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),

                  // Quick actions
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/tickets/create'),
                    icon: const Icon(Icons.add),
                    label: const Text('Buat Tiket Baru'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/tickets'),
                    icon: const Icon(Icons.list),
                    label: const Text('Lihat Semua Tiket'),
                    style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                  ),
                ],
              ),
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const _StatCard(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const Spacer(),
            Text('$value', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ],
        ),
      ),
    );
  }
}