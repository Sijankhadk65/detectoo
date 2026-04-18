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
  /// The backend's `/login` endpoint accepts either username or email
  /// in the `username` form field, so [emailOrUsername] may be either.
  Future<User> login({
    required String emailOrUsername,
    required String password,
  });

  /// Fetches the currently authenticated user. Requires a previously
  /// stored access token.
  Future<User> fetchCurrentUser();

  /// If a token is already stored, fetches and returns the current
  /// user; otherwise returns `null`. Useful on app start to decide
  /// between the login screen and the home screen.
  Future<User?> restoreSession();

  /// Revokes the current session on the server and clears the stored
  /// token. Safe to call even when not logged in.
  Future<void> logout();
}
