import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/models/user_model.dart';
import '../../../core/theme/modern_theme.dart';
import '../../../core/services/supabase_service.dart';
import '../widgets/common/widgets.dart';

/// Modern Profile Screen
/// Features:
/// - Clean profile header with gradient
/// - User info display
/// - Quick actions
/// - Logout confirmation
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final _authRepo = AuthRepository();
  UserModel? _user;
  bool _loading = true;

  late AnimationController _headerController;
  late Animation<double> _headerAnimation;

  @override
  void initState() {
    super.initState();

    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _headerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOut),
    );

    _headerController.forward();
    _loadUser();
  }

  @override
  void dispose() {
    _headerController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    // Try to get user from Supabase first
    final supabaseUser = SupabaseService.currentUser;
    if (supabaseUser != null) {
      setState(() {
        _user = UserModel(
          id: supabaseUser.id,
          name: supabaseUser.userMetadata?['name'] ?? supabaseUser.email?.split('@')[0] ?? 'User',
          email: supabaseUser.email ?? '',
          role: supabaseUser.userMetadata?['role'] ?? 'user',
          createdAt: supabaseUser.createdAt ?? DateTime.now(),
        );
        _loading = false;
      });
      return;
    }

    // Fallback to shared preferences
    final userId = await _authRepo.getUserId();
    final name = await _authRepo.getUserName();
    final email = await _authRepo.getUserEmail();
    final role = await _authRepo.getRole();

    setState(() {
      _user = UserModel(
        id: userId ?? '1',
        name: name ?? 'Demo User',
        email: email ?? 'demo@example.com',
        role: role ?? 'user',
        createdAt: DateTime.now(),
      );
      _loading = false;
    });
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ModernTheme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.logout_rounded,
                color: ModernTheme.error,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Konfirmasi Keluar',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin keluar dari akun?',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            color: ModernTheme.stone600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
              backgroundColor: ModernTheme.error,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Keluar',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _authRepo.logout();
      await SupabaseService.client.auth.signOut();
      if (mounted) context.go('/login');
    }
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return ModernTheme.error;
      case 'helpdesk':
        return ModernTheme.warning;
      default:
        return ModernTheme.primary;
    }
  }

  String _getRoleLabel(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'Administrator';
      case 'helpdesk':
        return 'Helpdesk Staff';
      default:
        return 'User';
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    if (_loading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: ModernTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: ModernTheme.primaryGlow,
                ),
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Memuat profil...',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  color: ModernTheme.stone500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 240,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: ModernTheme.heroGradient,
                ),
                child: SafeArea(
                  child: FadeTransition(
                    opacity: _headerAnimation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.1),
                        end: Offset.zero,
                      ).animate(_headerAnimation),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Avatar
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withValues(alpha: 0.3),
                                    Colors.white.withValues(alpha: 0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  _getInitials(_user?.name ?? 'U'),
                                  style: GoogleFonts.outfit(
                                    fontSize: 40,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Name
                            Text(
                              _user?.name ?? 'User',
                              style: GoogleFonts.outfit(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),

                            // Email
                            Text(
                              _user?.email ?? '',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Role Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.badge_rounded,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _getRoleLabel(_user?.role ?? 'user'),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
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
                  // Stats Section
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.confirmation_number_rounded,
                          label: 'Total Tiket',
                          value: '0',
                          color: ModernTheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.pending_rounded,
                          label: 'Open',
                          value: '0',
                          color: ModernTheme.warning,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Account Info Section
                  Text(
                    'Informasi Akun',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark ? ModernTheme.stone100 : ModernTheme.stone800,
                    ),
                  ),
                  const SizedBox(height: 16),

                  MenuItemCard(
                    icon: Icons.person_outline_rounded,
                    title: 'Nama Lengkap',
                    subtitle: _user?.name ?? '-',
                    showArrow: false,
                  ),
                  MenuItemCard(
                    icon: Icons.email_outlined,
                    title: 'Email',
                    subtitle: _user?.email ?? '-',
                    showArrow: false,
                  ),
                  MenuItemCard(
                    icon: Icons.verified_user_outlined,
                    title: 'Status Akun',
                    subtitle: 'Aktif',
                    iconColor: ModernTheme.success,
                    showArrow: false,
                  ),
                  const SizedBox(height: 24),

                  // Settings Section
                  Text(
                    'Pengaturan',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark ? ModernTheme.stone100 : ModernTheme.stone800,
                    ),
                  ),
                  const SizedBox(height: 16),

                  MenuItemCard(
                    icon: Icons.edit_outlined,
                    title: 'Edit Profil',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.info_outline, color: Colors.white),
                              const SizedBox(width: 12),
                              Text(
                                'Fitur edit profil belum tersedia',
                                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          backgroundColor: ModernTheme.info,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.all(16),
                        ),
                      );
                    },
                  ),
                  MenuItemCard(
                    icon: Icons.lock_outline,
                    title: 'Ubah Password',
                    onTap: () => context.push('/reset-password'),
                  ),
                  MenuItemCard(
                    icon: Icons.settings_outlined,
                    title: 'Pengaturan Aplikasi',
                    onTap: () => context.push('/settings'),
                  ),
                  MenuItemCard(
                    icon: Icons.notifications_outlined,
                    title: 'Notifikasi',
                    onTap: () => context.push('/notifications'),
                  ),
                  const SizedBox(height: 32),

                  // Logout Button
                  AppButton(
                    text: 'Keluar dari Akun',
                    onPressed: _logout,
                    type: AppButtonType.danger,
                    icon: Icons.logout_rounded,
                  ),
                  const SizedBox(height: 32),

                  // Version
                  Center(
                    child: Text(
                      'Version 1.0.0',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: ModernTheme.stone400,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final isDark = context.isDarkMode;

    return Container(
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
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: ModernTheme.stone500,
            ),
          ),
        ],
      ),
    );
  }
}
