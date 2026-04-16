import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../data/providers/providers.dart';
import '../../../../core/theme/modern_theme.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/empty_state.dart';

/// Modern Dashboard Screen
/// Features:
/// - Animated stat cards with staggered entrance
/// - Interactive pie chart with legend
/// - Quick action chips
/// - Smooth refresh indicator
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fabController;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();

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
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ticketsState = ref.watch(ticketsProvider);
    final stats = ticketsState.stats;
    final isDark = context.isDarkMode;

    return Scaffold(
      body: ticketsState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => ref.read(ticketsProvider.notifier).refresh(),
              color: ModernTheme.primary,
              backgroundColor: isDark ? ModernTheme.surfaceDarkElevated : Colors.white,
              child: CustomScrollView(
                slivers: [
                  // Modern App Bar with gradient
                  SliverAppBar(
                    expandedHeight: 140,
                    floating: false,
                    pinned: true,
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    flexibleSpace: FlexibleSpaceBar(
                      titlePadding: const EdgeInsets.only(bottom: 16, left: 20, right: 20),
                      title: AnimatedOpacity(
                        opacity: ticketsState.isLoading ? 0 : 1,
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          'Dashboard',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: ModernTheme.heroGradient,
                        ),
                        child: SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Spacer(),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _getGreeting(),
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white.withValues(alpha: 0.9),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Ringkasan aktivitas tiket Anda',
                                            style: GoogleFonts.outfit(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.notifications_outlined,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Content
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Stats Cards
                          if (stats.isNotEmpty) ...[
                            _buildStatsGrid(stats),
                            const SizedBox(height: 28),

                            // Chart Section
                            _buildChartSection(stats),
                            const SizedBox(height: 28),

                            // Quick Actions
                            _buildQuickActions(),
                          ] else
                            _buildEmptyState(),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildStatsGrid(Map<String, int> stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Statistik Tiket',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: ModernTheme.stone800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.4,
          children: [
            _buildAnimatedStatCard(
              index: 0,
              label: 'Total Tiket',
              value: '${stats['total'] ?? 0}',
              icon: Icons.confirmation_number_rounded,
              gradient: ModernTheme.heroGradient,
              color: ModernTheme.primary,
              delay: 0,
            ),
            _buildAnimatedStatCard(
              index: 1,
              label: 'Open',
              value: '${stats['open'] ?? 0}',
              icon: Icons.inbox_rounded,
              color: ModernTheme.info,
              delay: 100,
            ),
            _buildAnimatedStatCard(
              index: 2,
              label: 'In Progress',
              value: '${stats['in_progress'] ?? 0}',
              icon: Icons.pending_rounded,
              color: ModernTheme.warning,
              delay: 200,
            ),
            _buildAnimatedStatCard(
              index: 3,
              label: 'Resolved',
              value: '${stats['resolved'] ?? 0}',
              icon: Icons.check_circle_rounded,
              color: ModernTheme.success,
              delay: 300,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnimatedStatCard({
    required int index,
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    LinearGradient? gradient,
    required int delay,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.easeOut,
      builder: (context, animation, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - animation)),
          child: Opacity(
            opacity: animation,
            child: StatCard(
              label: label,
              value: value,
              icon: icon,
              color: color,
              gradient: gradient,
              isBig: true,
            ),
          ),
        );
      },
    );
  }

  Widget _buildChartSection(Map<String, int> stats) {
    final total = (stats['open'] ?? 0) +
        (stats['in_progress'] ?? 0) +
        (stats['resolved'] ?? 0) +
        (stats['closed'] ?? 0);

    if (total == 0) {
      return const EmptyState(
        title: 'Belum ada data tiket',
        subtitle: 'Buat tiket pertama Anda untuk melihat statistik',
        type: EmptyStateType.noTickets,
      );
    }

    final isDark = context.isDarkMode;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? ModernTheme.surfaceDarkElevated : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? ModernTheme.stone700.withValues(alpha: 0.5)
              : ModernTheme.stone200.withValues(alpha: 0.6),
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ModernTheme.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.pie_chart_outline_rounded,
                  color: ModernTheme.accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Distribusi Status',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: ModernTheme.stone800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: [
                  if ((stats['open'] ?? 0) > 0)
                    PieChartSectionData(
                      value: (stats['open'] ?? 0).toDouble(),
                      color: ModernTheme.info,
                      title: '${stats['open']}',
                      radius: 70,
                      titleStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  if ((stats['in_progress'] ?? 0) > 0)
                    PieChartSectionData(
                      value: (stats['in_progress'] ?? 0).toDouble(),
                      color: ModernTheme.warning,
                      title: '${stats['in_progress']}',
                      radius: 70,
                      titleStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  if ((stats['resolved'] ?? 0) > 0)
                    PieChartSectionData(
                      value: (stats['resolved'] ?? 0).toDouble(),
                      color: ModernTheme.success,
                      title: '${stats['resolved']}',
                      radius: 70,
                      titleStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  if ((stats['closed'] ?? 0) > 0)
                    PieChartSectionData(
                      value: (stats['closed'] ?? 0).toDouble(),
                      color: ModernTheme.stone400,
                      title: '${stats['closed']}',
                      radius: 70,
                      titleStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              if ((stats['open'] ?? 0) > 0) _buildLegend('Open', ModernTheme.info, stats['open'] ?? 0),
              if ((stats['in_progress'] ?? 0) > 0)
                _buildLegend('In Progress', ModernTheme.warning, stats['in_progress'] ?? 0),
              if ((stats['resolved'] ?? 0) > 0)
                _buildLegend('Resolved', ModernTheme.success, stats['resolved'] ?? 0),
              if ((stats['closed'] ?? 0) > 0)
                _buildLegend('Closed', ModernTheme.stone400, stats['closed'] ?? 0),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(String label, Color color, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$label ($count)',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aksi Cepat',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: ModernTheme.stone800,
          ),
        ),
        const SizedBox(height: 16),
        AppButton(
          text: 'Buat Tiket Baru',
          onPressed: () => context.push('/tickets/create'),
          icon: Icons.add_rounded,
          isGradient: true,
        ),
        const SizedBox(height: 12),
        AppButton(
          text: 'Lihat Semua Tiket',
          onPressed: () => context.push('/tickets'),
          icon: Icons.list_rounded,
          type: AppButtonType.outline,
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: ModernTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ModernTheme.stone200, width: 1),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: ModernTheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.inbox_outlined,
              size: 48,
              color: ModernTheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Belum ada tiket',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: ModernTheme.stone800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Mulai dengan membuat tiket pertama Anda',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: ModernTheme.stone500,
            ),
          ),
          const SizedBox(height: 24),
          AppButton(
            text: 'Buat Tiket',
            onPressed: () => context.push('/tickets/create'),
            icon: Icons.add_rounded,
            isGradient: true,
            isFullWidth: false,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    final isDark = context.isDarkMode;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? ModernTheme.surfaceDark : Colors.white,
        boxShadow: [
          BoxShadow(
            color: ModernTheme.stone900.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.dashboard_outlined,
                activeIcon: Icons.dashboard_rounded,
                label: 'Dashboard',
                index: 0,
              ),
              _buildNavItem(
                icon: Icons.confirmation_number_outlined,
                activeIcon: Icons.confirmation_number_rounded,
                label: 'Tiket',
                index: 1,
              ),
              _buildNavCenterItem(),
              _buildNavItem(
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'Profil',
                index: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final currentIndex = ref.watch(selectedTabProvider);
    final isActive = currentIndex == index;

    return GestureDetector(
      onTap: () {
        ref.read(selectedTabProvider.notifier).state = index;
        switch (index) {
          case 0:
            // Already on dashboard
            break;
          case 1:
            context.push('/tickets');
            break;
          case 2:
            context.push('/profile');
            break;
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? ModernTheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? ModernTheme.primary : ModernTheme.stone400,
              size: 22,
            ),
            if (isActive) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: ModernTheme.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNavCenterItem() {
    return ScaleTransition(
      scale: _fabAnimation,
      child: GestureDetector(
        onTap: () => context.push('/tickets/create'),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: ModernTheme.primaryGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: ModernTheme.primaryGlow,
          ),
          child: const Icon(
            Icons.add_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat Pagi';
    if (hour < 17) return 'Selamat Siang';
    return 'Selamat Malam';
  }
}
