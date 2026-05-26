import '../../models/user.dart';

/// Domain-level contract for authentication.
///
/// Screens and providers depend on this abstraction — never on
/// [ApiClient] or [TokenStorage] directly — so the transport layer
/// can be swapped (e.g. for fakes in widget tests) without touching
/// UI code.
abstract class AuthRepository {
  /// Exchanges credentials for an access token and returns the
  /// authenticated user. The token is persisted for subsequent
  /// requests.
  ///
  /// Authenticates with email + password. The backend accepts only a
  /// valid email address; usernames are no longer supported.
  Future<User> login({
    required String email,
    required String password,
  });

  /// Fetches the currently authenticated user. Requires a previously
  /// stored access token.
  Future<User> fetchCurrentUser();

  /// If a token is already stored, fetches and returns the current
  /// user; otherwise returns `null`. Useful on app start to decide
  /// between the login screen and the home screen.
  Future<User?> restoreSession();

  /// Verifies the current user's email with a 6-digit OTP code.
  Future<void> verifyEmail(String code);

  /// Requests a new verification code to be sent to the current user's email.
  Future<void> resendVerificationCode();

  /// Creates a new account and returns the authenticated user.
  ///
  /// On success the session token is persisted exactly as it would be
  /// after a successful [login] call.
  Future<User> signUp({
    required String name,
    required String username,
    required String email,
    required String password,
  });

  /// Revokes the current session on the server and clears the stored
  /// token. Safe to call even when not logged in.
  Future<void> logout();
}
