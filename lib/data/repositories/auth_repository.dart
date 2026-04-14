import 'package:dio/dio.dart';
import '../datasources/api_client.dart';
import '../models/user_model.dart';
import '../../core/constants/api_constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthRepository {
  final _api = ApiClient().dio;
  final _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await _api.post(ApiConstants.login, data: {
      'email': email,
      'password': password,
    });
    final token = res.data['token'];
    final user = UserModel.fromJson(res.data['user']);
    await _storage.write(key: 'auth_token', value: token);
    await _storage.write(key: 'user_role', value: user.role);
    await _storage.write(key: 'user_id', value: user.id);
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
    await _storage.deleteAll();
  }

  Future<String?> getToken() => _storage.read(key: 'auth_token');
  Future<String?> getRole() => _storage.read(key: 'user_role');
  Future<String?> getUserId() => _storage.read(key: 'user_id');
}