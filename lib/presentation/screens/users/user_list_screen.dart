import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/user_model.dart';
import '../../../../data/repositories/user_repository.dart';

// Provider untuk user list
final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier(UserRepository());
});

class UserState {
  final List<UserModel> users;
  final bool isLoading;
  final String? error;
  final Map<String, int> roleCounts;

  UserState({
    this.users = const [],
    this.isLoading = false,
    this.error,
    this.roleCounts = const {},
  });

  UserState copyWith({
    List<UserModel>? users,
    bool? isLoading,
    String? error,
    Map<String, int>? roleCounts,
  }) {
    return UserState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      roleCounts: roleCounts ?? this.roleCounts,
    );
  }
}

class UserNotifier extends StateNotifier<UserState> {
  final UserRepository _repo;

  UserNotifier(this._repo) : super(UserState()) {
    loadUsers();
  }

  Future<void> loadUsers() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final users = await _repo.getAllUsers();
      final counts = await _repo.getUsersCountByRole();
      state = state.copyWith(users: users, isLoading: false, roleCounts: counts);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setSearchResults(List<UserModel> results) {
    final currentCounts = state.roleCounts;
    state = UserState(
      users: results,
      isLoading: false,
      roleCounts: currentCounts,
    );
  }

  Future<void> updateUserRole(String userId, String newRole) async {
    try {
      await _repo.updateUserRole(userId, newRole);
      await loadUsers(); // Refresh
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _repo.deleteUser(userId);
      await loadUsers(); // Refresh
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

class UserListScreen extends ConsumerStatefulWidget {
  const UserListScreen({super.key});

  @override
  ConsumerState<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends ConsumerState<UserListScreen> {
  final _repo = UserRepository();
  final _searchCtrl = TextEditingController();
  String _userRole = '';
  bool _checkingRole = true;

  @override
  void initState() {
    super.initState();
    _checkRole();
  }

  Future<void> _checkRole() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('user_role') ?? 'user';
    print('🔍 Current role from prefs: $role');
    if (mounted) setState(() => _userRole = role);

    // Redirect if not admin
    if (role != 'admin' && mounted) {
      setState(() => _checkingRole = false);
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Akses ditolak: Hanya admin yang dapat mengakses halaman ini')),
      );
    } else {
      if (mounted) setState(() => _checkingRole = false);
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final userState = ref.watch(userProvider);

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
          'Kelola Pengguna',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: isDark ? AppTheme.white : AppTheme.black),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, size: 20, color: isDark ? AppTheme.white : AppTheme.black),
            onPressed: () => ref.read(userProvider.notifier).loadUsers(),
          ),
          IconButton(
            icon: Icon(Icons.person_add_rounded, size: 20, color: isDark ? AppTheme.white : AppTheme.black),
            onPressed: () => _showCreateUserDialog(),
          ),
        ],
      ),
      body: _checkingRole
          ? Center(child: CircularProgressIndicator(color: isDark ? AppTheme.white : AppTheme.black))
          : _userRole != 'admin'
          ? _buildAccessDenied(isDark)
          : Column(
              children: [
                // Stats Cards
                if (!userState.isLoading && userState.roleCounts.isNotEmpty)
                  _StatsCards(counts: userState.roleCounts, isDark: isDark),

                // Search Bar
                _SearchBar(
                  controller: _searchCtrl,
                  onSearch: (query) => _performSearch(query),
                  isDark: isDark,
                ),

                // User List
                Expanded(
                  child: userState.isLoading
                      ? Center(child: CircularProgressIndicator(color: isDark ? AppTheme.white : AppTheme.black))
                      : userState.error != null
                          ? _buildError(userState.error!, isDark)
                          : userState.users.isEmpty
                              ? _buildEmpty(isDark)
                              : _buildUserList(userState.users, isDark),
                ),
              ],
            ),
    );
  }

  Widget _buildAccessDenied(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline, size: 48, color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary),
          const SizedBox(height: 16),
          Text(
            'Akses Ditolak',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: isDark ? AppTheme.white : AppTheme.black),
          ),
          const SizedBox(height: 8),
          Text(
            'Hanya administrator yang dapat mengakses halaman ini',
            style: TextStyle(fontSize: 14, color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String error, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppTheme.priorityHigh),
            const SizedBox(height: 16),
            Text(
              'Terjadi Kesalahan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? AppTheme.white : AppTheme.black),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(fontSize: 13, color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(userProvider.notifier).loadUsers(),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.group_off_rounded, size: 48, color: isDark ? AppTheme.textTertiaryDark : AppTheme.textTertiary),
          const SizedBox(height: 16),
          Text(
            'Belum Ada Pengguna',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? AppTheme.white : AppTheme.black),
          ),
          const SizedBox(height: 8),
          Text(
            'Belum ada pengguna terdaftar',
            style: TextStyle(fontSize: 13, color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList(List<UserModel> users, bool isDark) {
    return RefreshIndicator(
      onRefresh: () => ref.read(userProvider.notifier).loadUsers(),
      color: isDark ? AppTheme.white : AppTheme.black,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
        itemCount: users.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (ctx, i) {
          final user = users[i];
          return _UserCard(
            user: user,
            isDark: isDark,
            onTap: () => context.push('/users/${user.id}'),
            onChangeRole: () => _showRoleDialog(user),
            onDelete: () => _showDeleteDialog(user),
          );
        },
      ),
    );
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      ref.read(userProvider.notifier).loadUsers();
      return;
    }
    try {
      final results = await _repo.searchUsers(query);
      // Gunakan method setSearchResults untuk update state
      ref.read(userProvider.notifier).setSearchResults(results);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Search error: $e')),
        );
      }
    }
  }

  Future<void> _showRoleDialog(UserModel user) async {
    final isDark = context.isDark;
    final roles = ['user', 'helpdesk', 'admin'];

    final selected = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppTheme.dark1 : AppTheme.surface0,
        title: Text(
          'Ubah Role',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: isDark ? AppTheme.white : AppTheme.black),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pilih role untuk ${user.name}',
              style: TextStyle(fontSize: 13, color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            ...roles.map((role) => ListTile(
              title: Text(
                role == 'admin' ? 'Administrator' : role == 'helpdesk' ? 'Helpdesk' : 'Pengguna',
                style: TextStyle(fontSize: 14, color: isDark ? AppTheme.white : AppTheme.black),
              ),
              leading: Icon(
                user.role == role
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                size: 18,
                color: user.role == role
                    ? (isDark ? AppTheme.white : AppTheme.black)
                    : (isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary),
              ),
              onTap: () => Navigator.pop(ctx, role),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: TextStyle(color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary)),
          ),
        ],
      ),
    );

    if (selected != null && selected != user.role) {
      try {
        await ref.read(userProvider.notifier).updateUserRole(user.id, selected);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Role berhasil diubah menjadi $selected')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal mengubah role: $e')),
          );
        }
      }
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
        await ref.read(userProvider.notifier).deleteUser(user.id);
        if (mounted) {
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

  Future<void> _showCreateUserDialog() async {
    final isDark = context.isDark;
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    String selectedRole = 'user';

    final created = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: isDark ? AppTheme.dark1 : AppTheme.surface0,
          title: Text(
            'Buat Pengguna Baru',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: isDark ? AppTheme.white : AppTheme.black),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                style: TextStyle(fontSize: 14, color: isDark ? AppTheme.white : AppTheme.black),
                decoration: InputDecoration(
                  labelText: 'Nama Lengkap',
                  labelStyle: TextStyle(fontSize: 13, color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(fontSize: 14, color: isDark ? AppTheme.white : AppTheme.black),
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(fontSize: 13, color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passCtrl,
                obscureText: true,
                style: TextStyle(fontSize: 14, color: isDark ? AppTheme.white : AppTheme.black),
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(fontSize: 13, color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedRole,
                decoration: InputDecoration(
                  labelText: 'Role',
                  labelStyle: TextStyle(fontSize: 13, color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                items: const [
                  DropdownMenuItem(value: 'user', child: Text('Pengguna')),
                  DropdownMenuItem(value: 'helpdesk', child: Text('Helpdesk')),
                  DropdownMenuItem(value: 'admin', child: Text('Administrator')),
                ],
                onChanged: (v) => setDialogState(() => selectedRole = v!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Batal', style: TextStyle(color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.isEmpty || emailCtrl.text.isEmpty || passCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Semua field harus diisi')),
                  );
                  return;
                }
                try {
                  await _repo.createUser(
                    name: nameCtrl.text.trim(),
                    email: emailCtrl.text.trim(),
                    password: passCtrl.text.trim(),
                    role: selectedRole,
                  );
                  Navigator.pop(ctx, true);
                } catch (e) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text('Gagal membuat user: $e')),
                  );
                }
              },
              child: const Text('Buat'),
            ),
          ],
        ),
      ),
    );

    if (created == true) {
      ref.read(userProvider.notifier).loadUsers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pengguna baru berhasil dibuat')),
        );
      }
    }

    nameCtrl.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
  }
}

// ── Widgets ─────────────────────────────────────────────────────────────────────

class _StatsCards extends StatelessWidget {
  final Map<String, int> counts;
  final bool isDark;

  const _StatsCards({required this.counts, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _StatCard(label: 'Total', value: '${counts['total'] ?? 0}', color: isDark ? AppTheme.white : AppTheme.black, isDark: isDark),
          const SizedBox(width: 8),
          _StatCard(label: 'Admin', value: '${counts['admin'] ?? 0}', color: AppTheme.priorityHigh, isDark: isDark),
          const SizedBox(width: 8),
          _StatCard(label: 'Helpdesk', value: '${counts['helpdesk'] ?? 0}', color: AppTheme.statusInProgress, isDark: isDark),
          const SizedBox(width: 8),
          _StatCard(label: 'User', value: '${counts['user'] ?? 0}', color: AppTheme.statusOpen, isDark: isDark),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const _StatCard({required this.label, required this.value, required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.dark1 : AppTheme.surface0,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? AppTheme.dark3 : AppTheme.surface2, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: color),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: isDark ? AppTheme.textTertiaryDark : AppTheme.textTertiary),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSearch;
  final bool isDark;

  const _SearchBar({required this.controller, required this.onSearch, required this.isDark});

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextField(
        controller: widget.controller,
        onChanged: widget.onSearch,
        style: TextStyle(fontSize: 14, color: widget.isDark ? AppTheme.white : AppTheme.black),
        decoration: InputDecoration(
          hintText: 'Cari berdasarkan nama atau email...',
          hintStyle: TextStyle(fontSize: 14, color: widget.isDark ? AppTheme.textTertiaryDark : AppTheme.textTertiary),
          prefixIcon: Icon(Icons.search_rounded, size: 20, color: widget.isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary),
          suffixIcon: widget.controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear_rounded, size: 18, color: widget.isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary),
                  onPressed: () {
                    widget.controller.clear();
                    widget.onSearch('');
                  },
                )
              : null,
          filled: true,
          fillColor: widget.isDark ? AppTheme.dark1 : AppTheme.surface0,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: widget.isDark ? AppTheme.dark3 : AppTheme.surface2, width: 0.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: widget.isDark ? AppTheme.dark3 : AppTheme.surface2, width: 0.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: widget.isDark ? AppTheme.white : AppTheme.black, width: 1),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final UserModel user;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onChangeRole;
  final VoidCallback onDelete;

  const _UserCard({
    required this.user,
    required this.isDark,
    required this.onTap,
    required this.onChangeRole,
    required this.onDelete,
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
            // Avatar
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _getRoleColor(user.role).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  user.initials,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _getRoleColor(user.role),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? AppTheme.white : AppTheme.black),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.email,
                    style: TextStyle(fontSize: 12, color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary),
                  ),
                ],
              ),
            ),

            // Role Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getRoleColor(user.role).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                user.roleLabel,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _getRoleColor(user.role)),
              ),
            ),
            const SizedBox(width: 8),

            // Actions
            Row(
              children: [
                // Role Change Button
                GestureDetector(
                  onTap: onChangeRole,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.dark2 : AppTheme.surface1,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.edit_rounded,
                      size: 16,
                      color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                // Delete Button
                GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.priorityHigh.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.delete_rounded,
                      size: 16,
                      color: AppTheme.priorityHigh,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
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
