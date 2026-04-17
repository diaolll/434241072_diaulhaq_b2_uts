import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/theme_service.dart';
import '../../../core/services/supabase_service.dart';
import '../../../data/repositories/auth_repository.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _auth = AuthRepository();
  final _theme = ThemeService();
  String? _name, _email, _role;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('user_name');
      _email = prefs.getString('user_email');
      _role = prefs.getString('user_role');
    });
  }

  Future<void> _logout() async {
    final isDark = context.isDark;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppTheme.dark1 : AppTheme.surface0,
        title: Text('Keluar?', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: isDark ? AppTheme.white : AppTheme.black)),
        content: Text('Anda akan keluar dari akun ini.', style: TextStyle(color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Batal', style: TextStyle(color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Keluar', style: TextStyle(color: AppTheme.priorityHigh, fontWeight: FontWeight.w700))),
        ],
      ),
    );
    if (ok == true) {
      await _auth.logout();
      try { await SupabaseService.client.auth.signOut(); } catch (_) {}
      if (mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.dark0 : AppTheme.surface1,
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.dark0 : AppTheme.surface1,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, size: 18, color: isDark ? AppTheme.white : AppTheme.black),
          onPressed: () => context.pop(),
        ),
        title: Text('Pengaturan', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: isDark ? AppTheme.white : AppTheme.black)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
        children: [
          // Profile card
          if (_email != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.dark1 : AppTheme.surface0,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isDark ? AppTheme.dark3 : AppTheme.surface2, width: 0.5),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.dark3 : AppTheme.surface2,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Center(
                      child: Text(
                        (_name?.isNotEmpty == true ? _name![0] : '?').toUpperCase(),
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: isDark ? AppTheme.white : AppTheme.black),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_name ?? 'User', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: isDark ? AppTheme.white : AppTheme.black)),
                        Text(_email ?? '', style: TextStyle(fontSize: 12, color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Tampilan
          _SectionLabel('TAMPILAN', isDark),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.dark1 : AppTheme.surface0,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isDark ? AppTheme.dark3 : AppTheme.surface2, width: 0.5),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.dark2 : AppTheme.surface1,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.dark_mode_outlined, size: 16, color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Mode Gelap', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isDark ? AppTheme.white : AppTheme.black)),
                ),
                AnimatedBuilder(
                  animation: _theme,
                  builder: (_, __) {
                    final on = _theme.themeMode == ThemeMode.dark;
                    return GestureDetector(
                      onTap: () => _theme.toggleTheme(),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 44,
                        height: 24,
                        decoration: BoxDecoration(
                          color: on ? (isDark ? AppTheme.white : AppTheme.black) : (isDark ? AppTheme.dark3 : AppTheme.surface3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: AnimatedAlign(
                          duration: const Duration(milliseconds: 180),
                          alignment: on ? Alignment.centerRight : Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: on ? (isDark ? AppTheme.black : AppTheme.white) : AppTheme.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Akun
          _SectionLabel('AKUN', isDark),
          const SizedBox(height: 8),
          _MenuCard(isDark: isDark, items: [
            _MenuItem(icon: Icons.lock_outline_rounded, label: 'Ganti Password', isDark: isDark, onTap: () => context.push('/reset-password')),
            _MenuItem(icon: Icons.badge_outlined, label: 'Role', value: (_role ?? 'user').toUpperCase(), isDark: isDark),
          ]),
          const SizedBox(height: 20),

          // Aplikasi
          _SectionLabel('APLIKASI', isDark),
          const SizedBox(height: 8),
          _MenuCard(isDark: isDark, items: [
            _MenuItem(icon: Icons.new_releases_outlined, label: 'Versi', value: '1.0.0', isDark: isDark),
            _MenuItem(icon: Icons.help_outline_rounded, label: 'Bantuan', isDark: isDark, onTap: _showHelp),
            _MenuItem(icon: Icons.privacy_tip_outlined, label: 'Kebijakan Privasi', isDark: isDark, onTap: _showPrivacy),
          ]),
          const SizedBox(height: 20),

          // Logout
          GestureDetector(
            onTap: _logout,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.dark1 : AppTheme.surface0,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isDark ? AppTheme.dark3 : AppTheme.surface2, width: 0.5),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(color: const Color(0xFFFFEBEB), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.logout_rounded, size: 16, color: AppTheme.priorityHigh),
                  ),
                  const SizedBox(width: 12),
                  const Text('Keluar dari Akun', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.priorityHigh)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text('© 2024 E-Ticketing Helpdesk', style: TextStyle(fontSize: 11, color: isDark ? AppTheme.textTertiaryDark : AppTheme.textTertiary)),
          ),
        ],
      ),
    );
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Bantuan', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Untuk membuat tiket, tap tombol + di halaman tiket. Isi judul, deskripsi, dan kirim.', style: TextStyle(height: 1.5)),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }

  void _showPrivacy() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Kebijakan Privasi', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Data Anda disimpan aman dan tidak dibagikan ke pihak ketiga.', style: TextStyle(height: 1.5)),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final bool isDark;
  const _SectionLabel(this.text, this.isDark);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: isDark ? AppTheme.textTertiaryDark : AppTheme.textTertiary, letterSpacing: 0.8),
  );
}

class _MenuCard extends StatelessWidget {
  final bool isDark;
  final List<_MenuItem> items;
  const _MenuCard({required this.isDark, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.dark1 : AppTheme.surface0,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppTheme.dark3 : AppTheme.surface2, width: 0.5),
      ),
      child: Column(
        children: List.generate(items.length, (i) => Column(children: [
          items[i],
          if (i < items.length - 1)
            Divider(height: 0, thickness: 0.5, indent: 52, color: isDark ? AppTheme.dark3 : AppTheme.surface2),
        ])),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final bool isDark;
  final VoidCallback? onTap;
  const _MenuItem({required this.icon, required this.label, required this.isDark, this.value, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(color: isDark ? AppTheme.dark2 : AppTheme.surface1, borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, size: 16, color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isDark ? AppTheme.white : AppTheme.black))),
            if (value != null) Text(value!, style: TextStyle(fontSize: 13, color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary)),
            if (onTap != null) Icon(Icons.chevron_right_rounded, size: 18, color: isDark ? AppTheme.textTertiaryDark : AppTheme.textTertiary),
          ],
        ),
      ),
    );
  }
}