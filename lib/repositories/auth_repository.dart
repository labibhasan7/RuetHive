import '../models/app_user.dart';
import '../services/authentication.dart';

class AuthRepository {
  final AuthService _service;

  AuthRepository(this._service);

  Future<AppUser> login(String email, String password) async {
    final user = await _service.login(email: email, password: password);
    return await _service.getUser(user!.uid);
  }

  Future<void> signup(AppUser user, String password) async {
    await _service.signUp(
      email: user.email,
      password: password,
      user: user,
    );
  }

  Future<void> logout() async {
    await _service.logout();
  }
}