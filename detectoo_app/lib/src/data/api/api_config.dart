import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

/// Environment configuration for the HTTP client.
///
/// The base URL is resolved per platform so dev builds reach the
/// local backend correctly:
///  * Android emulator → `10.0.2.2` (host loopback)
///  * Web / iOS simulator / desktop → `localhost`
///
/// Override for a physical device or staging build by passing
/// `--dart-define=API_BASE_URL=https://api.example.com/api/v1`.
class ApiConfig {
  ApiConfig._();

  /// Base URL for all backend requests, including the `/api/v1` prefix.
  static String get baseUrl {
    const override = String.fromEnvironment('API_BASE_URL');
    if (override.isNotEmpty) return override;

    if (kIsWeb) return 'http://localhost:8000/api/v1';
    if (Platform.isAndroid) return 'http://10.0.2.2:8000/api/v1';
    return 'http://localhost:8000/api/v1';
  }

  /// Maximum time to wait when opening a connection.
  static const Duration connectTimeout = Duration(seconds: 10);

  /// Maximum time to wait between bytes while receiving a response.
  static const Duration receiveTimeout = Duration(seconds: 30);

  /// Maximum time to wait while sending a request body.
  static const Duration sendTimeout = Duration(seconds: 30);
}
