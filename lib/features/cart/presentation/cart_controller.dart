import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/cart_repository.dart';
import '../data/models/cart_model.dart';

class CartState {
  final bool isLoading;
  final CartModel cart;
  final String? errorMessage;

  const CartState({
    this.isLoading = false,
    this.cart = const CartModel(),
    this.errorMessage,
  });

  int get itemCount => cart.totalQuantity;
  bool get isEmpty => cart.isEmpty;

  CartState copyWith({
    bool? isLoading,
    CartModel? cart,
    String? errorMessage,
  }) {
    return CartState(
      isLoading: isLoading ?? this.isLoading,
      cart: cart ?? this.cart,
      errorMessage: errorMessage,
    );
  }
}

class CartNotifier extends Notifier<CartState> {
  CartRepository get _cartRepository => ref.read(cartRepositoryProvider);

  @override
  CartState build() {
    final authState = ref.watch(authProvider);

    // Only load cart when user is authenticated (matching web logic)
    if (authState.isAuthenticated) {
      Future.microtask(() => loadCart());
    }

    return const CartState();
  }

  Future<void> loadCart() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final cart = await _cartRepository.getCart();
      state = state.copyWith(isLoading: false, cart: cart);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> addToCart({
    required String productId,
    String? variantId,
    int quantity = 1,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final updatedCart = await _cartRepository.addItem(
        productId: productId,
        variantId: variantId,
        quantity: quantity,
      );
      state = state.copyWith(isLoading: false, cart: updatedCart);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<void> updateQuantityDelta(String itemId, int delta) async {
    try {
      final updatedCart = await _cartRepository.updateItemQuantity(
        itemId: itemId,
        delta: delta,
      );
      state = state.copyWith(cart: updatedCart);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> removeItem(String itemId) async {
    try {
      final updatedCart = await _cartRepository.removeItem(itemId);
      state = state.copyWith(cart: updatedCart);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> clearCart() async {
    try {
      await _cartRepository.clearCart();
      state = const CartState(cart: CartModel());
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }
}

final cartProvider = NotifierProvider<CartNotifier, CartState>(() {
  return CartNotifier();
});
