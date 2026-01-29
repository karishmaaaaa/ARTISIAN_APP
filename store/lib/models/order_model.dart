import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';

/// Order model representing a customer purchase.
/// 
/// Contains order details, items, shipping info, and status tracking.
class OrderModel {
  final String id;
  final String customerId;
  final String artisanId;
  final List<OrderItem> items;
  final double subtotal;
  final double shippingCost;
  final double tax;
  final double total;
  final OrderStatus status;
  final ShippingAddress shippingAddress;
  final String? notes;
  final String? trackingNumber;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? shippedAt;
  final DateTime? completedAt;
  
  const OrderModel({
    required this.id,
    required this.customerId,
    required this.artisanId,
    required this.items,
    required this.subtotal,
    this.shippingCost = 0.0,
    this.tax = 0.0,
    required this.total,
    required this.status,
    required this.shippingAddress,
    this.notes,
    this.trackingNumber,
    required this.createdAt,
    required this.updatedAt,
    this.shippedAt,
    this.completedAt,
  });
  
  /// Creates an OrderModel from a Firestore document
  factory OrderModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return OrderModel(
      id: doc.id,
      customerId: data['customerId'] as String,
      artisanId: data['artisanId'] as String,
      items: (data['items'] as List<dynamic>)
          .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      subtotal: (data['subtotal'] as num).toDouble(),
      shippingCost: (data['shippingCost'] as num?)?.toDouble() ?? 0.0,
      tax: (data['tax'] as num?)?.toDouble() ?? 0.0,
      total: (data['total'] as num).toDouble(),
      status: OrderStatus.fromString(data['status'] as String),
      shippingAddress: ShippingAddress.fromJson(
          data['shippingAddress'] as Map<String, dynamic>),
      notes: data['notes'] as String?,
      trackingNumber: data['trackingNumber'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      shippedAt: data['shippedAt'] != null
          ? (data['shippedAt'] as Timestamp).toDate()
          : null,
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
    );
  }
  
  /// Creates an OrderModel from a Map
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      customerId: json['customerId'] as String,
      artisanId: json['artisanId'] as String,
      items: (json['items'] as List<dynamic>)
          .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      shippingCost: (json['shippingCost'] as num?)?.toDouble() ?? 0.0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num).toDouble(),
      status: OrderStatus.fromString(json['status'] as String),
      shippingAddress: ShippingAddress.fromJson(
          json['shippingAddress'] as Map<String, dynamic>),
      notes: json['notes'] as String?,
      trackingNumber: json['trackingNumber'] as String?,
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] is Timestamp
          ? (json['updatedAt'] as Timestamp).toDate()
          : DateTime.parse(json['updatedAt'] as String),
      shippedAt: json['shippedAt'] != null
          ? (json['shippedAt'] is Timestamp
              ? (json['shippedAt'] as Timestamp).toDate()
              : DateTime.parse(json['shippedAt'] as String))
          : null,
      completedAt: json['completedAt'] != null
          ? (json['completedAt'] is Timestamp
              ? (json['completedAt'] as Timestamp).toDate()
              : DateTime.parse(json['completedAt'] as String))
          : null,
    );
  }
  
  /// Converts the OrderModel to a Map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'artisanId': artisanId,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'shippingCost': shippingCost,
      'tax': tax,
      'total': total,
      'status': status.value,
      'shippingAddress': shippingAddress.toJson(),
      'notes': notes,
      'trackingNumber': trackingNumber,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'shippedAt': shippedAt != null ? Timestamp.fromDate(shippedAt!) : null,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }
  
  /// Creates a copy with updated fields
  OrderModel copyWith({
    String? id,
    String? customerId,
    String? artisanId,
    List<OrderItem>? items,
    double? subtotal,
    double? shippingCost,
    double? tax,
    double? total,
    OrderStatus? status,
    ShippingAddress? shippingAddress,
    String? notes,
    String? trackingNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? shippedAt,
    DateTime? completedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      artisanId: artisanId ?? this.artisanId,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      shippingCost: shippingCost ?? this.shippingCost,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      status: status ?? this.status,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      notes: notes ?? this.notes,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      shippedAt: shippedAt ?? this.shippedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
  
  /// Get total number of items
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);
  
  /// Check if order can be cancelled
  bool get canBeCancelled => 
      status == OrderStatus.pending || status == OrderStatus.accepted;
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderModel && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}

/// Individual item in an order
class OrderItem {
  final String productId;
  final String productName;
  final String? productImageUrl;
  final double price;
  final int quantity;
  final Map<String, dynamic>? selectedAttributes;
  
  const OrderItem({
    required this.productId,
    required this.productName,
    this.productImageUrl,
    required this.price,
    required this.quantity,
    this.selectedAttributes,
  });
  
  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      productImageUrl: json['productImageUrl'] as String?,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      selectedAttributes: json['selectedAttributes'] as Map<String, dynamic>?,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'productImageUrl': productImageUrl,
      'price': price,
      'quantity': quantity,
      'selectedAttributes': selectedAttributes,
    };
  }
  
  double get subtotal => price * quantity;
}

/// Shipping address for an order
class ShippingAddress {
  final String fullName;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final String? phone;
  
  const ShippingAddress({
    required this.fullName,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    this.phone,
  });
  
  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      fullName: json['fullName'] as String,
      addressLine1: json['addressLine1'] as String,
      addressLine2: json['addressLine2'] as String?,
      city: json['city'] as String,
      state: json['state'] as String,
      postalCode: json['postalCode'] as String,
      country: json['country'] as String,
      phone: json['phone'] as String?,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
      'phone': phone,
    };
  }
  
  String get formattedAddress {
    final parts = [
      addressLine1,
      if (addressLine2 != null) addressLine2,
      '$city, $state $postalCode',
      country,
    ];
    return parts.join('\n');
  }
}
