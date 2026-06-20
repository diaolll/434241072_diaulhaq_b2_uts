import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/user_model.dart';
import '../../../../data/repositories/user_repository.dart';

class UserDetailScreen extends ConsumerStatefulWidget {
  final String userId;

  const UserDetailScreen({super.key, required this.userId});

  @override
  ConsumerState<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends ConsumerState<UserDetailScreen> {
  final _repo = UserRepository();
  UserModel? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final user = await _repo.getUserById(widget.userId);
      if (mounted) setState(() => _user = user);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat user: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
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
        title: Text(
          'Detail Pengguna',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: isDark ? AppTheme.white : AppTheme.black),
        ),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: isDark ? AppTheme.white : AppTheme.black))
          : _user == null
              ? Center(child: Text('User tidak ditemukan', style: TextStyle(color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary)))
              : _buildContent(isDark),
    );
  }

  Widget _buildContent(bool isDark) {
    final user = _user!;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Avatar Card
        _Card(
          isDark: isDark,
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: _getRoleColor(user.role).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    user.initials,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: _getRoleColor(user.role),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                user.name,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: isDark ? AppTheme.white : AppTheme.black),
              ),
              const SizedBox(height: 4),
              Text(
                user.email,
                style: TextStyle(fontSize: 13, color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary),
              ),
            ],
          ),
        ),

        // Info Section
        const SizedBox(height: 16),
        _InfoSection(user: user, isDark: isDark),

        // Role Section
        const SizedBox(height: 16),
        _RoleSection(
          user: user,
          isDark: isDark,
          onRoleChange: (newRole) async {
            try {
              await _repo.updateUserRole(user.id, newRole);
              await _loadUser();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Role berhasil diubah menjadi $newRole')),
                );
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gagal mengubah role: $e')),
                );
              }
            }
          },
        ),

        // Delete Section
        const SizedBox(height: 16),
        _DangerSection(
          user: user,
          isDark: isDark,
          onDelete: () => _showDeleteDialog(user),
        ),
      ],
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return AppTheme.priorityHigh;
      case 'helpdesk':
        return AppTheme.statusInProgress;
      default:
        return AppTheme.statusOpen;
    }
  }

  Future<void> _showDeleteDialog(UserModel user) async {
    final isDark = context.isDark;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppTheme.dark1 : AppTheme.surface0,
        title: Text(
          'Hapus Pengguna',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: isDark ? AppTheme.white : AppTheme.black),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus ${user.name}? Tindakan ini tidak dapat dibatalkan.',
          style: TextStyle(fontSize: 14, color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal', style: TextStyle(color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(backgroundColor: AppTheme.priorityHigh),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _repo.deleteUser(user.id);
        if (mounted) {
          context.pop(); // Go back to list
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${user.name} berhasil dihapus')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menghapus: $e')),
          );
        }
      }
    }
  }
}

// ── Widgets ─────────────────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  final bool isDark;

  const _Card({required this.child, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.dark1 : AppTheme.surface0,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppTheme.dark3 : AppTheme.surface2, width: 0.5),
      ),
      child: child,
    );
  }
}

class _InfoSection extends StatelessWidget {
  final UserModel user;
  final bool isDark;

  const _InfoSection({required this.user, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return _Card(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informasi Pengguna',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary),
          ),
          const SizedBox(height: 12),
          _Row('Role', user.roleLabel, isDark),
          const Divider(height: 20, color: AppTheme.dark3, thickness: 0.5),
          _Row('ID', user.id.substring(0, 8) + '...', isDark),
          const Divider(height: 20, color: AppTheme.dark3, thickness: 0.5),
          _Row('Terdaftar', '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}', isDark),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;

  const _Row(this.label, this.value, this.isDark);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary)),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? AppTheme.white : AppTheme.black)),
      ],
    );
  }
}

class _RoleSection extends StatelessWidget {
  final UserModel user;
  final bool isDark;
  final Function(String) onRoleChange;

  const _RoleSection({required this.user, required this.isDark, required this.onRoleChange});

  @override
  Widget build(BuildContext context) {
    return _Card(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ubah Role',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary),
          ),
          const SizedBox(height: 12),
          ...['user', 'helpdesk', 'admin'].map((role) {
            final isSelected = user.role == role;
            final label = role == 'admin' ? 'Administrator' : role == 'helpdesk' ? 'Helpdesk' : 'Pengguna';

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: isSelected ? null : () => onRoleChange(role),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _getRoleColor(role).withValues(alpha: 0.15)
                        : isDark
                            ? AppTheme.dark2
                            : AppTheme.surface1,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? _getRoleColor(role) : (isDark ? AppTheme.dark3 : AppTheme.surface2),
                      width: isSelected ? 1 : 0.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                        size: 18,
                        color: isSelected ? _getRoleColor(role) : (isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? _getRoleColor(role) : (isDark ? AppTheme.white : AppTheme.black),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return AppTheme.priorityHigh;
      case 'helpdesk':
        return AppTheme.statusInProgress;
      default:
        return AppTheme.statusOpen;
    }
  }
}

class _DangerSection extends StatelessWidget {
  final UserModel user;
  final bool isDark;
  final VoidCallback onDelete;

  const _DangerSection({required this.user, required this.isDark, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return _Card(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Zona Berbahaya',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.priorityHigh),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onDelete,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.priorityHigh.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.priorityHigh, width: 0.5),
              ),
              child: Row(
                children: [
                  Icon(Icons.delete_rounded, size: 18, color: AppTheme.priorityHigh),
                  const SizedBox(width: 10),
                  Text(
                    'Hapus Pengguna',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.priorityHigh),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
