import 'package:dio/dio.dart';

sealed class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;

  factory ApiException.fromDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException('Kết nối máy chủ quá thời gian. Vui lòng kiểm tra mạng.');
      case DioExceptionType.connectionError:
        return const NetworkException('Không thể kết nối đến máy chủ. Vui lòng thử lại sau.');
      case DioExceptionType.badResponse:
        final status = error.response?.statusCode;
        final data = error.response?.data;
        String errorMessage = 'Đã có lỗi xảy ra. Vui lòng thử lại.';

        if (data is Map<String, dynamic>) {
          final msg = data['message'];
          if (msg is List && msg.isNotEmpty) {
            errorMessage = msg.first.toString();
          } else if (msg is String && msg.isNotEmpty) {
            errorMessage = msg;
          } else if (data['error'] is String) {
            errorMessage = data['error'];
          }
        }

        switch (status) {
          case 400:
            return ValidationException(errorMessage, status);
          case 401:
            return UnauthorizedException(errorMessage, status);
          case 403:
            return ForbiddenException(errorMessage, status);
          case 404:
            return NotFoundException(errorMessage, status);
          case 409:
            return ConflictException(errorMessage, status);
          case 500:
          case 502:
          case 503:
            return ServerException(errorMessage, status);
          default:
            return ServerException(errorMessage, status);
        }
      case DioExceptionType.cancel:
        return const RequestCancelledException('Yêu cầu đã bị hủy.');
      default:
        return UnknownException(error.message ?? 'Đã xảy ra lỗi không xác định.');
    }
  }
}

class ValidationException extends ApiException {
  const ValidationException(super.message, [super.statusCode = 400]);
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException([super.message = 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.', super.statusCode = 401]);
}

class ForbiddenException extends ApiException {
  const ForbiddenException([super.message = 'Bạn không có quyền thực hiện hành động này.', super.statusCode = 403]);
}

class NotFoundException extends ApiException {
  const NotFoundException([super.message = 'Không tìm thấy dữ liệu yêu cầu.', super.statusCode = 404]);
}

class ConflictException extends ApiException {
  const ConflictException([super.message = 'Dữ liệu bị trùng lặp hoặc xung đột.', super.statusCode = 409]);
}

class ServerException extends ApiException {
  const ServerException([super.message = 'Lỗi máy chủ nội bộ. Vui lòng thử lại sau.', super.statusCode = 500]);
}

class NetworkException extends ApiException {
  const NetworkException([super.message = 'Không có kết nối Internet. Vui lòng kiểm tra mạng.']);
}

class TimeoutException extends ApiException {
  const TimeoutException([super.message = 'Kết nối quá thời gian chờ.']);
}

class RequestCancelledException extends ApiException {
  const RequestCancelledException([super.message = 'Yêu cầu bị hủy.']);
}

class UnknownException extends ApiException {
  const UnknownException([super.message = 'Đã có lỗi không xác định xảy ra.']);
}
