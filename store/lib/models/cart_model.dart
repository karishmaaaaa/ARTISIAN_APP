import 'package:cloud_firestore/cloud_firestore.dart';

/// Cart model for customer shopping cart.
/// 
/// Stores cart items grouped by artisan for easier checkout processing.
class CartModel {
  final String id;
  final String customerId;
  final List<CartItem> items;
  final DateTime updatedAt;
  
  const CartModel({
    required this.id,
    required this.customerId,
    required this.items,
    required this.updatedAt,
  });
  
  /// Creates a CartModel from a Firestore document
  factory CartModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return CartModel(
      id: doc.id,
      customerId: data['customerId'] as String,
      items: (data['items'] as List<dynamic>)
          .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }
  
  /// Creates a CartModel from a Map
  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      id: json['id'] as String,
      customerId: json['customerId'] as String,
      items: (json['items'] as List<dynamic>)
          .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      updatedAt: json['updatedAt'] is Timestamp
          ? (json['updatedAt'] as Timestamp).toDate()
          : DateTime.parse(json['updatedAt'] as String),
    );
  }
  
  /// Converts the CartModel to a Map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'items': items.map((item) => item.toJson()).toList(),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
  
  /// Creates a copy with updated fields
  CartModel copyWith({
    String? id,
    String? customerId,
    List<CartItem>? items,
    DateTime? updatedAt,
  }) {
    return CartModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      items: items ?? this.items,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  /// Get total number of items in cart
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);
  
  /// Get cart subtotal
  double get subtotal => items.fold(0.0, (sum, item) => sum + item.subtotal);
  
  /// Check if cart is empty
  bool get isEmpty => items.isEmpty;
  
  /// Check if cart is not empty
  bool get isNotEmpty => items.isNotEmpty;
  
  /// Get items grouped by artisan
  Map<String, List<CartItem>> get itemsByArtisan {
    final grouped = <String, List<CartItem>>{};
    for (final item in items) {
      grouped.putIfAbsent(item.artisanId, () => []).add(item);
    }
    return grouped;
  }
  
  /// Get unique artisan IDs in cart
  List<String> get artisanIds => items.map((e) => e.artisanId).toSet().toList();
  
  /// Create an empty cart
  factory CartModel.empty(String customerId) {
    return CartModel(
      id: customerId,
      customerId: customerId,
      items: [],
      updatedAt: DateTime.now(),
    );
  }
}

/// Individual item in the cart
class CartItem {
  final String productId;
  final String artisanId;
  final String productName;
  final String? productImageUrl;
  final double price;
  final int quantity;
  final int availableStock;
  final Map<String, dynamic>? selectedAttributes;
  
  const CartItem({
    required this.productId,
    required this.artisanId,
    required this.productName,
    this.productImageUrl,
    required this.price,
    required this.quantity,
    required this.availableStock,
    this.selectedAttributes,
  });
  
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['productId'] as String,
      artisanId: json['artisanId'] as String,
      productName: json['productName'] as String,
      productImageUrl: json['productImageUrl'] as String?,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      availableStock: json['availableStock'] as int? ?? 0,
      selectedAttributes: json['selectedAttributes'] as Map<String, dynamic>?,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'artisanId': artisanId,
      'productName': productName,
      'productImageUrl': productImageUrl,
      'price': price,
      'quantity': quantity,
      'availableStock': availableStock,
      'selectedAttributes': selectedAttributes,
    };
  }
  
  CartItem copyWith({
    String? productId,
    String? artisanId,
    String? productName,
    String? productImageUrl,
    double? price,
    int? quantity,
    int? availableStock,
    Map<String, dynamic>? selectedAttributes,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      artisanId: artisanId ?? this.artisanId,
      productName: productName ?? this.productName,
      productImageUrl: productImageUrl ?? this.productImageUrl,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      availableStock: availableStock ?? this.availableStock,
      selectedAttributes: selectedAttributes ?? this.selectedAttributes,
    );
  }
  
  /// Get subtotal for this item
  double get subtotal => price * quantity;
  
  /// Check if more can be added
  bool get canAddMore => quantity < availableStock;
  
  /// Check if quantity exceeds available stock
  bool get exceedsStock => quantity > availableStock;
}
