enum AppRouteNames {
  home(path: '/', routeName: 'home'),
  products(path: '/products', routeName: 'products'),
  productDetail(path: '/products/:id', routeName: 'productDetail', paramName: 'id'),
  cart(path: '/cart', routeName: 'cart'),
  checkout(path: '/checkout', routeName: 'checkout'),
  orderSuccess(path: '/order-success', routeName: 'orderSuccess'),
  orders(path: '/orders', routeName: 'orders'),
  orderDetail(path: '/orders/:id', routeName: 'orderDetail', paramName: 'id'),
  profile(path: '/profile', routeName: 'profile'),
  addressList(path: '/profile/addresses', routeName: 'addressList'),
  login(path: '/login', routeName: 'login'),
  register(path: '/register', routeName: 'register');

  const AppRouteNames({
    required this.path,
    this.routeName,
    this.paramName,
  });

  final String path;
  final String? routeName;
  final String? paramName;

  String get name => routeName ?? path.replaceAll('/', '');
}
