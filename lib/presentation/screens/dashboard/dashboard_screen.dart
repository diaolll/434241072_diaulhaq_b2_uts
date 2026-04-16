import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/providers/providers.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final ticketsState = ref.watch(ticketsProvider);
    final stats = ticketsState.stats;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.dark0 : AppTheme.surface1,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () => ref.read(ticketsProvider.notifier).refresh(),
          color: isDark ? AppTheme.white : AppTheme.black,
          child: CustomScrollView(
            slivers: [
              // ── Header ───────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _greeting(),
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Dashboard',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.8,
                              color: isDark ? AppTheme.white : AppTheme.black,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => context.push('/notifications'),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isDark ? AppTheme.dark2 : AppTheme.surface0,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: isDark ? AppTheme.dark3 : AppTheme.surface2, width: 0.5),
                          ),
                          child: Icon(
                            Icons.notifications_outlined,
                            size: 20,
                            color: isDark ? AppTheme.white : AppTheme.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Stats Cards ───────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: ticketsState.isLoading
                      ? const _StatsShimmer()
                      : _StatsRow(stats: stats, isDark: isDark),
                ),
              ),

              // ── Chart Section ─────────────────────────────────────────────
              if (!ticketsState.isLoading && stats.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: _ChartCard(stats: stats, isDark: isDark),
                  ),
                ),

              // ── Recent Tickets ────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tiket Terbaru',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.3,
                          color: isDark ? AppTheme.white : AppTheme.black,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.push('/tickets'),
                        child: Text(
                          'Lihat Semua',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (ticketsState.isLoading)
                const SliverToBoxAdapter(child: SizedBox(height: 80))
              else if (ticketsState.tickets.isEmpty)
                SliverToBoxAdapter(
                  child: _EmptyDashboard(isDark: isDark),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      final t = ticketsState.tickets[i];
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                        child: _TicketRow(
                          id: t.ticketNo,
                          title: t.title,
                          status: t.status,
                          priority: t.priority,
                          isDark: isDark,
                          onTap: () => context.push('/tickets/${t.id}'),
                        ),
                      );
                    },
                    childCount: (ticketsState.tickets.length).clamp(0, 5),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _BottomBar(
        current: _tab,
        onChanged: (i) {
          setState(() => _tab = i);
          switch (i) {
            case 1: context.push('/tickets'); break;
            case 2: context.push('/notifications'); break;
            case 3: context.push('/profile'); break;
          }
        },
        isDark: isDark,
        onFab: () => context.push('/tickets/create'),
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Selamat Pagi 🌤';
    if (h < 17) return 'Selamat Siang ☀️';
    return 'Selamat Malam 🌙';
  }
}

// ── Stat cards ────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final Map<String, int> stats;
  final bool isDark;
  const _StatsRow({required this.stats, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Total',
                value: '${stats['total'] ?? 0}',
                isDark: isDark,
                accent: isDark ? AppTheme.white : AppTheme.black,
                bg: isDark ? AppTheme.dark2 : AppTheme.surface0,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: 'Open',
                value: '${stats['open'] ?? 0}',
                isDark: isDark,
                accent: AppTheme.statusOpen,
                bg: AppTheme.statusOpenBg,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'In Progress',
                value: '${stats['in_progress'] ?? 0}',
                isDark: isDark,
                accent: AppTheme.statusInProgress,
                bg: AppTheme.statusInProgressBg,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: 'Resolved',
                value: '${stats['resolved'] ?? 0}',
                isDark: isDark,
                accent: AppTheme.statusResolved,
                bg: AppTheme.statusResolvedBg,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;
  final Color bg;
  final bool isDark;
  const _StatCard({required this.label, required this.value, required this.accent, required this.bg, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.dark1 : bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppTheme.dark3 : AppTheme.surface2, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -1,
              color: accent,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? AppTheme.textTertiaryDark : AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsShimmer extends StatelessWidget {
  const _StatsShimmer();

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: List.generate(4, (_) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.dark2 : AppTheme.surface2,
          borderRadius: BorderRadius.circular(14),
        ),
      )),
    );
  }
}

// ── Chart ─────────────────────────────────────────────────────────────────────

class _ChartCard extends StatelessWidget {
  final Map<String, int> stats;
  final bool isDark;
  const _ChartCard({required this.stats, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final total = (stats['open'] ?? 0) + (stats['in_progress'] ?? 0) + (stats['resolved'] ?? 0) + (stats['closed'] ?? 0);
    if (total == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.dark1 : AppTheme.surface0,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppTheme.dark3 : AppTheme.surface2, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Distribusi Status',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDark ? AppTheme.white : AppTheme.black,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 36,
                      sections: [
                        if ((stats['open'] ?? 0) > 0)
                          PieChartSectionData(
                            value: (stats['open'] ?? 0).toDouble(),
                            color: AppTheme.statusOpen,
                            radius: 52,
                            title: '',
                          ),
                        if ((stats['in_progress'] ?? 0) > 0)
                          PieChartSectionData(
                            value: (stats['in_progress'] ?? 0).toDouble(),
                            color: AppTheme.statusInProgress,
                            radius: 52,
                            title: '',
                          ),
                        if ((stats['resolved'] ?? 0) > 0)
                          PieChartSectionData(
                            value: (stats['resolved'] ?? 0).toDouble(),
                            color: AppTheme.statusResolved,
                            radius: 52,
                            title: '',
                          ),
                        if ((stats['closed'] ?? 0) > 0)
                          PieChartSectionData(
                            value: (stats['closed'] ?? 0).toDouble(),
                            color: AppTheme.statusClosed,
                            radius: 52,
                            title: '',
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if ((stats['open'] ?? 0) > 0) _Dot('Open', AppTheme.statusOpen, stats['open']!),
                    if ((stats['in_progress'] ?? 0) > 0) _Dot('In Progress', AppTheme.statusInProgress, stats['in_progress']!),
                    if ((stats['resolved'] ?? 0) > 0) _Dot('Resolved', AppTheme.statusResolved, stats['resolved']!),
                    if ((stats['closed'] ?? 0) > 0) _Dot('Closed', AppTheme.statusClosed, stats['closed']!),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final String label;
  final Color color;
  final int count;
  const _Dot(this.label, this.color, this.count);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            '$label  $count',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: context.isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Ticket Row ────────────────────────────────────────────────────────────────

class _TicketRow extends StatelessWidget {
  final String id;
  final String title;
  final String status;
  final String priority;
  final bool isDark;
  final VoidCallback? onTap;
  const _TicketRow({required this.id, required this.title, required this.status, required this.priority, required this.isDark, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.dark1 : AppTheme.surface0,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isDark ? AppTheme.dark3 : AppTheme.surface2, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.statusBgColor(status, isDark: isDark),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(
                status == 'resolved' ? Icons.check_rounded
                    : status == 'in_progress' ? Icons.pending_rounded
                    : status == 'closed' ? Icons.lock_outline_rounded
                    : Icons.inbox_rounded,
                size: 18,
                color: AppTheme.statusColor(status),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppTheme.white : AppTheme.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '#$id',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppTheme.textTertiaryDark : AppTheme.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _StatusChip(status: status, isDark: isDark),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  final bool isDark;
  const _StatusChip({required this.status, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.statusBgColor(status, isDark: isDark),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        AppTheme.statusLabel(status),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppTheme.statusColor(status),
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}

// ── Empty ─────────────────────────────────────────────────────────────────────

class _EmptyDashboard extends StatelessWidget {
  final bool isDark;
  const _EmptyDashboard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.dark1 : AppTheme.surface0,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? AppTheme.dark3 : AppTheme.surface2, width: 0.5),
        ),
        child: Column(
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 36,
              color: isDark ? AppTheme.textTertiaryDark : AppTheme.textTertiary,
            ),
            const SizedBox(height: 12),
            Text(
              'Belum ada tiket',
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
      ),
    );
  }
}

// ── Bottom Nav ────────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final int current;
  final ValueChanged<int> onChanged;
  final VoidCallback onFab;
  final bool isDark;
  const _BottomBar({required this.current, required this.onChanged, required this.onFab, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.dark1 : AppTheme.surface0,
        border: Border(top: BorderSide(color: isDark ? AppTheme.dark3 : AppTheme.surface2, width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(icon: Icons.grid_view_rounded, label: 'Dashboard', active: current == 0, onTap: () => onChanged(0), isDark: isDark),
              _NavItem(icon: Icons.list_alt_rounded, label: 'Tiket', active: current == 1, onTap: () => onChanged(1), isDark: isDark),
              // FAB center
              GestureDetector(
                onTap: onFab,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.white : AppTheme.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.add_rounded, size: 22, color: isDark ? AppTheme.black : AppTheme.white),
                ),
              ),
              _NavItem(icon: Icons.notifications_outlined, label: 'Notifikasi', active: current == 2, onTap: () => onChanged(2), isDark: isDark),
              _NavItem(icon: Icons.person_outline_rounded, label: 'Profil', active: current == 3, onTap: () => onChanged(3), isDark: isDark),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  final bool isDark;
  const _NavItem({required this.icon, required this.label, required this.active, required this.onTap, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final color = active
        ? (isDark ? AppTheme.white : AppTheme.black)
        : (isDark ? AppTheme.textTertiaryDark : AppTheme.textTertiary);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ignore: non_constant_identifier_names
IconData bell_outlined = Icons.notifications_outlined;