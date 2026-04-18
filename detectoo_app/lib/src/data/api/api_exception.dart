/// Typed exception raised by the HTTP layer.
///
/// Repositories surface this (or their own domain errors) instead of
/// leaking `DioException`, so callers never depend on the transport
/// library.
class ApiException implements Exception {
  /// Creates an [ApiException].
  const ApiException({
    required this.message,
    required this.type,
    this.statusCode,
    this.details,
  });

  /// Human-readable message suitable for display or logging.
  final String message;

  /// High-level category callers can switch on.
  final ApiExceptionType type;

  /// HTTP status code when the request reached the server.
  final int? statusCode;

  /// Decoded response body, if any (e.g. FastAPI's `{"detail": "..."}`).
  final Object? details;

  @override
  String toString() =>
      'ApiException(type: $type, status: $statusCode, message: $message)';
}

/// High-level categories for [ApiException].
enum ApiExceptionType {
  /// Request timed out (connect, send, or receive).
  timeout,

  /// No internet, host unreachable, or DNS failure.
  network,

  /// Authentication required or token expired (HTTP 401).
  unauthorized,

  /// Authenticated but not allowed (HTTP 403).
  forbidden,

  /// Resource does not exist (HTTP 404).
  notFound,

  /// Request rejected due to validation (HTTP 422) or bad input (HTTP 400).
  badRequest,

  /// Server responded with a 5xx status code.
  server,

  /// Request was cancelled by the caller.
  cancelled,

  /// Any other failure (including response parsing errors).
  unknown,
}
