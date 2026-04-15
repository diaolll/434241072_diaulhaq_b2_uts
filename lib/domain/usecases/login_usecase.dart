import '../../data/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Map<String, dynamic>> call(String username, String password) {
    return repository.login(username, password);
  }
}
