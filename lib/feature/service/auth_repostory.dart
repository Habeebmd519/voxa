import 'package:voxa/feature/service/auth_service.dart';

class AuthRepository {
  final AuthService service;

  AuthRepository(this.service);

  Future<void> logout() async {
    await service.logout();
  }
}
