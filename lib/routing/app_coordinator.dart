import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_routes.dart';

/// Centralized, type-safe navigation coordinator following GoldenOwl template
class AppCoordinator {
  AppCoordinator._();

  static final navigatorKey = GlobalKey<NavigatorState>(debugLabel: 'rootNav');

  static BuildContext get context => navigatorKey.currentState!.context;

  static void pop<T extends Object?>([T? result]) {
    if (context.canPop()) {
      context.pop(result);
    }
  }

  static void showHome() => context.go(AppRoutes.home);

  static void showProducts({String? category, String? search}) {
    final queryParams = <String, String>{
      if (category != null && category.isNotEmpty) 'category': category,
      if (search != null && search.isNotEmpty) 'search': search,
    };
    final uri = Uri(path: AppRoutes.products, queryParameters: queryParams.isEmpty ? null : queryParams);
    context.go(uri.toString());
  }

  static void showProductDetail(String id) {
    context.push(AppRoutes.productDetailPath(id));
  }

  static void showCart() => context.go(AppRoutes.cart);

  static void showCheckout() => context.push(AppRoutes.checkout);

  static void showOrderSuccess(String orderId) {
    context.go(AppRoutes.orderSuccessPath(orderId));
  }

  static void showOrders() => context.push(AppRoutes.orders);

  static void showOrderDetail(String id) {
    context.push(AppRoutes.orderDetailPath(id));
  }

  static void showProfile() => context.go(AppRoutes.profile);

  static void showAddressList() => context.push(AppRoutes.addressList);

  static void showLogin() => context.push(AppRoutes.login);

  static void showRegister() => context.push(AppRoutes.register);
}
