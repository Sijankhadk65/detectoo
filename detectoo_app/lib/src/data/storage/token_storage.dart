import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists authentication tokens between app launches.
///
/// The default [SecureTokenStorage] is backed by platform keychains on
/// iOS/macOS, EncryptedSharedPreferences on Android, libsecret on Linux,
/// and WebCrypto-encrypted localStorage on web.
abstract class TokenStorage {
  /// Returns the current access token, or `null` if none is saved.
  Future<String?> readAccessToken();

  /// Overwrites the saved access token. Passing `null` clears it.
  Future<void> writeAccessToken(String? token);

  /// Clears every token from storage. Called on logout.
  Future<void> clear();
}

/// Production implementation backed by [FlutterSecureStorage].
class SecureTokenStorage implements TokenStorage {
  /// Creates a [SecureTokenStorage]. Inject a custom [FlutterSecureStorage]
  /// in tests to swap the native backend.
  SecureTokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const _accessTokenKey = 'detectoo.access_token';

  final FlutterSecureStorage _storage;

  @override
  Future<String?> readAccessToken() => _storage.read(key: _accessTokenKey);

  @override
  Future<void> writeAccessToken(String? token) {
    if (token == null) return _storage.delete(key: _accessTokenKey);
    return _storage.write(key: _accessTokenKey, value: token);
  }

  @override
  Future<void> clear() => _storage.deleteAll();
}

/// In-memory fallback used by tests and transient/unauthenticated flows.
class InMemoryTokenStorage implements TokenStorage {
  /// Creates an empty [InMemoryTokenStorage].
  InMemoryTokenStorage();

  String? _token;

  @override
  Future<String?> readAccessToken() async => _token;

  @override
  Future<void> writeAccessToken(String? token) async => _token = token;

  @override
  Future<void> clear() async => _token = null;
}
