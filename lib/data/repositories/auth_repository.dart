import '../../core/services/supabase_service.dart';
import '../models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// AuthRepository using Supabase Auth
/// RLS policies now work properly with auth.uid()
class AuthRepository {
  final _client = SupabaseService.client;

  /// Login dengan email & password
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Login failed: Invalid credentials');
      }

      if (response.session == null) {
        throw Exception('Login failed: No session created');
      }

      final user = response.user!;

      // Pastikan user ada di tabel users (pakai upsert)
      await _ensureUserExists(user);

      // Ambil data user dari tabel users (termasuk role)
      final userData = await _client
          .from('users')
          .select()
          .eq('id', user.id)
          .single();

      final name = userData['name']?.toString() ?? email.split('@')[0];
      final role = userData['role']?.toString() ?? 'user';

      // Simpan ke SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', response.session!.accessToken);
      await prefs.setString('user_id', user.id);
      await prefs.setString('user_email', email);
      await prefs.setString('user_name', name);
      await prefs.setString('user_role', role);

      return {
        'token': response.session!.accessToken,
        'user': UserModel(
          id: user.id,
          name: name,
          email: email,
          role: role,
          createdAt: DateTime.now(),
        ),
      };
    } catch (e) {
      print('❌ Login error: $e');
      rethrow;
    }
  }

  /// Register user baru
  Future<UserModel> register(String name, String email, String password) async {
    try {
      print('📝 Registering: $email, $name');

      // Sign up
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'role': 'user',
        },
      );

      if (response.user == null) {
        print('❌ Register failed: no user returned');
        throw Exception('Registration failed: No user created');
      }

      final user = response.user!;
      print('✅ User created in auth: ${user.id}');

      // Pastikan user ada di tabel users (pakai upsert)
      await _ensureUserExists(user);
      print('✅ User synced to public.users');

      // Return user data (tanpa auto login)
      return UserModel(
        id: user.id,
        name: name,
        email: email,
        role: 'user',
        createdAt: DateTime.now(),
      );
    } catch (e) {
      print('❌ Register error: $e');
      rethrow;
    }
  }

  /// Reset password (kirim email reset)
  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  /// Logout
  Future<void> logout() async {
    await _client.auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_role');
    await prefs.remove('user_id');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
  }

  /// Get current user dari Supabase Auth
  Future<UserModel?> getCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    final metadata = user.userMetadata ?? {};
    return UserModel(
      id: user.id,
      name: metadata['name'] ?? user.email?.split('@')[0] ?? '',
      email: user.email ?? '',
      role: metadata['role'] ?? 'user',
      createdAt: DateTime.now(),
    );
  }

  /// Get token
  Future<String?> getToken() async {
    final session = _client.auth.currentSession;
    return session?.accessToken;
  }

  /// Get role
  Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_role');
  }

  /// Get user ID
  Future<String?> getUserId() async {
    return _client.auth.currentUser?.id;
  }

  /// Get user name
  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_name');
  }

  /// Get user email
  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_email');
  }

  /// Check if logged in
  bool get isLoggedIn {
    return _client.auth.currentUser != null;
  }

  /// Pastikan user ada di tabel users (pakai upsert)
  /// Jangan override role yang sudah ada di database
  Future<void> _ensureUserExists(User user) async {
    final metadata = user.userMetadata ?? {};

    // Cek dulu apakah user sudah ada
    final existing = await _client
        .from('users')
        .select('role')
        .eq('id', user.id)
        .maybeSingle();

    final role = existing?['role'] ??
                 metadata['role'] ??
                 'user';

    // Upsert - insert atau update jika sudah ada
    // Tapi jangan override role jika sudah ada
    await _client.from('users').upsert({
      'id': user.id,
      'email': user.email,
      'name': metadata['name'] ?? user.email?.split('@')[0],
      'role': role,  // Pakai role dari database jika ada
    }, onConflict: 'id');

    print('✅ Upsert user: ${user.id} with role: $role');
  }

  /// Refresh session
  Future<void> refreshSession() async {
    await _client.auth.refreshSession();
  }
}
