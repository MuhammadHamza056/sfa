import 'dart:async';

import 'package:dio/dio.dart';

import '../hive_services.dart';
import '../localization/app_localizations.dart';
import 'api_endpoints.dart';
import 'api_exception.dart';
import 'api_result.dart';
import 'app_config.dart';

/// Single Dio-backed gateway for every API call in the app.
///
/// Responsibilities:
/// - attaches the standard headers from the guide (Content-Type, Accept,
///   Accept-Language, bearer token when logged in)
/// - transparently refreshes an expired access token once (M05) and retries
///   the request that triggered the 401, so callers never see the token
///   lifecycle
/// - unwraps the `{ success, data }` / `{ statusCode, message }` envelopes
///   into an [ApiResult], so a feature repository never has to touch Dio or
///   parse an error body itself
class ApiClient {
  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
      ),
    );
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers['Content-Type'] = 'application/json';
          options.headers['Accept'] = 'application/json';
          options.headers['Accept-Language'] = localeNotifier.value.languageCode;
          final token = SecureStorage.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final requestPath = error.requestOptions.path;
          final isRefreshCall = requestPath == ApiEndpoints.refreshToken;

          if (error.response?.statusCode == 401 && !isRefreshCall) {
            final refreshed = await _refreshAccessToken();
            if (refreshed) {
              try {
                final response = await _dio.fetch(error.requestOptions);
                return handler.resolve(response);
              } on DioException catch (retryError) {
                return handler.next(retryError);
              }
            }
            await SecureStorage.clearSession();
          }
          handler.next(error);
        },
      ),
    );
  }

  static final ApiClient instance = ApiClient._internal();

  late final Dio _dio;

  /// Guards concurrent 401s during one request burst so only a single
  /// `/auth/refresh` call is made; the rest await its result.
  Completer<bool>? _refreshCompleter;

  Future<bool> _refreshAccessToken() {
    final inFlight = _refreshCompleter;
    if (inFlight != null) return inFlight.future;

    final completer = Completer<bool>();
    _refreshCompleter = completer;

    () async {
      try {
        final refreshToken = SecureStorage.getRefreshToken();
        if (refreshToken == null || refreshToken.isEmpty) {
          completer.complete(false);
          return;
        }
        final response = await Dio(
          BaseOptions(baseUrl: AppConfig.baseUrl),
        ).post(ApiEndpoints.refreshToken, data: {'refreshToken': refreshToken});

        final body = response.data as Map<String, dynamic>;
        final tokens = (body['data'] ?? body) as Map<String, dynamic>;
        final newAccess = tokens['accessToken'] as String?;
        final newRefresh = tokens['refreshToken'] as String?;
        if (newAccess == null) {
          completer.complete(false);
          return;
        }
        await SecureStorage.putAccessToken(newAccess);
        if (newRefresh != null) {
          await SecureStorage.putRefreshToken(newRefresh);
        }
        completer.complete(true);
      } catch (_) {
        completer.complete(false);
      } finally {
        _refreshCompleter = null;
      }
    }();

    return completer.future;
  }

  Future<ApiResult<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic data) fromJson,
  }) {
    return _request<T>(
      () => _dio.get(path, queryParameters: queryParameters),
      fromJson,
    );
  }

  Future<ApiResult<T>> post<T>(
    String path, {
    Object? data,
    required T Function(dynamic data) fromJson,
  }) {
    return _request<T>(() => _dio.post(path, data: data), fromJson);
  }

  Future<ApiResult<T>> put<T>(
    String path, {
    Object? data,
    required T Function(dynamic data) fromJson,
  }) {
    return _request<T>(() => _dio.put(path, data: data), fromJson);
  }

  Future<ApiResult<T>> patch<T>(
    String path, {
    Object? data,
    required T Function(dynamic data) fromJson,
  }) {
    return _request<T>(() => _dio.patch(path, data: data), fromJson);
  }

  Future<ApiResult<T>> delete<T>(
    String path, {
    Object? data,
    required T Function(dynamic data) fromJson,
  }) {
    return _request<T>(() => _dio.delete(path, data: data), fromJson);
  }

  Future<ApiResult<T>> _request<T>(
    Future<Response> Function() call,
    T Function(dynamic data) fromJson,
  ) async {
    try {
      final response = await call();
      final body = response.data;
      final payload = body is Map<String, dynamic> && body.containsKey('data')
          ? body['data']
          : body;
      return ApiSuccess<T>(fromJson(payload));
    } on DioException catch (error) {
      return ApiFailure<T>(ApiException.fromDioException(error));
    } catch (error) {
      return ApiFailure<T>(ApiException(message: error.toString()));
    }
  }
}
