import 'package:synapse/feature/auth/data/services/auth_service.dart';

class AuthRepository {
  final AuthService service;

  AuthRepository(this.service);

  Future<void> logout() async {
    await service.logout();
  }
}
