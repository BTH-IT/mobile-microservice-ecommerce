import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../../config/env.dart';
import '../storage/secure_storage.dart';
import 'api_exception.dart';
import 'auth_interceptor.dart';

class ApiClient {
  final Dio dio;
  final SecureStorage secureStorage;
  final void Function()? onSessionExpired;

  ApiClient({
    required this.secureStorage,
    this.onSessionExpired,
    String? baseUrl,
  }) : dio = Dio(
          BaseOptions(
            baseUrl: baseUrl ?? Env.apiBaseUrl,
            connectTimeout: const Duration(seconds: Env.connectTimeoutSeconds),
            receiveTimeout: const Duration(seconds: Env.receiveTimeoutSeconds),
            sendTimeout: const Duration(seconds: Env.sendTimeoutSeconds),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        ) {
    final effectiveBaseUrl = baseUrl ?? Env.apiBaseUrl;

    dio.interceptors.add(
      AuthInterceptor(
        dio: dio,
        secureStorage: secureStorage,
        baseUrl: effectiveBaseUrl,
        onSessionExpired: onSessionExpired,
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
          maxWidth: 100,
        ),
      );
    }
  }

  /// Unwraps the standard NestJS envelope `{ success: true, data: T, ... }`
  dynamic _unwrapData(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      if (responseData.containsKey('data')) {
        return responseData['data'];
      }
    }
    return responseData;
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return _unwrapData(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return _unwrapData(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<dynamic> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return _unwrapData(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<dynamic> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return _unwrapData(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<dynamic> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return _unwrapData(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
