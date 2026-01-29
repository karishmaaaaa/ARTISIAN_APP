import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/order_model.dart';
import '../../../models/cart_model.dart';
import '../../../repositories/order_repository.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/result.dart';
import '../../auth/providers/auth_provider.dart';

/// Provider for the OrderRepository instance
final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository();
});

/// Stream provider for artisan's orders
final artisanOrdersStreamProvider = StreamProvider<List<OrderModel>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null || !user.isArtisan) {
    return const Stream.empty();
  }
  
  final repo = ref.watch(orderRepositoryProvider);
  return repo.artisanOrdersStream(user.id);
});

/// Stream provider for customer's orders
final customerOrdersStreamProvider = StreamProvider<List<OrderModel>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null || !user.isCustomer) {
    return const Stream.empty();
  }
  
  final repo = ref.watch(orderRepositoryProvider);
  return repo.customerOrdersStream(user.id);
});

/// Provider for a single order
final orderProvider = FutureProvider.family<OrderModel?, String>(
  (ref, orderId) async {
    final repo = ref.watch(orderRepositoryProvider);
    final result = await repo.getOrder(orderId);
    return result.dataOrNull;
  },
);

/// Provider for artisan dashboard stats
final artisanOrderStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null || !user.isArtisan) {
    return {};
  }
  
  final repo = ref.watch(orderRepositoryProvider);
  final result = await repo.getArtisanOrderStats(user.id);
  return result.getOrElse({});
});

/// State for order list with filtering
class OrderListState {
  final List<OrderModel> orders;
  final bool isLoading;
  final bool hasMore;
  final String? error;
  final OrderStatus? statusFilter;

  const OrderListState({
    this.orders = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.error,
    this.statusFilter,
  });

  OrderListState copyWith({
    List<OrderModel>? orders,
    bool? isLoading,
    bool? hasMore,
    String? error,
    OrderStatus? statusFilter,
  }) {
    return OrderListState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error,
      statusFilter: statusFilter ?? this.statusFilter,
    );
  }
}

/// Notifier for artisan orders with filtering
class ArtisanOrdersNotifier extends StateNotifier<OrderListState> {
  final OrderRepository _repository;
  final String _artisanId;

  ArtisanOrdersNotifier(this._repository, this._artisanId) 
      : super(const OrderListState()) {
    loadOrders();
  }

  Future<void> loadOrders({bool refresh = false}) async {
    if (state.isLoading) return;

    state = state.copyWith(
      isLoading: true,
      error: null,
      orders: refresh ? [] : state.orders,
    );

    final result = await _repository.getArtisanOrders(
      _artisanId,
      status: state.statusFilter,
    );

    result.when(
      success: (orders) {
        state = state.copyWith(
          orders: orders,
          isLoading: false,
          hasMore: orders.length >= AppConstants.ordersPerPage,
        );
      },
      failure: (error) {
        state = state.copyWith(
          isLoading: false,
          error: error.message,
        );
      },
    );
  }

  void setStatusFilter(OrderStatus? status) {
    state = state.copyWith(statusFilter: status);
    loadOrders(refresh: true);
  }
}

/// Provider for artisan orders with filtering
final artisanOrdersNotifierProvider = StateNotifierProvider.family<
    ArtisanOrdersNotifier, OrderListState, String>((ref, artisanId) {
  final repo = ref.watch(orderRepositoryProvider);
  return ArtisanOrdersNotifier(repo, artisanId);
});

/// Controller for order operations
class OrderController {
  final OrderRepository _repository;

  OrderController(this._repository);

  /// Create orders from cart
  Future<Result<List<OrderModel>>> createOrdersFromCart({
    required String customerId,
    required CartModel cart,
    required ShippingAddress shippingAddress,
    String? notes,
  }) {
    return _repository.createOrdersFromCart(
      customerId: customerId,
      cart: cart,
      shippingAddress: shippingAddress,
      notes: notes,
    );
  }

  /// Update order status (for artisans)
  Future<Result<OrderModel>> updateOrderStatus({
    required String orderId,
    required OrderStatus newStatus,
    String? trackingNumber,
  }) {
    return _repository.updateOrderStatus(
      orderId: orderId,
      newStatus: newStatus,
      trackingNumber: trackingNumber,
    );
  }

  /// Cancel an order
  Future<Result<OrderModel>> cancelOrder({
    required String orderId,
    String? reason,
  }) {
    return _repository.cancelOrder(orderId: orderId, reason: reason);
  }
}

/// Provider for order controller
final orderControllerProvider = Provider<OrderController>((ref) {
  final repo = ref.watch(orderRepositoryProvider);
  return OrderController(repo);
});

/// Provider for pending orders count (for badges)
final pendingOrdersCountProvider = Provider<int>((ref) {
  final ordersAsync = ref.watch(artisanOrdersStreamProvider);
  return ordersAsync.when(
    data: (orders) => orders.where((o) => o.status == OrderStatus.pending).length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});
