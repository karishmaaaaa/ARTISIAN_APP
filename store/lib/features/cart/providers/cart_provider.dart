import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/cart_model.dart';
import '../../../models/product_model.dart';
import '../../../repositories/cart_repository.dart';
import '../../../core/errors/result.dart';
import '../../auth/providers/auth_provider.dart';

/// Provider for the CartRepository instance
final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return CartRepository();
});

/// Stream provider for current user's cart
final cartStreamProvider = StreamProvider<CartModel>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return Stream.value(CartModel.empty(''));
  }
  
  final repo = ref.watch(cartRepositoryProvider);
  return repo.cartStream(user.id);
});

/// Provider for cart item count (for badge display)
final cartItemCountProvider = Provider<int>((ref) {
  final cartAsync = ref.watch(cartStreamProvider);
  return cartAsync.when(
    data: (cart) => cart.totalItems,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

/// Provider for cart subtotal
final cartSubtotalProvider = Provider<double>((ref) {
  final cartAsync = ref.watch(cartStreamProvider);
  return cartAsync.when(
    data: (cart) => cart.subtotal,
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
});

/// State for cart operations
class CartState {
  final CartModel? cart;
  final bool isLoading;
  final String? error;
  final String? successMessage;

  const CartState({
    this.cart,
    this.isLoading = false,
    this.error,
    this.successMessage,
  });

  CartState copyWith({
    CartModel? cart,
    bool? isLoading,
    String? error,
    String? successMessage,
  }) {
    return CartState(
      cart: cart ?? this.cart,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: successMessage,
    );
  }
}

/// Notifier for cart operations
class CartNotifier extends StateNotifier<CartState> {
  final CartRepository _repository;
  final String _customerId;

  CartNotifier(this._repository, this._customerId) : super(const CartState()) {
    _init();
  }

  Future<void> _init() async {
    if (_customerId.isEmpty) return;
    
    state = state.copyWith(isLoading: true);
    final result = await _repository.getOrCreateCart(_customerId);
    result.when(
      success: (cart) => state = state.copyWith(cart: cart, isLoading: false),
      failure: (e) => state = state.copyWith(error: e.message, isLoading: false),
    );
  }

  /// Add item to cart
  Future<bool> addToCart({
    required ProductModel product,
    int quantity = 1,
    Map<String, dynamic>? selectedAttributes,
  }) async {
    state = state.copyWith(isLoading: true, error: null, successMessage: null);

    final result = await _repository.addToCart(
      customerId: _customerId,
      product: product,
      quantity: quantity,
      selectedAttributes: selectedAttributes,
    );

    return result.when(
      success: (cart) {
        state = state.copyWith(
          cart: cart,
          isLoading: false,
          successMessage: '${product.name} added to cart',
        );
        return true;
      },
      failure: (e) {
        state = state.copyWith(isLoading: false, error: e.message);
        return false;
      },
    );
  }

  /// Update item quantity
  Future<bool> updateQuantity({
    required String productId,
    required int quantity,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.updateCartItemQuantity(
      customerId: _customerId,
      productId: productId,
      quantity: quantity,
    );

    return result.when(
      success: (cart) {
        state = state.copyWith(cart: cart, isLoading: false);
        return true;
      },
      failure: (e) {
        state = state.copyWith(isLoading: false, error: e.message);
        return false;
      },
    );
  }

  /// Remove item from cart
  Future<bool> removeFromCart(String productId) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.removeFromCart(
      customerId: _customerId,
      productId: productId,
    );

    return result.when(
      success: (cart) {
        state = state.copyWith(cart: cart, isLoading: false);
        return true;
      },
      failure: (e) {
        state = state.copyWith(isLoading: false, error: e.message);
        return false;
      },
    );
  }

  /// Clear the cart
  Future<bool> clearCart() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.clearCart(_customerId);

    return result.when(
      success: (cart) {
        state = state.copyWith(cart: cart, isLoading: false);
        return true;
      },
      failure: (e) {
        state = state.copyWith(isLoading: false, error: e.message);
        return false;
      },
    );
  }

  /// Validate cart before checkout
  Future<bool> validateCart() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.validateCart(_customerId);

    return result.when(
      success: (cart) {
        state = state.copyWith(cart: cart, isLoading: false);
        return true;
      },
      failure: (e) {
        state = state.copyWith(isLoading: false, error: e.message);
        return false;
      },
    );
  }

  /// Clear messages
  void clearMessages() {
    state = state.copyWith(error: null, successMessage: null);
  }
}

/// Provider for cart notifier
final cartNotifierProvider =
    StateNotifierProvider<CartNotifier, CartState>((ref) {
  final user = ref.watch(currentUserProvider);
  final repo = ref.watch(cartRepositoryProvider);
  return CartNotifier(repo, user?.id ?? '');
});

/// Convenience provider to check if a product is in cart
final isInCartProvider = Provider.family<bool, String>((ref, productId) {
  final cartAsync = ref.watch(cartStreamProvider);
  return cartAsync.when(
    data: (cart) => cart.items.any((item) => item.productId == productId),
    loading: () => false,
    error: (_, __) => false,
  );
});

/// Get quantity of a specific product in cart
final cartItemQuantityProvider = Provider.family<int, String>((ref, productId) {
  final cartAsync = ref.watch(cartStreamProvider);
  return cartAsync.when(
    data: (cart) {
      final item = cart.items.where((i) => i.productId == productId).firstOrNull;
      return item?.quantity ?? 0;
    },
    loading: () => 0,
    error: (_, __) => 0,
  );
});
