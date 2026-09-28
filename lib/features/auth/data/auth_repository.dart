import 'package:ecommerce_mobile/core/constants/api_endpoints.dart';
import 'package:ecommerce_mobile/core/network/api_client.dart';
import 'package:ecommerce_mobile/core/storage/secure_storage.dart';
import 'models/user_model.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final SecureStorage _secureStorage;

  AuthRepository(this._apiClient, this._secureStorage);

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      data: {
        'email': email.trim(),
        'password': password,
      },
    );

    final data = response is Map<String, dynamic> ? response : <String, dynamic>{};
    final accessToken = data['accessToken']?.toString() ?? '';
    final refreshToken = data['refreshToken']?.toString() ?? '';

    if (accessToken.isNotEmpty) {
      await _secureStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    }

    if (data['user'] != null && data['user'] is Map<String, dynamic>) {
      return UserModel.fromJson(data['user'] as Map<String, dynamic>);
    }

    return await getProfile();
  }

  Future<UserModel> register({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.register,
      data: {
        'email': email.trim(),
        'password': password,
        if (firstName != null && firstName.isNotEmpty) 'firstName': firstName.trim(),
        if (lastName != null && lastName.isNotEmpty) 'lastName': lastName.trim(),
      },
    );

    final data = response is Map<String, dynamic> ? response : <String, dynamic>{};
    final accessToken = data['accessToken']?.toString() ?? '';
    final refreshToken = data['refreshToken']?.toString() ?? '';

    if (accessToken.isNotEmpty) {
      await _secureStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    }

    if (data['user'] != null && data['user'] is Map<String, dynamic>) {
      return UserModel.fromJson(data['user'] as Map<String, dynamic>);
    }

    return await getProfile();
  }

  Future<UserModel> getProfile() async {
    final response = await _apiClient.get(ApiEndpoints.profile);
    if (response is Map<String, dynamic>) {
      return UserModel.fromJson(response);
    }
    throw Exception('Dữ liệu người dùng không hợp lệ');
  }

  Future<void> logout() async {
    try {
      await _apiClient.post(ApiEndpoints.logout);
    } catch (_) {
      // Ignore network errors on logout to allow local session clearing
    } finally {
      await _secureStorage.clearAuth();
    }
  }

  Future<void> forgotPassword(String email) async {
    await _apiClient.post(
      ApiEndpoints.forgotPassword,
      data: {'email': email.trim()},
    );
  }

  Future<bool> hasValidToken() async {
    final token = await _secureStorage.getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
