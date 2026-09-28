import 'package:flutter/foundation.dart';

class Env {
  Env._();

  /// Default API root pointing to NestJS API Gateway
  /// - Android Emulator: 10.0.2.2:3300/api/v1
  /// - iOS Simulator / macOS / Web: localhost:3300/api/v1
  /// - Can be overridden via --dart-define=API_URL=https://...
  static String get apiBaseUrl {
    const definedUrl = String.fromEnvironment('API_URL');
    if (definedUrl.isNotEmpty) {
      return definedUrl;
    }

    if (kIsWeb) {
      return 'http://localhost:3300/api/v1';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3300/api/v1';
    }

    return 'http://localhost:3300/api/v1';
  }

  static const int connectTimeoutSeconds = 15;
  static const int receiveTimeoutSeconds = 15;
  static const int sendTimeoutSeconds = 15;

  static const String appName = 'BTH Ecommerce';
  static const String appVersion = '1.0.0';
  static const String deepLinkScheme = 'bthecommerce';
}
