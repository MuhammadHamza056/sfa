import 'package:dio/dio.dart';

/// A normalized failure for any API call, built from the guide's standard
/// error envelope:
/// ```json
/// {
///   "statusCode": 400,
///   "message": ["phoneNumber must be 7-15 digits"],
///   "error": "BadRequestException",
///   "path": "/api/v1/auth/register",
///   "timestamp": "..."
/// }
/// ```
/// `message` is normalized to a single display-ready string (validation
/// errors arrive as a list; other errors as a plain string).
class ApiException implements Exception {
  final int? statusCode;
  final String message;
  final String? errorType;
  final String? path;

  const ApiException({
    required this.message,
    this.statusCode,
    this.errorType,
    this.path,
  });

  bool get isUnauthorized => statusCode == 401;
  bool get isNotFound => statusCode == 404;
  bool get isValidationError => statusCode == 400;
  bool get isNetworkError => statusCode == null;

  factory ApiException.fromDioException(DioException error) {
    final response = error.response;
    if (response == null) {
      return ApiException(message: _messageForDioError(error));
    }
    return ApiException.fromResponseData(
      response.data,
      fallbackStatusCode: response.statusCode,
    );
  }

  factory ApiException.fromResponseData(
    dynamic data, {
    int? fallbackStatusCode,
  }) {
    if (data is Map<String, dynamic>) {
      final rawMessage = data['message'];
      final message = rawMessage is List
          ? rawMessage.join('\n')
          : (rawMessage?.toString() ?? 'Something went wrong');
      return ApiException(
        message: message,
        statusCode: (data['statusCode'] as num?)?.toInt() ?? fallbackStatusCode,
        errorType: data['error'] as String?,
        path: data['path'] as String?,
      );
    }
    return ApiException(
      message: 'Something went wrong',
      statusCode: fallbackStatusCode,
    );
  }

  static String _messageForDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'The server took too long to respond. Please try again.';
      case DioExceptionType.connectionError:
        return 'No internet connection. Please check your network.';
      case DioExceptionType.cancel:
        return 'Request cancelled.';
      default:
        return error.message ?? 'Something went wrong';
    }
  }

  @override
  String toString() => 'ApiException($statusCode, $message)';
}
