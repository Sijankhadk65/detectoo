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

  /// Logs in with email + password. On completion the notifier state is
  /// either `AsyncValue.data(user)` or `AsyncValue.error(...)`.
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() {
      return _repo.login(
        email: email,
        password: password,
      );
    });
  }

  /// Creates a new account, logs in, and loads the user profile.
  Future<void> signUp({
    required String name,
    required String username,
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.signUp(
          name: name,
          username: username,
          email: email,
          password: password,
        ));
  }

  /// Resends the verification email for the currently signed-in user.
  ///
  /// Does not change the notifier state on success — the user is still
  /// unverified until they click the link in the email.
  Future<void> resendVerification() async {
    await _repo.resendVerificationEmail();
  }

  /// Re-fetches the current user's profile and updates the state.
  ///
  /// Used to pick up an email-verification status change after the user
  /// clicks the link in their inbox (which happens outside the app).
  Future<void> refreshUser() async {
    state = AsyncValue.data(await _repo.fetchCurrentUser());
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
