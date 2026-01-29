import 'package:cloud_firestore/cloud_firestore.dart';

/// Product model representing items sold by artisans.
/// 
/// Contains all product information including pricing, inventory,
/// and metadata for search and filtering.
class ProductModel {
  final String id;
  final String artisanId;
  final String name;
  final String description;
  final double price;
  final double? compareAtPrice; // Original price for showing discounts
  final List<String> imageUrls;
  final String category;
  final List<String> tags;
  final int stockQuantity;
  final bool isActive;
  final bool isFeatured;
  final double rating;
  final int totalReviews;
  final int totalSold;
  final Map<String, dynamic>? attributes; // Size, color, material, etc.
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const ProductModel({
    required this.id,
    required this.artisanId,
    required this.name,
    required this.description,
    required this.price,
    this.compareAtPrice,
    required this.imageUrls,
    required this.category,
    this.tags = const [],
    required this.stockQuantity,
    this.isActive = true,
    this.isFeatured = false,
    this.rating = 0.0,
    this.totalReviews = 0,
    this.totalSold = 0,
    this.attributes,
    required this.createdAt,
    required this.updatedAt,
  });
  
  /// Creates a ProductModel from a Firestore document
  factory ProductModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return ProductModel(
      id: doc.id,
      artisanId: data['artisanId'] as String,
      name: data['name'] as String,
      description: data['description'] as String,
      price: (data['price'] as num).toDouble(),
      compareAtPrice: (data['compareAtPrice'] as num?)?.toDouble(),
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      category: data['category'] as String,
      tags: List<String>.from(data['tags'] ?? []),
      stockQuantity: data['stockQuantity'] as int? ?? 0,
      isActive: data['isActive'] as bool? ?? true,
      isFeatured: data['isFeatured'] as bool? ?? false,
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: data['totalReviews'] as int? ?? 0,
      totalSold: data['totalSold'] as int? ?? 0,
      attributes: data['attributes'] as Map<String, dynamic>?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }
  
  /// Creates a ProductModel from a Map
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      artisanId: json['artisanId'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      compareAtPrice: (json['compareAtPrice'] as num?)?.toDouble(),
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      category: json['category'] as String,
      tags: List<String>.from(json['tags'] ?? []),
      stockQuantity: json['stockQuantity'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      isFeatured: json['isFeatured'] as bool? ?? false,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['totalReviews'] as int? ?? 0,
      totalSold: json['totalSold'] as int? ?? 0,
      attributes: json['attributes'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] is Timestamp
          ? (json['updatedAt'] as Timestamp).toDate()
          : DateTime.parse(json['updatedAt'] as String),
    );
  }
  
  /// Converts the ProductModel to a Map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'artisanId': artisanId,
      'name': name,
      'description': description,
      'price': price,
      'compareAtPrice': compareAtPrice,
      'imageUrls': imageUrls,
      'category': category,
      'tags': tags,
      'stockQuantity': stockQuantity,
      'isActive': isActive,
      'isFeatured': isFeatured,
      'rating': rating,
      'totalReviews': totalReviews,
      'totalSold': totalSold,
      'attributes': attributes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      // Searchable lowercase name for queries
      'nameLowercase': name.toLowerCase(),
    };
  }
  
  /// Creates a copy with updated fields
  ProductModel copyWith({
    String? id,
    String? artisanId,
    String? name,
    String? description,
    double? price,
    double? compareAtPrice,
    List<String>? imageUrls,
    String? category,
    List<String>? tags,
    int? stockQuantity,
    bool? isActive,
    bool? isFeatured,
    double? rating,
    int? totalReviews,
    int? totalSold,
    Map<String, dynamic>? attributes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      artisanId: artisanId ?? this.artisanId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      compareAtPrice: compareAtPrice ?? this.compareAtPrice,
      imageUrls: imageUrls ?? this.imageUrls,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      isActive: isActive ?? this.isActive,
      isFeatured: isFeatured ?? this.isFeatured,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      totalSold: totalSold ?? this.totalSold,
      attributes: attributes ?? this.attributes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  /// Check if product is in stock
  bool get isInStock => stockQuantity > 0;
  
  /// Check if product has a discount
  bool get hasDiscount => compareAtPrice != null && compareAtPrice! > price;
  
  /// Calculate discount percentage
  int get discountPercentage {
    if (!hasDiscount) return 0;
    return (((compareAtPrice! - price) / compareAtPrice!) * 100).round();
  }
  
  /// Get the primary image URL
  String? get primaryImageUrl => imageUrls.isNotEmpty ? imageUrls.first : null;
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductModel && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
  
  @override
  String toString() {
    return 'ProductModel(id: $id, name: $name, price: $price)';
  }
}
