import '../../models/user.dart';
import '../api/api_client.dart';
import '../api/api_exception.dart';
import '../storage/token_storage.dart';
import 'auth_repository.dart';

/// HTTP-backed [AuthRepository] that talks to the FastAPI backend.
class AuthRepositoryImpl implements AuthRepository {
  /// Creates an [AuthRepositoryImpl].
  AuthRepositoryImpl({
    required ApiClient client,
    required TokenStorage tokenStorage,
  })  : _client = client,
        _tokenStorage = tokenStorage;

  final ApiClient _client;
  final TokenStorage _tokenStorage;

  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    final tokenJson = await _client.post(
      '/login',
      body: {
        'email': email,
        'password': password,
      },
    ) as Map<String, dynamic>;

    final accessToken = tokenJson['access_token'] as String?;
    if (accessToken == null || accessToken.isEmpty) {
      throw const ApiException(
        message: 'Login response missing access_token',
        type: ApiExceptionType.unknown,
      );
    }

    await _tokenStorage.writeAccessToken(accessToken);

    try {
      return await fetchCurrentUser();
    } catch (_) {
      // If we can't load the profile after a successful login, don't
      // leave a half-authenticated state behind.
      await _tokenStorage.clear();
      rethrow;
    }
  }

  @override
  Future<User> fetchCurrentUser() async {
    final json = await _client.get('/user/me/') as Map<String, dynamic>;
    return _mapUser(json);
  }

  @override
  Future<User?> restoreSession() async {
    final token = await _tokenStorage.readAccessToken();
    if (token == null || token.isEmpty) return null;

    try {
      return await fetchCurrentUser();
    } on ApiException catch (e) {
      if (e.type == ApiExceptionType.unauthorized) {
        await _tokenStorage.clear();
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<User> signUp({
    required String name,
    required String username,
    required String email,
    required String password,
  }) async {
    await _client.post(
      '/user',
      body: {
        'name': name,
        'username': username,
        'email': email,
        'password': password,
      },
    );
    return login(email: email, password: password);
  }

  @override
  Future<bool> isUsernameAvailable(String username) async {
    final json = await _client.get('/check/username/$username') as Map<String, dynamic>;
    return json['available'] as bool;
  }

  @override
  Future<bool> isEmailAvailable(String email) async {
    final json = await _client.get('/check/email/$email') as Map<String, dynamic>;
    return json['available'] as bool;
  }

  @override
  Future<void> logout() async {
    final token = await _tokenStorage.readAccessToken();
    if (token != null && token.isNotEmpty) {
      try {
        await _client.post('/logout');
      } on ApiException {
        // Server-side revocation can fail (expired token, offline);
        // we still clear local state below.
      }
    }
    await _tokenStorage.clear();
  }

  /// Maps a `UserRead` JSON payload onto the app's [User] model.
  ///
  /// The backend's `UserRead` schema does not expose a sign-up date,
  /// so [User.memberSince] is left as an empty string for now.
  User _mapUser(Map<String, dynamic> json) {
    return User(
      (b) => b
        ..name = json['name'] as String
        ..email = json['email'] as String
        ..memberSince = '',
    );
  }
}
