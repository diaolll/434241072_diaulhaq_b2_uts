import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/modern_theme.dart';
import '../../../core/services/theme_service.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../core/services/supabase_service.dart';
import '../widgets/common/widgets.dart';

/// Modern Settings Screen
/// Features:
/// - Theme toggle (dark/light mode)
/// - User profile quick access
/// - Account settings
/// - App info and help
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _authRepo = AuthRepository();
  final _themeService = ThemeService();

  String? _userName;
  String? _userEmail;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    // Try Supabase first
    final supabaseUser = SupabaseService.currentUser;
    if (supabaseUser != null) {
      setState(() {
        _userName = supabaseUser.userMetadata?['name'] ?? supabaseUser.email?.split('@')[0];
        _userEmail = supabaseUser.email;
        _userRole = supabaseUser.userMetadata?['role'] ?? 'user';
      });
      return;
    }

    // Fallback to shared preferences
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userEmail = prefs.getString('user_email');
      _userRole = prefs.getString('user_role');
      _userName = prefs.getString('user_name');
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

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: ModernTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.help_outline, color: ModernTheme.primary),
            ),
            const SizedBox(width: 12),
            Text(
              'Panduan Penggunaan',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _HelpItem(
                icon: Icons.add_circle_outline,
                title: 'Membuat Tiket Baru',
                description: 'Klik tombol "+" di halaman tiket, isi judul, deskripsi, pilih kategori dan prioritas',
                color: ModernTheme.primary,
              ),
              _HelpItem(
                icon: Icons.list_alt,
                title: 'Melihat Daftar Tiket',
                description: 'Lihat semua tiket Anda di halaman tiket, filter berdasarkan status dan prioritas',
                color: ModernTheme.info,
              ),
              _HelpItem(
                icon: Icons.search,
                title: 'Detail & Status Tiket',
                description: 'Buka detail tiket untuk melihat perkembangan dan berkomunikasi dengan helpdesk',
                color: ModernTheme.warning,
              ),
              _HelpItem(
                icon: Icons.bar_chart,
                title: 'Dashboard Statistik',
                description: 'Pantau statistik tiket Anda di dashboard - total tiket, open, in progress, dan resolved',
                color: ModernTheme.success,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Mengerti',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: ModernTheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: ModernTheme.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.security, color: ModernTheme.success),
            ),
            const SizedBox(width: 12),
            Text(
              'Kebijakan Privasi',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _PrivacyItem(
                icon: Icons.lock,
                text: 'Data login Anda disimpan aman dengan enkripsi',
              ),
              _PrivacyItem(
                icon: Icons.verified_user,
                text: 'Tiket hanya dapat diakses oleh Anda dan tim helpdesk',
              ),
              _PrivacyItem(
                icon: Icons.cloud_upload,
                text: 'File lampiran dienkripsi dan disimpan di cloud',
              ),
              _PrivacyItem(
                icon: Icons.block,
                text: 'Data tidak dibagikan ke pihak ketiga tanpa izin',
              ),
              _PrivacyItem(
                icon: Icons.update,
                text: 'Anda dapat memperbarui atau menghapus data kapan saja',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Mengerti',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: ModernTheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 140,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Pengaturan',
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
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Profile Card
                  if (_userEmail != null)
                    ProfileCard(
                      name: _userName ?? 'User',
                      email: _userEmail ?? '',
                      role: _userRole?.toUpperCase(),
                      onTap: () => context.push('/profile'),
                      initials: _userName?.isNotEmpty == true
                          ? '${_userName![0].toUpperCase()}'
                          : 'U',
                    ),
                  const SizedBox(height: 24),

                  // Appearance Section
                  _SectionHeader(
                    title: 'Tampilan',
                    icon: Icons.palette_outlined,
                  ),
                  AppCard(
                    type: AppCardType.filled,
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        AnimatedBuilder(
                          animation: _themeService,
                          builder: (context, child) {
                            final isDark = _themeService.themeMode == ThemeMode.dark;
                            return AppSwitch(
                              label: 'Mode Gelap',
                              subtitle: isDark ? 'Sedang aktif' : 'Sedang nonaktif',
                              value: isDark,
                              onChanged: (value) {
                                _themeService.toggleTheme();
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Account Section
                  _SectionHeader(
                    title: 'Akun',
                    icon: Icons.person_outline,
                  ),
                  AppCard(
                    type: AppCardType.filled,
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        MenuItemCard(
                          icon: Icons.lock_outline_rounded,
                          title: 'Ganti Password',
                          onTap: () => context.push('/reset-password'),
                        ),
                        const Divider(height: 1),
                        MenuItemCard(
                          icon: Icons.badge_outlined,
                          title: 'Role',
                          subtitle: _userRole?.toUpperCase() ?? 'USER',
                          showArrow: false,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // App Info Section
                  _SectionHeader(
                    title: 'Aplikasi',
                    icon: Icons.info_outline,
                  ),
                  AppCard(
                    type: AppCardType.filled,
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        MenuItemCard(
                          icon: Icons.new_releases_outlined,
                          title: 'Versi Aplikasi',
                          subtitle: '1.0.0',
                          showArrow: false,
                        ),
                        const Divider(height: 1),
                        MenuItemCard(
                          icon: Icons.help_outline_rounded,
                          title: 'Bantuan & Panduan',
                          onTap: _showHelpDialog,
                        ),
                        const Divider(height: 1),
                        MenuItemCard(
                          icon: Icons.privacy_tip_outlined,
                          title: 'Kebijakan Privasi',
                          onTap: _showPrivacyDialog,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Logout Button
                  AppButton(
                    text: 'Keluar dari Akun',
                    onPressed: _logout,
                    type: AppButtonType.danger,
                    icon: Icons.logout_rounded,
                  ),
                  const SizedBox(height: 32),

                  // Copyright
                  Center(
                    child: Text(
                      '© 2024 E-Ticketing Helpdesk',
                      style: GoogleFonts.plusJakartaSans(
                        color: ModernTheme.stone400,
                        fontSize: 12,
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

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ModernTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 18,
              color: ModernTheme.primary,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title.toUpperCase(),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDark ? ModernTheme.stone400 : ModernTheme.stone600,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _HelpItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? ModernTheme.stone100 : ModernTheme.stone800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: ModernTheme.stone500,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrivacyItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _PrivacyItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ModernTheme.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 18,
              color: ModernTheme.success,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: isDark ? ModernTheme.stone300 : ModernTheme.stone600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
