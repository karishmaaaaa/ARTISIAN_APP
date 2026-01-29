import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

import '../core/constants/app_constants.dart';
import '../core/errors/failures.dart';
import '../core/errors/result.dart';
import '../core/utils/helpers.dart';
import '../models/product_model.dart';

/// Repository for product management operations.
/// 
/// Handles CRUD operations for products including image uploads
/// and complex queries for browsing/filtering.
class ProductRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final Uuid _uuid;
  
  ProductRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance,
        _uuid = const Uuid();
  
  /// Collection reference for products
  CollectionReference<Map<String, dynamic>> get _productsRef =>
      _firestore.collection(AppConstants.productsCollection);
  
  /// Create a new product
  Future<Result<ProductModel>> createProduct({
    required String artisanId,
    required String name,
    required String description,
    required double price,
    double? compareAtPrice,
    required String category,
    List<String> tags = const [],
    required int stockQuantity,
    List<File>? images,
    Map<String, dynamic>? attributes,
  }) async {
    try {
      final productId = _uuid.v4();
      final now = DateTime.now();
      
      // Upload images if provided
      List<String> imageUrls = [];
      if (images != null && images.isNotEmpty) {
        imageUrls = await _uploadProductImages(productId, images);
      }
      
      final product = ProductModel(
        id: productId,
        artisanId: artisanId,
        name: name,
        description: description,
        price: price,
        compareAtPrice: compareAtPrice,
        imageUrls: imageUrls,
        category: category,
        tags: tags,
        stockQuantity: stockQuantity,
        attributes: attributes,
        createdAt: now,
        updatedAt: now,
      );
      
      await _productsRef.doc(productId).set(product.toJson());
      
      // Update artisan's product count
      await _firestore
          .collection(AppConstants.artisansCollection)
          .doc(artisanId)
          .update({
        'totalProducts': FieldValue.increment(1),
        'updatedAt': Timestamp.fromDate(now),
      });
      
      return Result.success(product);
    } catch (e) {
      return Result.failure(DatabaseFailure.fromFirestore(e));
    }
  }
  
  /// Update an existing product
  Future<Result<ProductModel>> updateProduct({
    required String productId,
    String? name,
    String? description,
    double? price,
    double? compareAtPrice,
    String? category,
    List<String>? tags,
    int? stockQuantity,
    List<String>? imageUrls,
    List<File>? newImages,
    bool? isActive,
    bool? isFeatured,
    Map<String, dynamic>? attributes,
  }) async {
    try {
      final now = DateTime.now();
      
      // If there are new images, upload them
      List<String>? updatedImageUrls = imageUrls;
      if (newImages != null && newImages.isNotEmpty) {
        final newUrls = await _uploadProductImages(productId, newImages);
        updatedImageUrls = [...?imageUrls, ...newUrls];
      }
      
      final updates = <String, dynamic>{
        'updatedAt': Timestamp.fromDate(now),
        if (name != null) 'name': name,
        if (name != null) 'nameLowercase': name.toLowerCase(),
        if (description != null) 'description': description,
        if (price != null) 'price': price,
        if (compareAtPrice != null) 'compareAtPrice': compareAtPrice,
        if (category != null) 'category': category,
        if (tags != null) 'tags': tags,
        if (stockQuantity != null) 'stockQuantity': stockQuantity,
        if (updatedImageUrls != null) 'imageUrls': updatedImageUrls,
        if (isActive != null) 'isActive': isActive,
        if (isFeatured != null) 'isFeatured': isFeatured,
        if (attributes != null) 'attributes': attributes,
      };
      
      await _productsRef.doc(productId).update(updates);
      
      // Fetch updated product
      final doc = await _productsRef.doc(productId).get();
      return Result.success(ProductModel.fromFirestore(doc));
    } catch (e) {
      return Result.failure(DatabaseFailure.fromFirestore(e));
    }
  }
  
  /// Delete a product
  Future<Result<void>> deleteProduct({
    required String productId,
    required String artisanId,
  }) async {
    try {
      // Get product to delete its images
      final doc = await _productsRef.doc(productId).get();
      if (doc.exists) {
        final product = ProductModel.fromFirestore(doc);
        
        // Delete images from storage
        for (final url in product.imageUrls) {
          try {
            await _storage.refFromURL(url).delete();
          } catch (_) {
            // Ignore image deletion errors
          }
        }
      }
      
      await _productsRef.doc(productId).delete();
      
      // Update artisan's product count
      await _firestore
          .collection(AppConstants.artisansCollection)
          .doc(artisanId)
          .update({
        'totalProducts': FieldValue.increment(-1),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      
      return Result.success(null);
    } catch (e) {
      return Result.failure(DatabaseFailure.fromFirestore(e));
    }
  }
  
  /// Get a single product by ID
  Future<Result<ProductModel>> getProduct(String productId) async {
    try {
      final doc = await _productsRef.doc(productId).get();
      
      if (!doc.exists) {
        return Result.failure(
          const DatabaseFailure(message: 'Product not found'),
        );
      }
      
      return Result.success(ProductModel.fromFirestore(doc));
    } catch (e) {
      return Result.failure(DatabaseFailure.fromFirestore(e));
    }
  }
  
  /// Get products by artisan
  Future<Result<List<ProductModel>>> getProductsByArtisan(
    String artisanId, {
    int limit = AppConstants.productsPerPage,
    DocumentSnapshot? startAfter,
    bool activeOnly = false,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _productsRef
          .where('artisanId', isEqualTo: artisanId)
          .orderBy('createdAt', descending: true)
          .limit(limit);
      
      if (activeOnly) {
        query = query.where('isActive', isEqualTo: true);
      }
      
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }
      
      final snapshot = await query.get();
      final products = snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();
      
      return Result.success(products);
    } catch (e) {
      return Result.failure(DatabaseFailure.fromFirestore(e));
    }
  }
  
  /// Get all active products with filtering
  Future<Result<List<ProductModel>>> getProducts({
    String? category,
    String? searchQuery,
    double? minPrice,
    double? maxPrice,
    int limit = AppConstants.productsPerPage,
    DocumentSnapshot? startAfter,
    String sortBy = 'createdAt',
    bool descending = true,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _productsRef
          .where('isActive', isEqualTo: true);
      
      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }
      
      if (minPrice != null) {
        query = query.where('price', isGreaterThanOrEqualTo: minPrice);
      }
      
      if (maxPrice != null) {
        query = query.where('price', isLessThanOrEqualTo: maxPrice);
      }
      
      query = query.orderBy(sortBy, descending: descending).limit(limit);
      
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }
      
      final snapshot = await query.get();
      var products = snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();
      
      // Client-side text search (for demo - use Algolia/ElasticSearch in production)
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final searchLower = searchQuery.toLowerCase();
        products = products.where((p) =>
            p.name.toLowerCase().contains(searchLower) ||
            p.description.toLowerCase().contains(searchLower) ||
            p.tags.any((t) => t.toLowerCase().contains(searchLower))
        ).toList();
      }
      
      return Result.success(products);
    } catch (e) {
      return Result.failure(DatabaseFailure.fromFirestore(e));
    }
  }
  
  /// Get featured products
  Future<Result<List<ProductModel>>> getFeaturedProducts({
    int limit = 10,
  }) async {
    try {
      final snapshot = await _productsRef
          .where('isActive', isEqualTo: true)
          .where('isFeatured', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      
      final products = snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();
      
      return Result.success(products);
    } catch (e) {
      return Result.failure(DatabaseFailure.fromFirestore(e));
    }
  }
  
  /// Stream of products by artisan
  Stream<List<ProductModel>> productsStreamByArtisan(String artisanId) {
    return _productsRef
        .where('artisanId', isEqualTo: artisanId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductModel.fromFirestore(doc))
            .toList());
  }
  
  /// Upload product images to Firebase Storage
  Future<List<String>> _uploadProductImages(
    String productId,
    List<File> images,
  ) async {
    final urls = <String>[];
    
    for (int i = 0; i < images.length; i++) {
      final file = images[i];
      
      // Compress image before upload
      final compressedFile = await Helpers.compressImage(file);
      final uploadFile = compressedFile ?? file;
      
      final filename = Helpers.generateUniqueFilename('product_$i.jpg');
      final ref = _storage
          .ref()
          .child(AppConstants.productImagesPath)
          .child(productId)
          .child(filename);
      
      await ref.putFile(uploadFile);
      final url = await ref.getDownloadURL();
      urls.add(url);
    }
    
    return urls;
  }
  
  /// Delete a single product image
  Future<Result<void>> deleteProductImage({
    required String productId,
    required String imageUrl,
  }) async {
    try {
      // Delete from storage
      await _storage.refFromURL(imageUrl).delete();
      
      // Remove from product document
      await _productsRef.doc(productId).update({
        'imageUrls': FieldValue.arrayRemove([imageUrl]),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      
      return Result.success(null);
    } catch (e) {
      return Result.failure(StorageFailure.fromFirebaseStorage(e));
    }
  }
  
  /// Update product stock
  Future<Result<void>> updateStock({
    required String productId,
    required int quantityChange,
  }) async {
    try {
      await _productsRef.doc(productId).update({
        'stockQuantity': FieldValue.increment(quantityChange),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      return Result.success(null);
    } catch (e) {
      return Result.failure(DatabaseFailure.fromFirestore(e));
    }
  }
}
