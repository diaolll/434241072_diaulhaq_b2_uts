import '../models/user_model.dart';
import '../../core/services/supabase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserRepository {
  final _client = SupabaseService.client;

  /// Get current user ID from Supabase Auth
  String? get _currentUserId => _client.auth.currentUser?.id;

  /// Get current user role from SharedPreferences
  Future<String> get _currentRole async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('user_role') ?? 'user';
    print('🔍 _currentRole: $role');
    return role;
  }

  /// Check if current user is admin
  Future<bool> get _isAdmin async {
    final role = await _currentRole;
    return role == 'admin';
  }

  /// Get all users - Admin only
  Future<List<UserModel>> getAllUsers() async {
    // Check if current user is admin
    final isAdmin = await _isAdmin;
    if (!isAdmin) {
      throw Exception('Hanya admin yang dapat mengakses daftar pengguna.');
    }

    try {
      final response = await _client
          .from('users')
          .select('*')
          .order('created_at', ascending: false);

      return (response as List).map((e) => UserModel.fromJson(e)).toList();
    } catch (e) {
      print('❌ Get all users error: $e');
      rethrow;
    }
  }

  /// Get user by ID
  Future<UserModel> getUserById(String id) async {
    final isAdmin = await _isAdmin;
    if (!isAdmin) {
      throw Exception('Hanya admin yang dapat mengakses data pengguna.');
    }

    try {
      final response = await _client
          .from('users')
          .select('*')
          .eq('id', id)
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      print('❌ Get user by ID error: $e');
      throw Exception('User tidak ditemukan: $e');
    }
  }

  /// Create new user (Admin only)
  Future<UserModel> createUser({
    required String name,
    required String email,
    required String password,
    String role = 'user',
  }) async {
    final isAdmin = await _isAdmin;
    if (!isAdmin) {
      throw Exception('Hanya admin yang dapat membuat pengguna baru.');
    }

    try {
      // Create auth user using signup
      final authResponse = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'role': role,
        },
      );

      if (authResponse.user == null) {
        throw Exception('Gagal membuat user di auth');
      }

      final userId = authResponse.user!.id;

      // Gunakan function upsert_user yang bypass RLS
      await _client.rpc('upsert_user', params: {
        'p_id': userId,
        'p_email': email,
        'p_name': name,
        'p_role': role,
      });

      print('✅ User created: $userId - $name ($role)');

      return UserModel(
        id: userId,
        name: name,
        email: email,
        role: role,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      print('❌ Create user error: $e');
      rethrow;
    }
  }

  /// Update user role (Admin only)
  Future<void> updateUserRole(String userId, String newRole) async {
    final isAdmin = await _isAdmin;
    if (!isAdmin) {
      throw Exception('Hanya admin yang dapat mengubah role pengguna.');
    }

    // Prevent admin from changing their own role
    if (userId == _currentUserId) {
      throw Exception('Admin tidak dapat mengubah role sendiri.');
    }

    try {
      await _client
          .from('users')
          .update({'role': newRole})
          .eq('id', userId);

      print('✅ User role updated: $userId -> $newRole');
    } catch (e) {
      print('❌ Update user role error: $e');
      rethrow;
    }
  }

  /// Update user profile (Admin only)
  Future<void> updateUserProfile({
    required String userId,
    String? name,
    String? email,
  }) async {
    final isAdmin = await _isAdmin;
    if (!isAdmin) {
      throw Exception('Hanya admin yang dapat mengubah profil pengguna.');
    }

    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (email != null) data['email'] = email;

      await _client
          .from('users')
          .update(data)
          .eq('id', userId);

      print('✅ User profile updated: $userId');
    } catch (e) {
      print('❌ Update user profile error: $e');
      rethrow;
    }
  }

  /// Delete user (Admin only)
  /// Note: This is a soft delete - user is removed from public.users but auth.users may still exist
  Future<void> deleteUser(String userId) async {
    final isAdmin = await _isAdmin;
    if (!isAdmin) {
      throw Exception('Hanya admin yang dapat menghapus pengguna.');
    }

    // Prevent admin from deleting themselves
    if (userId == _currentUserId) {
      throw Exception('Admin tidak dapat menghapus diri sendiri.');
    }

    try {
      // Delete from public.users
      await _client.from('users').delete().eq('id', userId);

      print('⚠️ User deleted: $userId');
    } catch (e) {
      print('❌ Delete user error: $e');
      rethrow;
    }
  }

  /// Search users by name or email
  Future<List<UserModel>> searchUsers(String query) async {
    final isAdmin = await _isAdmin;
    if (!isAdmin) {
      throw Exception('Hanya admin yang dapat mencari pengguna.');
    }

    try {
      final response = await _client
          .from('users')
          .select('*')
          .or('name.ilike.%$query%,email.ilike.%$query%')
          .order('created_at', ascending: false);

      return (response as List).map((e) => UserModel.fromJson(e)).toList();
    } catch (e) {
      print('❌ Search users error: $e');
      rethrow;
    }
  }

  /// Get users count by role
  Future<Map<String, int>> getUsersCountByRole() async {
    final isAdmin = await _isAdmin;
    if (!isAdmin) {
      throw Exception('Hanya admin yang dapat melihat statistik pengguna.');
    }

    try {
      final response = await _client
          .from('users')
          .select('role');

      final counts = <String, int>{
        'total': 0,
        'admin': 0,
        'helpdesk': 0,
        'user': 0,
      };

      final list = response as List;
      counts['total'] = list.length;

      for (var item in list) {
        final role = item['role'] as String? ?? 'user';
        counts[role] = (counts[role] ?? 0) + 1;
      }

      return counts;
    } catch (e) {
      print('❌ Get users count error: $e');
      rethrow;
    }
  }
}
