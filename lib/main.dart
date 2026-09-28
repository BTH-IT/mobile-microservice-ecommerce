import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/theme/app_screens.dart';
import 'config/theme/app_theme.dart';
import 'core/providers/core_providers.dart';
import 'core/storage/preference_storage.dart';
import 'routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize persistent storage before running the app
  final preferenceStorage = await PreferenceStorage.create();

  runApp(
    ProviderScope(
      overrides: [
        preferenceStorageProvider.overrideWithValue(preferenceStorage),
      ],
      child: const BthEcommerceApp(),
    ),
  );
}

class BthEcommerceApp extends ConsumerWidget {
  const BthEcommerceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'BTH Ecommerce',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
      builder: (context, child) {
        AppScreens.init(context);
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
