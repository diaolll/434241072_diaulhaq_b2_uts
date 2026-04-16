import '../datasources/api_client.dart';
import '../models/user_model.dart';
import '../../core/constants/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  final _api = ApiClient().dio;

  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await _api.post(ApiConstants.login, data: {
      'email': email,
      'password': password,
    });
    final token = res.data['token']?.toString() ?? '';
    final user = UserModel.fromJson(res.data['user'] ?? {});

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('user_role', user.role);
    await prefs.setString('user_id', user.id);
    await prefs.setString('user_name', user.name);
    await prefs.setString('user_email', user.email);

    return {'token': token, 'user': user};
  }

  Future<UserModel> register(String name, String email, String password) async {
    final res = await _api.post(ApiConstants.register, data: {
      'name': name,
      'email': email,
      'password': password,
    });
    return UserModel.fromJson(res.data['user']);
  }

  Future<void> resetPassword(String email, String newPassword) async {
    await _api.post(ApiConstants.resetPassword, data: {
      'email': email,
      'new_password': newPassword,
    });
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_role');
    await prefs.remove('user_id');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_role');
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_name');
  }

  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_email');
  }
}
