import 'dart:async';
import 'package:dio/dio.dart';
import '../storage/secure_storage.dart';
import '../constants/api_endpoints.dart';
import 'api_exception.dart';

class AuthInterceptor extends QueuedInterceptor {
  final Dio dio;
  final SecureStorage secureStorage;
  final String baseUrl;
  final void Function()? onSessionExpired;

  AuthInterceptor({
    required this.dio,
    required this.secureStorage,
    required this.baseUrl,
    this.onSessionExpired,
  });

  bool _isAuthEndpoint(String path) {
    return path.contains(ApiEndpoints.login) ||
        path.contains(ApiEndpoints.register) ||
        path.contains(ApiEndpoints.refreshToken) ||
        path.contains(ApiEndpoints.forgotPassword);
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_isAuthEndpoint(options.path)) {
      final token = await secureStorage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode;
    final path = err.requestOptions.path;

    if (statusCode == 401 && !_isAuthEndpoint(path)) {
      final refreshToken = await secureStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        await secureStorage.clearAuth();
        onSessionExpired?.call();
        return handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            error: const UnauthorizedException(),
            type: DioExceptionType.badResponse,
            response: err.response,
          ),
        );
      }

      try {
        // Create an isolated Dio instance to avoid interceptor loop
        final refreshDio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
          ),
        );

        final refreshResponse = await refreshDio.post(
          ApiEndpoints.refreshToken,
          data: {'refreshToken': refreshToken},
        );

        final responseData = refreshResponse.data;
        Map<String, dynamic>? dataMap;

        if (responseData is Map<String, dynamic>) {
          if (responseData['data'] is Map<String, dynamic>) {
            dataMap = responseData['data'] as Map<String, dynamic>;
          } else {
            dataMap = responseData;
          }
        }

        final newAccessToken = dataMap?['accessToken'] as String?;
        final newRefreshToken = (dataMap?['refreshToken'] as String?) ?? refreshToken;

        if (newAccessToken != null && newAccessToken.isNotEmpty) {
          await secureStorage.saveTokens(
            accessToken: newAccessToken,
            refreshToken: newRefreshToken,
          );

          // Retry the original request with the new access token
          final newOptions = err.requestOptions;
          newOptions.headers['Authorization'] = 'Bearer $newAccessToken';

          final clonedResponse = await dio.fetch(newOptions);
          return handler.resolve(clonedResponse);
        } else {
          throw const UnauthorizedException('Không thể làm mới phiên đăng nhập');
        }
      } catch (refreshErr) {
        await secureStorage.clearAuth();
        onSessionExpired?.call();
        return handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            error: const UnauthorizedException(),
            type: DioExceptionType.badResponse,
            response: err.response,
          ),
        );
      }
    }

    return handler.next(err);
  }
}
