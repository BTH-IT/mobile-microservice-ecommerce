class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh-token';
  static const String profile = '/auth/profile';
  static const String logout = '/auth/logout';
  static const String googleAuth = '/auth/google';
  static const String forgotPassword = '/auth/forgot-password';

  // Catalog
  static const String products = '/products';
  static String productDetail(String id) => '/products/$id';
  static String productBySlug(String slug) => '/products/slug/$slug';
  static const String categories = '/categories';
  static const String brands = '/brands';

  // Cart
  static const String cart = '/cart';
  static const String cartItems = '/cart/items';
  static String cartItem(String itemId) => '/cart/items/$itemId';

  // Checkout
  static const String checkoutSessions = '/checkout/sessions';
  static String checkoutSession(String sessionId) => '/checkout/sessions/$sessionId';
  static String confirmCheckout(String sessionId) => '/checkout/sessions/$sessionId/confirm';

  // Orders
  static const String orders = '/orders';
  static String orderDetail(String orderId) => '/orders/$orderId';
  static String cancelOrder(String orderId) => '/orders/$orderId/cancel';

  // User & Addresses
  static const String userAddresses = '/users/me/addresses';
  static String userAddress(String id) => '/users/me/addresses/$id';
  static String setDefaultAddress(String id) => '/users/me/addresses/$id/default';

  // Administrative / Public Address (Vietnam Administrative Units)
  static const String provinces = '/public-address/provinces';
  static String districts(String provinceCode) => '/public-address/districts?provinceCode=$provinceCode';
  static String wards(String districtCode) => '/public-address/wards?districtCode=$districtCode';

  // Media
  static const String uploadMedia = '/media/upload';
}
