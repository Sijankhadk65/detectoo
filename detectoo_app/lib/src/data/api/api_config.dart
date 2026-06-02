import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb, kReleaseMode;

/// Environment configuration for the HTTP client.
///
/// The base URL is resolved per platform and build mode:
///  * Android debug → `dev.detectoo.tech`
///  * Android release → `api.detectoo.tech`
///  * Web / iOS simulator / desktop → `localhost`
///
/// Override for any build by passing
/// `--dart-define=API_BASE_URL=https://api.example.com/api/v1`.
class ApiConfig {
  ApiConfig._();

  /// Base URL for all backend requests, including the `/api/v1` prefix.
  static String get baseUrl {
    const override = String.fromEnvironment('API_BASE_URL');
    if (override.isNotEmpty) return override;

    if (kIsWeb) return 'http://localhost:8000/api/v1';
    if (Platform.isAndroid) {
      return kReleaseMode
          ? 'https://api.detectoo.tech/api/v1'
          : 'https://dev.detectoo.tech/api/v1';
    }
    return 'http://localhost:8000/api/v1';
  }

  /// Maximum time to wait when opening a connection.
  static const Duration connectTimeout = Duration(seconds: 10);

  /// Maximum time to wait between bytes while receiving a response.
  static const Duration receiveTimeout = Duration(seconds: 30);

  /// Maximum time to wait while sending a request body.
  static const Duration sendTimeout = Duration(seconds: 30);
}
