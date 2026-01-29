import 'package:cloud_firestore/cloud_firestore.dart';

/// Category model for organizing products.
/// 
/// Supports hierarchical categories with parent-child relationships.
class CategoryModel {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final String? parentId;
  final int sortOrder;
  final bool isActive;
  final int productCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const CategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.parentId,
    this.sortOrder = 0,
    this.isActive = true,
    this.productCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });
  
  /// Creates a CategoryModel from a Firestore document
  factory CategoryModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return CategoryModel(
      id: doc.id,
      name: data['name'] as String,
      description: data['description'] as String?,
      imageUrl: data['imageUrl'] as String?,
      parentId: data['parentId'] as String?,
      sortOrder: data['sortOrder'] as int? ?? 0,
      isActive: data['isActive'] as bool? ?? true,
      productCount: data['productCount'] as int? ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }
  
  /// Creates a CategoryModel from a Map
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      parentId: json['parentId'] as String?,
      sortOrder: json['sortOrder'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      productCount: json['productCount'] as int? ?? 0,
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] is Timestamp
          ? (json['updatedAt'] as Timestamp).toDate()
          : DateTime.parse(json['updatedAt'] as String),
    );
  }
  
  /// Converts the CategoryModel to a Map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'parentId': parentId,
      'sortOrder': sortOrder,
      'isActive': isActive,
      'productCount': productCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
  
  /// Creates a copy with updated fields
  CategoryModel copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    String? parentId,
    int? sortOrder,
    bool? isActive,
    int? productCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      parentId: parentId ?? this.parentId,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      productCount: productCount ?? this.productCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  /// Check if this is a root category
  bool get isRootCategory => parentId == null;
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryModel && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
  
  @override
  String toString() => 'CategoryModel(id: $id, name: $name)';
}
