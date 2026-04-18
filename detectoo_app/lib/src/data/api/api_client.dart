import 'package:dio/dio.dart';

import '../storage/token_storage.dart';
import 'api_config.dart';
import 'api_exception.dart';

/// Thin wrapper around [Dio] consumed exclusively by repositories.
///
/// Hides the underlying HTTP library so repositories depend only on
/// this class and [ApiException]. Swapping the transport later means
/// changing this one file and its Riverpod provider — nothing else.
class ApiClient {
  /// Creates an [ApiClient] bound to [tokenStorage]. Inject a custom
  /// [dio] in tests (e.g. with `DioAdapter`) to stub network responses.
  ApiClient({required TokenStorage tokenStorage, Dio? dio})
      : _tokenStorage = tokenStorage,
        _dio = dio ?? _defaultDio() {
    _dio.interceptors.add(_authInterceptor());
  }

  final Dio _dio;
  final TokenStorage _tokenStorage;

  static Dio _defaultDio() => Dio(
        BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          connectTimeout: ApiConfig.connectTimeout,
          receiveTimeout: ApiConfig.receiveTimeout,
          sendTimeout: ApiConfig.sendTimeout,
          contentType: 'application/json',
          responseType: ResponseType.json,
        ),
      );

  Interceptor _authInterceptor() => InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.readAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      );

  /// Performs a `GET` and returns the decoded JSON body.
  Future<dynamic> get(String path, {Map<String, dynamic>? query}) =>
      _send(() => _dio.get<dynamic>(path, queryParameters: query));

  /// Performs a JSON `POST` and returns the decoded body.
  Future<dynamic> post(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
  }) =>
      _send(
        () => _dio.post<dynamic>(path, data: body, queryParameters: query),
      );

  /// Performs a form-url-encoded `POST`. Used for OAuth2 endpoints like
  /// `/login` that expect `application/x-www-form-urlencoded`.
  Future<dynamic> postForm(
    String path, {
    required Map<String, dynamic> fields,
  }) =>
      _send(
        () => _dio.post<dynamic>(
          path,
          data: fields,
          options: Options(contentType: Headers.formUrlEncodedContentType),
        ),
      );

  /// Performs a `PATCH` and returns the decoded JSON body.
  Future<dynamic> patch(String path, {Object? body}) =>
      _send(() => _dio.patch<dynamic>(path, data: body));

  /// Performs a `DELETE` and returns the decoded JSON body.
  Future<dynamic> delete(String path) =>
      _send(() => _dio.delete<dynamic>(path));

  Future<dynamic> _send(Future<Response<dynamic>> Function() run) async {
    try {
      final response = await run();
      return response.data;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  ApiException _mapDioError(DioException e) {
    final status = e.response?.statusCode;
    final body = e.response?.data;
    final serverMessage = _extractMessage(body);

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'Request timed out. Please try again.',
          type: ApiExceptionType.timeout,
          statusCode: status,
          details: body,
        );
      case DioExceptionType.cancel:
        return ApiException(
          message: 'Request cancelled',
          type: ApiExceptionType.cancelled,
          statusCode: status,
          details: body,
        );
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        if (status == null) {
          return ApiException(
            message: 'Cannot reach server. Check your connection.',
            type: ApiExceptionType.network,
            details: body,
          );
        }
        break;
      case DioExceptionType.badCertificate:
        return ApiException(
          message: 'Invalid server certificate',
          type: ApiExceptionType.network,
          statusCode: status,
          details: body,
        );
      case DioExceptionType.badResponse:
        break;
    }

    return ApiException(
      message: serverMessage ?? e.message ?? 'Request failed',
      type: _classifyStatus(status),
      statusCode: status,
      details: body,
    );
  }

  ApiExceptionType _classifyStatus(int? status) {
    if (status == null) return ApiExceptionType.unknown;
    if (status == 401) return ApiExceptionType.unauthorized;
    if (status == 403) return ApiExceptionType.forbidden;
    if (status == 404) return ApiExceptionType.notFound;
    if (status == 400 || status == 422) return ApiExceptionType.badRequest;
    if (status >= 500) return ApiExceptionType.server;
    return ApiExceptionType.unknown;
  }

  /// Pulls a `detail` string out of a FastAPI error body when present.
  String? _extractMessage(Object? body) {
    if (body is Map) {
      final detail = body['detail'];
      if (detail is String) return detail;
      if (detail is List && detail.isNotEmpty) {
        final first = detail.first;
        if (first is Map && first['msg'] is String) {
          return first['msg'] as String;
        }
      }
    }
    return null;
  }
}
