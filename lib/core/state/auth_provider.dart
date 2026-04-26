import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/app_user.dart';
import '../../repositories/auth_repository.dart';
import '../../services/authentication.dart';
import 'role_provider.dart';

final authRepositoryProvider =
Provider((ref) => AuthRepository(AuthService()));

final authProvider =
StateNotifierProvider<AuthNotifier, AuthState>(
        (ref) => AuthNotifier(ref));


// STATE

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final AppUser? user;
  final String? error;

  const AuthState({
    required this.status,
    this.user,
    this.error,
  });

  const AuthState.unknown()
      : status = AuthStatus.unknown,
        user = null,
        error = null;

  const AuthState.unauthenticated({this.error})
      : status = AuthStatus.unauthenticated,
        user = null;

  const AuthState.authenticated(AppUser user)
      : status = AuthStatus.authenticated,
        user = user,
        error = null;

  bool get isAuthenticated => status == AuthStatus.authenticated;
}


// NOTIFIER

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;
  late final AuthRepository _repo;

  AuthNotifier(this.ref) : super(const AuthState.unknown()) {
    _repo = ref.read(authRepositoryProvider);
    _checkSession();
  }

  Future<void> _checkSession() async {
    state = const AuthState.unauthenticated();
  }

  Future<void> login(String email, String password) async {
    state = const AuthState.unknown();

    try {
      final user = await _repo.login(email, password);

      // SET ROLE PROVIDER (IMPORTANT)
      ref.read(roleProvider.notifier).state = user.role;

      state = AuthState.authenticated(user);
    } catch (e) {
      state = AuthState.unauthenticated(error: e.toString());
    }
  }

  Future<void> signup(AppUser user, String password) async {
    state = const AuthState.unknown();

    try {
      await _repo.signup(user, password);

      ref.read(roleProvider.notifier).state = user.role;

      state = AuthState.authenticated(user);
    } catch (e) {
      state = AuthState.unauthenticated(error: e.toString());
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    ref.read(roleProvider.notifier).state = null;
    state = const AuthState.unauthenticated();
  }
}