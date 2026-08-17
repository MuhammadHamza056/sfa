import 'dart:io';
import 'package:dio/dio.dart';
import 'package:sfa/core/hive_services.dart';
import 'package:sfa/utils/loader.dart';

import 'app_exceptions.dart';

class BaseClients {
  static const int timeduration = 60;

  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: timeduration),
      receiveTimeout: const Duration(seconds: timeduration),
      sendTimeout: const Duration(seconds: timeduration),
    ),
  );

  //GET
  static Future<Response> get(String baseUrl, String api) async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      //  'Authorization': 'bearearToken ${HiveService.getTokken()}'
    };
    var fullUrl = baseUrl + api;
    try {
      return await _dio.get(fullUrl, options: Options(headers: requestHeaders));
    } on DioException catch (e) {
      return _handleDioError(e, fullUrl);
    } on SocketException {
      Loader.showError("Api not responsding...");
      throw FetchDataException(message: 'No Internet connection', url: fullUrl);
    }
  }

  //POST
  static Future<Response> post({
    required String baseUrl,
    required String api,
    Map<String, dynamic>? payloadObj,
  }) async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      //   'Authorization': 'bearearToken ${HiveService.getTokken()}'
    };
    var fullUrl = baseUrl + api;

    try {
      return await _dio.post(
        fullUrl,
        data: payloadObj,
        options: Options(headers: requestHeaders),
      );
    } on DioException catch (e) {
      return _handleDioError(e, fullUrl);
    } on SocketException {
      throw FetchDataException(message: 'No Internet connection', url: fullUrl);
    }
  }

  static Future<Response> login({
    required String baseUrl,
    required String api,
    Map<String, dynamic>? payloadObj,
  }) async {
    Map<String, String> requestHeaders = {'Accept': 'application/json'};
    var fullUrl = baseUrl + api;
    try {
      return await _dio.post(
        fullUrl,
        data: payloadObj,
        options: Options(headers: requestHeaders),
      );
    } on DioException catch (e) {
      return _handleDioError(e, fullUrl);
    } on SocketException {
      throw FetchDataException(message: 'No Internet connection', url: fullUrl);
    }
  }

  //DELETE
  static Future<Response> delete(
    String baseUrl,
    String api,
    dynamic payloadObj,
  ) async {
    var fullUrl = baseUrl + api;
    try {
      return await _dio.delete(fullUrl, data: payloadObj);
    } on DioException catch (e) {
      return _handleDioError(e, fullUrl);
    } on SocketException {
      throw FetchDataException(message: 'No Internet connection', url: fullUrl);
    }
  }

  //PUT
  static Future<Response> put(
    String baseUrl,
    String api,
    Map<String, dynamic> payloadObj,
  ) async {
    Map<String, String> requestHeaders = {
      'Accept': 'application/json',
      'Authorization': 'bearearToken ${SecureStorage.getTokken()}',
    };
    var fullUrl = baseUrl + api;

    try {
      return await _dio.put(
        fullUrl,
        data: payloadObj,
        options: Options(headers: requestHeaders),
      );
    } on DioException catch (e) {
      return _handleDioError(e, fullUrl);
    } on SocketException {
      throw FetchDataException(message: 'No Internet connection', url: fullUrl);
    }
  }

  static Response _handleDioError(DioException error, String url) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      throw ApiNotRespondingException('API not responded in time', url);
    } else if (error.type == DioExceptionType.connectionError) {
      Loader.showError("Api not responsding...");
      throw FetchDataException(message: 'No Internet connection', url: url);
    } else if (error.response != null) {
      return error.response!;
    } else {
      throw FetchDataException(
        message: error.message ?? 'Unexpected error occurred',
        url: url,
      );
    }
  }
}
