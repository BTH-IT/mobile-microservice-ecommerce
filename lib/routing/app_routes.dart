class AppRoutes {
  AppRoutes._();

  // Root Tabs
  static const String home = '/';
  static const String products = '/products';
  static const String cart = '/cart';
  static const String profile = '/profile';

  // Details & Modals
  static const String productDetail = '/products/:id';
  static String productDetailPath(String id) => '/products/$id';

  static const String checkout = '/checkout';
  static String checkoutPath(String sessionId) => '/checkout?sessionId=$sessionId';

  static const String orderSuccess = '/order-success';
  static String orderSuccessPath(String orderId) => '/order-success?orderId=$orderId';

  static const String orders = '/orders';
  static const String orderDetail = '/orders/:id';
  static String orderDetailPath(String id) => '/orders/$id';

  // Auth
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // Profile Sub-screens
  static const String addressList = '/profile/addresses';
  static const String addressEdit = '/profile/addresses/edit';
}
