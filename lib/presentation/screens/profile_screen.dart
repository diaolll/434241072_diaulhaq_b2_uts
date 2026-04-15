import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/models/user_model.dart';
import '../../../core/theme/app_theme.dart';

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
    final role = await _authRepo.getRole();

    // Mock data for demo - in real app, fetch from API
    setState(() {
      _user = UserModel(
        id: userId ?? '1',
        name: 'Demo User',
        email: 'demo@example.com',
        role: role ?? 'user',
        isActive: true,
      );
      _loading = false;
    });
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _authRepo.logout();
      if (mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fitur edit profil belum tersedia')),
              );
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Profile header
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                            child: Text(
                              _user?.name.substring(0, 2).toUpperCase() ?? 'U',
                              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.primary),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _user?.name ?? 'User',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _user?.email ?? '',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          _RoleBadge(_user?.role ?? 'user'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Info cards
                  _InfoCard(
                    icon: Icons.person_outline,
                    title: 'Nama Lengkap',
                    value: _user?.name ?? '-',
                  ),
                  _InfoCard(
                    icon: Icons.email_outlined,
                    title: 'Email',
                    value: _user?.email ?? '-',
                  ),
                  _InfoCard(
                    icon: Icons.badge_outlined,
                    title: 'Role',
                    value: _user?.role.toUpperCase() ?? '-',
                  ),
                  _InfoCard(
                    icon: Icons.verified_user_outlined,
                    title: 'Status',
                    value: _user?.isActive == true ? 'Aktif' : 'Tidak Aktif',
                    valueColor: _user?.isActive == true ? AppTheme.success : Colors.grey,
                  ),
                  const SizedBox(height: 24),

                  // Logout button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout),
                      label: const Text('Keluar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.error,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String role;
  const _RoleBadge(this.role);

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (role.toLowerCase()) {
      case 'admin':
        color = AppTheme.error;
        label = 'Admin';
        break;
      case 'helpdesk':
        color = AppTheme.warning;
        label = 'Helpdesk';
        break;
      default:
        color = AppTheme.info;
        label = 'User';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color? valueColor;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primary),
        title: Text(title, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondaryColor)),
        subtitle: Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: valueColor ?? AppTheme.textPrimaryColor,
          ),
        ),
      ),
    );
  }
}
