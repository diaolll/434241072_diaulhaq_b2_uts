import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/models/user_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/supabase_service.dart';

/// Clean Profile Screen - iOS Style
/// No gradients, minimal design
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authRepo = AuthRepository();
  UserModel? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
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
    final isDark = context.isDark;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppTheme.dark1 : AppTheme.surface0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.dark2 : AppTheme.surface1,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.logout_rounded,
                color: AppTheme.priorityHigh,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Keluar?',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: isDark ? AppTheme.white : AppTheme.black),
            ),
          ],
        ),
        content: Text(
          'Anda akan keluar dari akun ini.',
          style: TextStyle(fontSize: 14, color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal', style: TextStyle(color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Keluar', style: TextStyle(color: AppTheme.priorityHigh, fontWeight: FontWeight.w700)),
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
    final isDark = context.isDark;

    if (_loading) {
      return Scaffold(
        backgroundColor: isDark ? AppTheme.dark0 : AppTheme.surface1,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.white : AppTheme.black,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: isDark ? AppTheme.black : AppTheme.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Memuat profil...',
                style: TextStyle(fontSize: 14, color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppTheme.dark0 : AppTheme.surface1,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: isDark ? AppTheme.white : AppTheme.black,
                child: SafeArea(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Avatar
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: isDark ? AppTheme.black : AppTheme.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              _getInitials(_user?.name ?? 'U'),
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppTheme.white : AppTheme.black,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Name
                        Text(
                          _user?.name ?? 'User',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppTheme.black : AppTheme.white,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Email
                        Text(
                          _user?.email ?? '',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppTheme.black.withValues(alpha: 0.7) : AppTheme.white.withValues(alpha: 0.7),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Role Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: isDark ? AppTheme.black.withValues(alpha: 0.2) : AppTheme.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            _getRoleLabel(_user?.role ?? 'user'),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppTheme.black : AppTheme.white,
                              letterSpacing: 0.3,
                            ),
                          ),
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
                  // Account Info Section
                  Text(
                    'Informasi Akun',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppTheme.white : AppTheme.black,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _MenuItem(
                    icon: Icons.person_outline_rounded,
                    title: 'Nama Lengkap',
                    subtitle: _user?.name ?? '-',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 8),
                  _MenuItem(
                    icon: Icons.email_outlined,
                    title: 'Email',
                    subtitle: _user?.email ?? '-',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 8),
                  _MenuItem(
                    icon: Icons.badge_outlined,
                    title: 'Role',
                    subtitle: _getRoleLabel(_user?.role ?? 'user'),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 24),

                  // Settings Section
                  Text(
                    'Pengaturan',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppTheme.white : AppTheme.black,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _MenuAction(
                    icon: Icons.lock_outline,
                    title: 'Ubah Password',
                    isDark: isDark,
                    onTap: () => context.push('/reset-password'),
                  ),
                  const SizedBox(height: 8),
                  _MenuAction(
                    icon: Icons.settings_outlined,
                    title: 'Pengaturan Aplikasi',
                    isDark: isDark,
                    onTap: () => context.push('/settings'),
                  ),
                  const SizedBox(height: 8),
                  _MenuAction(
                    icon: Icons.notifications_outlined,
                    title: 'Notifikasi',
                    isDark: isDark,
                    onTap: () => context.push('/notifications'),
                  ),
                  const SizedBox(height: 32),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: _logout,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.priorityHigh,
                        side: const BorderSide(color: AppTheme.priorityHigh, width: 1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Keluar dari Akun', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Version
                  Center(
                    child: Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppTheme.textTertiaryDark : AppTheme.textTertiary,
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
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDark;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
              color: isDark ? AppTheme.dark2 : AppTheme.surface1,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 18, color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 12, color: isDark ? AppTheme.textTertiaryDark : AppTheme.textTertiary)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? AppTheme.white : AppTheme.black)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isDark;
  final VoidCallback onTap;

  const _MenuAction({
    required this.icon,
    required this.title,
    required this.isDark,
    required this.onTap,
  });

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
                color: isDark ? AppTheme.dark2 : AppTheme.surface1,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, size: 18, color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isDark ? AppTheme.white : AppTheme.black)),
            ),
            Icon(Icons.chevron_right_rounded, size: 18, color: isDark ? AppTheme.textTertiaryDark : AppTheme.textTertiary),
          ],
        ),
      ),
    );
  }
}
