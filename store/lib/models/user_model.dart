import 'package:cloud_firestore/cloud_firestore.dart';

/// User model representing both artisans and customers.
/// 
/// This model serves as the base user data stored in Firestore.
/// Role-specific data (artisan profile, etc.) is stored separately.
class UserModel {
  final String id;
  final String email;
  final String name;
  final String role; // 'artisan' or 'customer'
  final String? phone;
  final String? profileImageUrl;
  final String? address;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  
  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.phone,
    this.profileImageUrl,
    this.address,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });
  
  /// Creates a UserModel from a Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return UserModel(
      id: doc.id,
      email: data['email'] as String,
      name: data['name'] as String,
      role: data['role'] as String,
      phone: data['phone'] as String?,
      profileImageUrl: data['profileImageUrl'] as String?,
      address: data['address'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      isActive: data['isActive'] as bool? ?? true,
    );
  }
  
  /// Creates a UserModel from a Map
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      phone: json['phone'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      address: json['address'] as String?,
      createdAt: json['createdAt'] is Timestamp 
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] is Timestamp
          ? (json['updatedAt'] as Timestamp).toDate()
          : DateTime.parse(json['updatedAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
    );
  }
  
  /// Converts the UserModel to a Map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'phone': phone,
      'profileImageUrl': profileImageUrl,
      'address': address,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isActive': isActive,
    };
  }
  
  /// Creates a copy with updated fields
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    String? phone,
    String? profileImageUrl,
    String? address,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
  
  /// Check if user is an artisan
  bool get isArtisan => role == 'artisan';
  
  /// Check if user is a customer
  bool get isCustomer => role == 'customer';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
  
  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, name: $name, role: $role)';
  }
}
