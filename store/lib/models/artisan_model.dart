import 'package:cloud_firestore/cloud_firestore.dart';

/// Artisan profile model with shop-specific information.
/// 
/// This extends the base user with artisan-specific data like
/// shop name, description, specializations, and business metrics.
class ArtisanModel {
  final String id; // Same as user ID
  final String userId;
  final String shopName;
  final String description;
  final String? bannerImageUrl;
  final List<String> specializations;
  final String? location;
  final double rating;
  final int totalReviews;
  final int totalProducts;
  final int totalOrders;
  final double totalSales;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const ArtisanModel({
    required this.id,
    required this.userId,
    required this.shopName,
    required this.description,
    this.bannerImageUrl,
    this.specializations = const [],
    this.location,
    this.rating = 0.0,
    this.totalReviews = 0,
    this.totalProducts = 0,
    this.totalOrders = 0,
    this.totalSales = 0.0,
    this.isVerified = false,
    required this.createdAt,
    required this.updatedAt,
  });
  
  /// Creates an ArtisanModel from a Firestore document
  factory ArtisanModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return ArtisanModel(
      id: doc.id,
      userId: data['userId'] as String,
      shopName: data['shopName'] as String,
      description: data['description'] as String? ?? '',
      bannerImageUrl: data['bannerImageUrl'] as String?,
      specializations: List<String>.from(data['specializations'] ?? []),
      location: data['location'] as String?,
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: data['totalReviews'] as int? ?? 0,
      totalProducts: data['totalProducts'] as int? ?? 0,
      totalOrders: data['totalOrders'] as int? ?? 0,
      totalSales: (data['totalSales'] as num?)?.toDouble() ?? 0.0,
      isVerified: data['isVerified'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }
  
  /// Creates an ArtisanModel from a Map
  factory ArtisanModel.fromJson(Map<String, dynamic> json) {
    return ArtisanModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      shopName: json['shopName'] as String,
      description: json['description'] as String? ?? '',
      bannerImageUrl: json['bannerImageUrl'] as String?,
      specializations: List<String>.from(json['specializations'] ?? []),
      location: json['location'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['totalReviews'] as int? ?? 0,
      totalProducts: json['totalProducts'] as int? ?? 0,
      totalOrders: json['totalOrders'] as int? ?? 0,
      totalSales: (json['totalSales'] as num?)?.toDouble() ?? 0.0,
      isVerified: json['isVerified'] as bool? ?? false,
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] is Timestamp
          ? (json['updatedAt'] as Timestamp).toDate()
          : DateTime.parse(json['updatedAt'] as String),
    );
  }
  
  /// Converts the ArtisanModel to a Map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'shopName': shopName,
      'description': description,
      'bannerImageUrl': bannerImageUrl,
      'specializations': specializations,
      'location': location,
      'rating': rating,
      'totalReviews': totalReviews,
      'totalProducts': totalProducts,
      'totalOrders': totalOrders,
      'totalSales': totalSales,
      'isVerified': isVerified,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
  
  /// Creates a copy with updated fields
  ArtisanModel copyWith({
    String? id,
    String? userId,
    String? shopName,
    String? description,
    String? bannerImageUrl,
    List<String>? specializations,
    String? location,
    double? rating,
    int? totalReviews,
    int? totalProducts,
    int? totalOrders,
    double? totalSales,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ArtisanModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      shopName: shopName ?? this.shopName,
      description: description ?? this.description,
      bannerImageUrl: bannerImageUrl ?? this.bannerImageUrl,
      specializations: specializations ?? this.specializations,
      location: location ?? this.location,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      totalProducts: totalProducts ?? this.totalProducts,
      totalOrders: totalOrders ?? this.totalOrders,
      totalSales: totalSales ?? this.totalSales,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  /// Get shareable storefront URL
  String get storefrontUrl => 'https://artisan.marketplace/store/$id';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ArtisanModel && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
  
  @override
  String toString() {
    return 'ArtisanModel(id: $id, shopName: $shopName)';
  }
}
