import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/cart/presentation/screens/cart_screen.dart';
import '../features/checkout/presentation/screens/checkout_screen.dart';
import '../features/checkout/presentation/screens/order_success_screen.dart';
import '../features/order/presentation/screens/order_detail_screen.dart';
import '../features/order/presentation/screens/order_list_screen.dart';
import '../features/product/presentation/screens/home_screen.dart';
import '../features/product/presentation/screens/product_detail_screen.dart';
import '../features/product/presentation/screens/product_list_screen.dart';
import '../features/profile/presentation/screens/address_book_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import 'app_coordinator.dart';
import 'app_routes.dart';
import 'main_scaffold.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: AppCoordinator.navigatorKey,
    initialLocation: AppRoutes.home,
    routes: [
      // Stateful shell route for persistent bottom navigation
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScaffold(navigationShell: navigationShell);
        },
        branches: [
          // Tab 0: Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),

          // Tab 1: Products
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.products,
                builder: (context, state) {
                  final category = state.uri.queryParameters['category'];
                  final search = state.uri.queryParameters['search'];
                  return ProductListScreen(
                    initialCategory: category,
                    initialSearch: search,
                  );
                },
              ),
            ],
          ),

          // Tab 2: Cart
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.cart,
                builder: (context, state) => const CartScreen(),
              ),
            ],
          ),

          // Tab 3: Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // Product Detail (Pushed over tabs)
      GoRoute(
        path: AppRoutes.productDetail,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return ProductDetailScreen(productId: id);
        },
      ),

      // Auth Routes
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),

      // Checkout Flow
      GoRoute(
        path: AppRoutes.checkout,
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: AppRoutes.orderSuccess,
        builder: (context, state) {
          final orderId = state.uri.queryParameters['orderId'] ?? '';
          return OrderSuccessScreen(orderId: orderId);
        },
      ),

      // Order History & Tracking
      GoRoute(
        path: AppRoutes.orders,
        builder: (context, state) => const OrderListScreen(),
      ),
      GoRoute(
        path: AppRoutes.orderDetail,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return OrderDetailScreen(orderId: id);
        },
      ),

      // Profile Sub-Screens
      GoRoute(
        path: AppRoutes.addressList,
        builder: (context, state) => const AddressBookScreen(),
      ),
    ],
  );
});
