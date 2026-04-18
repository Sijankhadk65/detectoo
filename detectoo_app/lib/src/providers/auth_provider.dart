import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/auth_repository.dart';
import '../models/user.dart';
import 'api_providers.dart';

/// AsyncNotifier that owns the authenticated user state.
///
/// * `build()` attempts to restore a persisted session.
/// * [signIn] exchanges credentials for a session and loads the user.
/// * [signOut] revokes the session and clears local state.
class AuthNotifier extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    return _repo.restoreSession();
  }

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  /// Logs in with an email (or username) + password. On completion the
  /// notifier state is either `AsyncValue.data(user)` or
  /// `AsyncValue.error(...)` — observe [state] to react.
  Future<void> signIn({
    required String emailOrUsername,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() {
      return _repo.login(
        emailOrUsername: emailOrUsername,
        password: password,
      );
    });
  }

  /// Signs out the current user. After this returns the state is
  /// `AsyncValue.data(null)` regardless of whether server-side
  /// revocation succeeded — the token is always cleared locally.
  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await _repo.logout();
    } finally {
      state = const AsyncValue.data(null);
    }
  }
}

/// Global [AuthNotifier] provider. Screens read `.valueOrNull` for the
/// current user and can also observe loading/error states.
final authProvider =
    AsyncNotifierProvider<AuthNotifier, User?>(AuthNotifier.new);
