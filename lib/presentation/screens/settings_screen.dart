import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _authRepo = Supabase.instance.client.auth;

  User? _currentUser;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = _authRepo.currentUser;
    setState(() {
      _currentUser = user;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // User info card
                if (_currentUser != null) ...[
                  Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 28,
                        backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                        child: Text(
                          _currentUser!.userMetadata?['name']?.substring(0, 2).toUpperCase() ?? 'U',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                      title: Text(
                        _currentUser!.userMetadata?['name'] ?? 'User',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(_currentUser!.email ?? ''),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => context.push('/profile'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Appearance section
                const SectionHeader(title: 'Tampilan'),
                Card(
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Mode Gelap'),
                        subtitle: Text(isDark ? 'Sedang aktif' : 'Sedang matikan'),
                        value: isDark,
                        onChanged: (value) {
                          // Theme toggle requires theme management setup
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Fitur tema akan segera hadir')),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.palette_outlined),
                        title: const Text('Tema Aplikasi'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Fitur tema akan segera hadir')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Account section
                const SectionHeader(title: 'Akun'),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.lock_outline),
                        title: const Text('Ganti Password'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/reset-password'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.description_outlined),
                        title: const Text('Role'),
                        subtitle: Text(_currentUser?.userMetadata?['role']?.toString().toUpperCase() ?? 'USER'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/profile'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.delete_outline, color: Colors.red),
                        title: const Text('Hapus Akun', style: TextStyle(color: Colors.red)),
                        onTap: () => _showDeleteAccountDialog(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // App info section
                const SectionHeader(title: 'Aplikasi'),
                Card(
                  child: Column(
                    children: [
                      const ListTile(
                        leading: Icon(Icons.info_outline),
                        title: Text('Versi Aplikasi'),
                        subtitle: Text('1.0.0'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.support_agent_outlined),
                        title: const Text('Bantuan'),
                        onTap: () {
                          _showHelpDialog();
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.policy_outlined),
                        title: const Text('Kebijakan Privasi'),
                        onTap: () {
                          _showPrivacyDialog();
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Logout button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.error,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    label: const Text('Keluar', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 32),

                // Copyright
                Center(
                  child: Text(
                    '© 2025 E-Ticketing Helpdesk',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx, true);
              await _authRepo.signOut();
              if (mounted) context.go('/login');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _authRepo.signOut();
      if (mounted) context.go('/login');
    }
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Akun'),
        content: const Text(
          'Tindakan ini akan menghapus akun Anda secara permanen. Apakah Anda yakin?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              // Delete account functionality requires backend API
              Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fitur hapus akun akan segera hadir'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Bantuan'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Cara Menggunakan Aplikasi:\n\n'
                '1. Buat Tiket\n'
                '   - Klik tombol "+" di halaman tiket\n'
                '   - Isi form dan pilih kategori\n'
                '   - Upload lampiran jika perlu\n\n\n'
                '2. Track Tiket\n'
                '   - Lihat daftar tiket di halaman tiket\n'
                '   - Buka detail tiket untuk melihat status\n'
                '   - Tambah komentar untuk komunikasi\n\n\n'
                '3. Dashboard\n'
                '   - Lihat statistik tiket Anda\n'
                '   - Akses fitur cepat\n\n\n'
                '4. Profil & Pengaturan\n'
                '   - Edit profil\n'
                '   - Ganti password\n'
                '   - Atur mode gelap/terang\n',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Mengerti')),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kebijakan Privasi'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Kami menghargai privasi data Anda:\n\n'
                '• Email dan password disimpan aman\n'
                '• Data tiket hanya diakses oleh user yang berwenang\n'
                '• File lampiran dienkripsi dengan aman\n'
                '• Kami tidak akan membagikan data Anda ke pihak ketiga tanpa izin\n\n'
                'Untuk informasi lebih lanjut, hubungi: support@eticketing.com',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Mengerti')),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppTheme.textSecondaryColor,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
