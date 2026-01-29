import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/app_constants.dart';
import '../core/errors/failures.dart';
import '../core/errors/result.dart';
import '../models/cart_model.dart';
import '../models/product_model.dart';

/// Repository for shopping cart operations.
/// 
/// Handles cart CRUD operations with real-time synchronization
/// and stock validation.
class CartRepository {
  final FirebaseFirestore _firestore;
  
  CartRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;
  
  /// Collection reference for carts
  CollectionReference<Map<String, dynamic>> get _cartRef =>
      _firestore.collection(AppConstants.cartCollection);
  
  /// Get or create cart for a customer
  Future<Result<CartModel>> getOrCreateCart(String customerId) async {
    try {
      final doc = await _cartRef.doc(customerId).get();
      
      if (doc.exists) {
        return Result.success(CartModel.fromFirestore(doc));
      }
      
      // Create empty cart
      final cart = CartModel.empty(customerId);
      await _cartRef.doc(customerId).set(cart.toJson());
      
      return Result.success(cart);
    } catch (e) {
      return Result.failure(DatabaseFailure.fromFirestore(e));
    }
  }
  
  /// Add item to cart
  Future<Result<CartModel>> addToCart({
    required String customerId,
    required ProductModel product,
    int quantity = 1,
    Map<String, dynamic>? selectedAttributes,
  }) async {
    try {
      // Get current cart
      final cartResult = await getOrCreateCart(customerId);
      if (cartResult.isFailure) {
        return cartResult;
      }
      
      final cart = cartResult.data;
      final items = List<CartItem>.from(cart.items);
      
      // Check if product already in cart
      final existingIndex = items.indexWhere(
        (item) => item.productId == product.id,
      );
      
      if (existingIndex >= 0) {
        // Update quantity
        final existingItem = items[existingIndex];
        final newQuantity = existingItem.quantity + quantity;
        
        // Check stock
        if (newQuantity > product.stockQuantity) {
          return Result.failure(
            ValidationFailure(
              message: 'Only ${product.stockQuantity} items available',
            ),
          );
        }
        
        items[existingIndex] = existingItem.copyWith(
          quantity: newQuantity,
          price: product.price, // Update price in case it changed
          availableStock: product.stockQuantity,
        );
      } else {
        // Check stock
        if (quantity > product.stockQuantity) {
          return Result.failure(
            ValidationFailure(
              message: 'Only ${product.stockQuantity} items available',
            ),
          );
        }
        
        // Add new item
        items.add(CartItem(
          productId: product.id,
          artisanId: product.artisanId,
          productName: product.name,
          productImageUrl: product.primaryImageUrl,
          price: product.price,
          quantity: quantity,
          availableStock: product.stockQuantity,
          selectedAttributes: selectedAttributes,
        ));
      }
      
      // Update cart in Firestore
      final updatedCart = cart.copyWith(
        items: items,
        updatedAt: DateTime.now(),
      );
      
      await _cartRef.doc(customerId).update(updatedCart.toJson());
      
      return Result.success(updatedCart);
    } catch (e) {
      return Result.failure(DatabaseFailure.fromFirestore(e));
    }
  }
  
  /// Update item quantity in cart
  Future<Result<CartModel>> updateCartItemQuantity({
    required String customerId,
    required String productId,
    required int quantity,
  }) async {
    try {
      final cartResult = await getOrCreateCart(customerId);
      if (cartResult.isFailure) {
        return cartResult;
      }
      
      final cart = cartResult.data;
      final items = List<CartItem>.from(cart.items);
      
      final itemIndex = items.indexWhere(
        (item) => item.productId == productId,
      );
      
      if (itemIndex < 0) {
        return Result.failure(
          const DatabaseFailure(message: 'Item not found in cart'),
        );
      }
      
      if (quantity <= 0) {
        // Remove item
        items.removeAt(itemIndex);
      } else {
        // Check stock
        final item = items[itemIndex];
        if (quantity > item.availableStock) {
          return Result.failure(
            ValidationFailure(
              message: 'Only ${item.availableStock} items available',
            ),
          );
        }
        
        items[itemIndex] = item.copyWith(quantity: quantity);
      }
      
      final updatedCart = cart.copyWith(
        items: items,
        updatedAt: DateTime.now(),
      );
      
      await _cartRef.doc(customerId).update(updatedCart.toJson());
      
      return Result.success(updatedCart);
    } catch (e) {
      return Result.failure(DatabaseFailure.fromFirestore(e));
    }
  }
  
  /// Remove item from cart
  Future<Result<CartModel>> removeFromCart({
    required String customerId,
    required String productId,
  }) async {
    return updateCartItemQuantity(
      customerId: customerId,
      productId: productId,
      quantity: 0,
    );
  }
  
  /// Clear cart
  Future<Result<CartModel>> clearCart(String customerId) async {
    try {
      final cart = CartModel.empty(customerId);
      await _cartRef.doc(customerId).update(cart.toJson());
      return Result.success(cart);
    } catch (e) {
      return Result.failure(DatabaseFailure.fromFirestore(e));
    }
  }
  
  /// Stream of cart changes
  Stream<CartModel> cartStream(String customerId) {
    return _cartRef
        .doc(customerId)
        .snapshots()
        .map((doc) {
          if (doc.exists) {
            return CartModel.fromFirestore(doc);
          }
          return CartModel.empty(customerId);
        });
  }
  
  /// Validate cart items (check stock, prices, etc.)
  Future<Result<CartModel>> validateCart(String customerId) async {
    try {
      final cartResult = await getOrCreateCart(customerId);
      if (cartResult.isFailure) {
        return cartResult;
      }
      
      final cart = cartResult.data;
      final validatedItems = <CartItem>[];
      bool hasChanges = false;
      
      for (final item in cart.items) {
        // Fetch current product data
        final productDoc = await _firestore
            .collection(AppConstants.productsCollection)
            .doc(item.productId)
            .get();
        
        if (!productDoc.exists) {
          // Product no longer exists, skip it
          hasChanges = true;
          continue;
        }
        
        final product = ProductModel.fromFirestore(productDoc);
        
        if (!product.isActive) {
          // Product is inactive, skip it
          hasChanges = true;
          continue;
        }
        
        // Adjust quantity if needed
        int validQuantity = item.quantity;
        if (validQuantity > product.stockQuantity) {
          validQuantity = product.stockQuantity;
          hasChanges = true;
        }
        
        if (validQuantity > 0) {
          validatedItems.add(CartItem(
            productId: item.productId,
            artisanId: product.artisanId,
            productName: product.name,
            productImageUrl: product.primaryImageUrl,
            price: product.price,
            quantity: validQuantity,
            availableStock: product.stockQuantity,
            selectedAttributes: item.selectedAttributes,
          ));
        }
      }
      
      if (hasChanges) {
        final updatedCart = cart.copyWith(
          items: validatedItems,
          updatedAt: DateTime.now(),
        );
        await _cartRef.doc(customerId).update(updatedCart.toJson());
        return Result.success(updatedCart);
      }
      
      return Result.success(cart);
    } catch (e) {
      return Result.failure(DatabaseFailure.fromFirestore(e));
    }
  }
}
