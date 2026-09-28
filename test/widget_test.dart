import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecommerce_mobile/core/providers/core_providers.dart';
import 'package:ecommerce_mobile/core/storage/preference_storage.dart';
import 'package:ecommerce_mobile/features/auth/presentation/auth_controller.dart';
import 'package:ecommerce_mobile/features/product/data/product_repository.dart';
import 'package:ecommerce_mobile/core/network/api_response.dart';
import 'package:ecommerce_mobile/features/product/data/models/product_model.dart';
import 'package:ecommerce_mobile/main.dart';

class FakeProductRepository implements ProductRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #getProducts) {
      return Future.value(
        const PaginatedResponse<ProductModel>(
          items: [],
          total: 0,
          page: 1,
          limit: 10,
          totalPages: 0,
        ),
      );
    }
    if (invocation.memberName == #getCategories) {
      return Future.value(<CategoryModel>[]);
    }
    return super.noSuchMethod(invocation);
  }
}

class FakeAuthNotifier extends AuthNotifier {
  @override
  AuthState build() {
    return const AuthState(status: AuthStatus.unauthenticated);
  }
}

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferenceStorage = await PreferenceStorage.create();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          preferenceStorageProvider.overrideWithValue(preferenceStorage),
          authProvider.overrideWith(() => FakeAuthNotifier()),
          productRepositoryProvider.overrideWithValue(FakeProductRepository()),
        ],
        child: const BthEcommerceApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(BthEcommerceApp), findsOneWidget);
    expect(find.text('BTH Store'), findsOneWidget);
    expect(find.text('Trang chủ'), findsOneWidget);
    expect(find.text('Sản phẩm'), findsOneWidget);
    expect(find.text('Giỏ hàng'), findsOneWidget);
    expect(find.text('Tài khoản'), findsOneWidget);
  });
}
