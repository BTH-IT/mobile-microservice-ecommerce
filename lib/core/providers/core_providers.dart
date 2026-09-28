import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/api_client.dart';
import '../storage/preference_storage.dart';
import '../storage/secure_storage.dart';

final secureStorageProvider = Provider<SecureStorage>((ref) {
  return SecureStorage();
});

/// Overridden in main.dart after SharedPreferences.getInstance() resolves
final preferenceStorageProvider = Provider<PreferenceStorage>((ref) {
  throw UnimplementedError('preferenceStorageProvider must be initialized in main');
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return ApiClient(
    secureStorage: secureStorage,
    onSessionExpired: () {
      // Session expired handling can trigger authState changes
    },
  );
});
