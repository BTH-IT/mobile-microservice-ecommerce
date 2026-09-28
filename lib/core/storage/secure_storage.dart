import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _keyAccessToken = 'access_token';
  static const _keyRefreshToken = 'refresh_token';
  static const _keyDeviceId = 'device_id';

  final FlutterSecureStorage _storage;
  final Map<String, String> _memoryFallback = {};

  SecureStorage([FlutterSecureStorage? storage])
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(),
              iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
              mOptions: MacOsOptions(accessibility: KeychainAccessibility.first_unlock),
              webOptions: WebOptions(dbName: 'bth_ecommerce', publicKey: 'bth_ecommerce_key'),
            );

  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    try {
      await Future.wait([
        _storage.write(key: _keyAccessToken, value: accessToken),
        _storage.write(key: _keyRefreshToken, value: refreshToken),
      ]);
    } catch (_) {
      _memoryFallback[_keyAccessToken] = accessToken;
      _memoryFallback[_keyRefreshToken] = refreshToken;
    }
  }

  Future<String?> getAccessToken() async {
    try {
      final token = await _storage.read(key: _keyAccessToken);
      return token ?? _memoryFallback[_keyAccessToken];
    } catch (_) {
      return _memoryFallback[_keyAccessToken];
    }
  }

  Future<String?> getRefreshToken() async {
    try {
      final token = await _storage.read(key: _keyRefreshToken);
      return token ?? _memoryFallback[_keyRefreshToken];
    } catch (_) {
      return _memoryFallback[_keyRefreshToken];
    }
  }

  Future<void> saveDeviceId(String deviceId) async {
    try {
      await _storage.write(key: _keyDeviceId, value: deviceId);
    } catch (_) {
      _memoryFallback[_keyDeviceId] = deviceId;
    }
  }

  Future<String?> getDeviceId() async {
    try {
      return await _storage.read(key: _keyDeviceId) ?? _memoryFallback[_keyDeviceId];
    } catch (_) {
      return _memoryFallback[_keyDeviceId];
    }
  }

  Future<void> clearAuth() async {
    _memoryFallback.remove(_keyAccessToken);
    _memoryFallback.remove(_keyRefreshToken);
    try {
      await Future.wait([
        _storage.delete(key: _keyAccessToken),
        _storage.delete(key: _keyRefreshToken),
      ]);
    } catch (_) {}
  }

  Future<void> clearAll() async {
    _memoryFallback.clear();
    try {
      await _storage.deleteAll();
    } catch (_) {}
  }
}
