import '../../data/repositories/auth_repository.dart';
import '../../data/models/auth_response_model.dart';

class LoginUseCase {
  final AuthRepositoryImpl repository;

  LoginUseCase(this.repository);

  Future<AuthResponseModel> call(String username, String password) {
    return repository.login(username, password);
  }
}
