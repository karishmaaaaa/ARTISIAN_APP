import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../core/constants/app_constants.dart';
import '../core/errors/failures.dart';
import '../core/errors/result.dart';
import '../models/order_model.dart';
import '../models/cart_model.dart';

/// Repository for order management operations.
/// 
/// Handles order creation, status updates, and queries
/// for both artisans and customers.
class OrderRepository {
  final FirebaseFirestore _firestore;
  final Uuid _uuid;
  
  OrderRepository({
    FirebaseFirestore? firestore,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _uuid = const Uuid();
  
  /// Collection reference for orders
  CollectionReference<Map<String, dynamic>> get _ordersRef =>
      _firestore.collection(AppConstants.ordersCollection);
  
  /// Create orders from cart items (one order per artisan)
  Future<Result<List<OrderModel>>> createOrdersFromCart({
    required String customerId,
    required CartModel cart,
    required ShippingAddress shippingAddress,
    String? notes,
  }) async {
    try {
      final orders = <OrderModel>[];
      final batch = _firestore.batch();
      final now = DateTime.now();
      
      // Group cart items by artisan
      final itemsByArtisan = cart.itemsByArtisan;
      
      for (final entry in itemsByArtisan.entries) {
        final artisanId = entry.key;
        final items = entry.value;
        
        // Calculate totals for this order
        final subtotal = items.fold<double>(
          0.0,
          (sum, item) => sum + item.subtotal,
        );
        
        // You can implement shipping cost calculation logic here
        const shippingCost = 0.0;
        final tax = subtotal * 0.0; // Implement tax calculation as needed
        final total = subtotal + shippingCost + tax;
        
        final orderId = _uuid.v4();
        
        final order = OrderModel(
          id: orderId,
          customerId: customerId,
          artisanId: artisanId,
          items: items.map((item) => OrderItem(
            productId: item.productId,
            productName: item.productName,
            productImageUrl: item.productImageUrl,
            price: item.price,
            quantity: item.quantity,
            selectedAttributes: item.selectedAttributes,
          )).toList(),
          subtotal: subtotal,
          shippingCost: shippingCost,
          tax: tax,
          total: total,
          status: OrderStatus.pending,
          shippingAddress: shippingAddress,
          notes: notes,
          createdAt: now,
          updatedAt: now,
        );
        
        orders.add(order);
        batch.set(_ordersRef.doc(orderId), order.toJson());
        
        // Update artisan stats
        final artisanRef = _firestore
            .collection(AppConstants.artisansCollection)
            .doc(artisanId);
        batch.update(artisanRef, {
          'totalOrders': FieldValue.increment(1),
          'updatedAt': Timestamp.fromDate(now),
        });
        
        // Update product stock for each item
        for (final item in items) {
          final productRef = _firestore
              .collection(AppConstants.productsCollection)
              .doc(item.productId);
          batch.update(productRef, {
            'stockQuantity': FieldValue.increment(-item.quantity),
            'totalSold': FieldValue.increment(item.quantity),
            'updatedAt': Timestamp.fromDate(now),
          });
        }
      }
      
      // Clear the cart
      final cartRef = _firestore
          .collection(AppConstants.cartCollection)
          .doc(customerId);
      batch.update(cartRef, {
        'items': [],
        'updatedAt': Timestamp.fromDate(now),
      });
      
      await batch.commit();
      
      return Result.success(orders);
    } catch (e) {
      return Result.failure(DatabaseFailure.fromFirestore(e));
    }
  }
  
  /// Update order status
  Future<Result<OrderModel>> updateOrderStatus({
    required String orderId,
    required OrderStatus newStatus,
    String? trackingNumber,
  }) async {
    try {
      final now = DateTime.now();
      
      final updates = <String, dynamic>{
        'status': newStatus.value,
        'updatedAt': Timestamp.fromDate(now),
        if (trackingNumber != null) 'trackingNumber': trackingNumber,
      };
      
      // Set timestamps for specific status changes
      if (newStatus == OrderStatus.shipped) {
        updates['shippedAt'] = Timestamp.fromDate(now);
      } else if (newStatus == OrderStatus.completed) {
        updates['completedAt'] = Timestamp.fromDate(now);
        
        // Update artisan's total sales
        final orderDoc = await _ordersRef.doc(orderId).get();
        if (orderDoc.exists) {
          final order = OrderModel.fromFirestore(orderDoc);
          await _firestore
              .collection(AppConstants.artisansCollection)
              .doc(order.artisanId)
              .update({
            'totalSales': FieldValue.increment(order.total),
          });
        }
      }
      
      await _ordersRef.doc(orderId).update(updates);
      
      // Fetch updated order
      final doc = await _ordersRef.doc(orderId).get();
      return Result.success(OrderModel.fromFirestore(doc));
    } catch (e) {
      return Result.failure(DatabaseFailure.fromFirestore(e));
    }
  }
  
  /// Cancel an order
  Future<Result<OrderModel>> cancelOrder({
    required String orderId,
    String? reason,
  }) async {
    try {
      final orderDoc = await _ordersRef.doc(orderId).get();
      
      if (!orderDoc.exists) {
        return Result.failure(
          const DatabaseFailure(message: 'Order not found'),
        );
      }
      
      final order = OrderModel.fromFirestore(orderDoc);
      
      if (!order.canBeCancelled) {
        return Result.failure(
          const DatabaseFailure(message: 'This order cannot be cancelled'),
        );
      }
      
      final now = DateTime.now();
      final batch = _firestore.batch();
      
      // Update order status
      batch.update(_ordersRef.doc(orderId), {
        'status': OrderStatus.cancelled.value,
        'updatedAt': Timestamp.fromDate(now),
        if (reason != null) 'cancellationReason': reason,
      });
      
      // Restore product stock
      for (final item in order.items) {
        final productRef = _firestore
            .collection(AppConstants.productsCollection)
            .doc(item.productId);
        batch.update(productRef, {
          'stockQuantity': FieldValue.increment(item.quantity),
          'totalSold': FieldValue.increment(-item.quantity),
          'updatedAt': Timestamp.fromDate(now),
        });
      }
      
      // Update artisan stats
      batch.update(
        _firestore
            .collection(AppConstants.artisansCollection)
            .doc(order.artisanId),
        {
          'totalOrders': FieldValue.increment(-1),
          'updatedAt': Timestamp.fromDate(now),
        },
      );
      
      await batch.commit();
      
      // Fetch updated order
      final updatedDoc = await _ordersRef.doc(orderId).get();
      return Result.success(OrderModel.fromFirestore(updatedDoc));
    } catch (e) {
      return Result.failure(DatabaseFailure.fromFirestore(e));
    }
  }
  
  /// Get a single order by ID
  Future<Result<OrderModel>> getOrder(String orderId) async {
    try {
      final doc = await _ordersRef.doc(orderId).get();
      
      if (!doc.exists) {
        return Result.failure(
          const DatabaseFailure(message: 'Order not found'),
        );
      }
      
      return Result.success(OrderModel.fromFirestore(doc));
    } catch (e) {
      return Result.failure(DatabaseFailure.fromFirestore(e));
    }
  }
  
  /// Get orders for a customer
  Future<Result<List<OrderModel>>> getCustomerOrders(
    String customerId, {
    int limit = AppConstants.ordersPerPage,
    DocumentSnapshot? startAfter,
    OrderStatus? status,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _ordersRef
          .where('customerId', isEqualTo: customerId)
          .orderBy('createdAt', descending: true)
          .limit(limit);
      
      if (status != null) {
        query = query.where('status', isEqualTo: status.value);
      }
      
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }
      
      final snapshot = await query.get();
      final orders = snapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc))
          .toList();
      
      return Result.success(orders);
    } catch (e) {
      return Result.failure(DatabaseFailure.fromFirestore(e));
    }
  }
  
  /// Get orders for an artisan
  Future<Result<List<OrderModel>>> getArtisanOrders(
    String artisanId, {
    int limit = AppConstants.ordersPerPage,
    DocumentSnapshot? startAfter,
    OrderStatus? status,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _ordersRef
          .where('artisanId', isEqualTo: artisanId)
          .orderBy('createdAt', descending: true)
          .limit(limit);
      
      if (status != null) {
        query = query.where('status', isEqualTo: status.value);
      }
      
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }
      
      final snapshot = await query.get();
      final orders = snapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc))
          .toList();
      
      return Result.success(orders);
    } catch (e) {
      return Result.failure(DatabaseFailure.fromFirestore(e));
    }
  }
  
  /// Stream of orders for artisan
  Stream<List<OrderModel>> artisanOrdersStream(String artisanId) {
    return _ordersRef
        .where('artisanId', isEqualTo: artisanId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromFirestore(doc))
            .toList());
  }
  
  /// Stream of orders for customer
  Stream<List<OrderModel>> customerOrdersStream(String customerId) {
    return _ordersRef
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromFirestore(doc))
            .toList());
  }
  
  /// Get order statistics for artisan dashboard
  Future<Result<Map<String, dynamic>>> getArtisanOrderStats(
    String artisanId,
  ) async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      
      // Get all orders for this artisan
      final snapshot = await _ordersRef
          .where('artisanId', isEqualTo: artisanId)
          .get();
      
      final orders = snapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc))
          .toList();
      
      // Calculate statistics
      final pendingOrders = orders.where((o) => o.status == OrderStatus.pending).length;
      final completedOrders = orders.where((o) => o.status == OrderStatus.completed).length;
      final totalRevenue = orders
          .where((o) => o.status == OrderStatus.completed)
          .fold<double>(0.0, (sum, o) => sum + o.total);
      
      // This month's orders
      final thisMonthOrders = orders
          .where((o) => o.createdAt.isAfter(startOfMonth))
          .toList();
      final thisMonthRevenue = thisMonthOrders
          .where((o) => o.status == OrderStatus.completed)
          .fold<double>(0.0, (sum, o) => sum + o.total);
      
      return Result.success({
        'totalOrders': orders.length,
        'pendingOrders': pendingOrders,
        'completedOrders': completedOrders,
        'totalRevenue': totalRevenue,
        'thisMonthOrders': thisMonthOrders.length,
        'thisMonthRevenue': thisMonthRevenue,
      });
    } catch (e) {
      return Result.failure(DatabaseFailure.fromFirestore(e));
    }
  }
}
