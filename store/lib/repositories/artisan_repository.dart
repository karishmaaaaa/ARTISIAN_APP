import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../core/constants/app_constants.dart';
import '../core/errors/failures.dart';
import '../core/errors/result.dart';
import '../core/utils/helpers.dart';
import '../models/artisan_model.dart';
import '../models/user_model.dart';

/// Repository for artisan profile management.
/// 
/// Handles artisan profile CRUD, storefront customization,
/// and artisan listing/search operations.
class ArtisanRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  
  ArtisanRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;
  
  /// Collection reference for artisans
  CollectionReference<Map<String, dynamic>> get _artisansRef =>
      _firestore.collection(AppConstants.artisansCollection);
  
  /// Get artisan profile by ID
  Future<Result<ArtisanModel>> getArtisan(String artisanId) async {
    try {
      final doc = await _artisansRef.doc(artisanId).get();
      
      if (!doc.exists) {
        return Result.failure(
          const DatabaseFailure(message: 'Artisan not found'),
        );
      }
      
      return Result.success(ArtisanModel.fromFirestore(doc));
    } catch (e) {
      return Result.failure(DatabaseFailure.fromFirestore(e));
    }
  }
  
  /// Get artisan with user data
  Future<Result<Map<String, dynamic>>> getArtisanWithUser(
    String artisanId,
  ) async {
    try {
      final artisanDoc = await _artisansRef.doc(artisanId).get();
      
      if (!artisanDoc.exists) {
        return Result.failure(
          const DatabaseFailure(message: 'Artisan not found'),
        );
      }
      
      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(artisanId)
          .get();
      
      return Result.success({
        'artisan': ArtisanModel.fromFirestore(artisanDoc),
        'user': userDoc.exists ? UserModel.fromFirestore(userDoc) : null,
      });
    } catch (e) {
      return Result.failure(DatabaseFailure.fromFirestore(e));
    }
  }
  
  /// Update artisan profile
  Future<Result<ArtisanModel>> updateArtisan({
    required String artisanId,
    String? shopName,
    String? description,
    String? bannerImageUrl,
    List<String>? specializations,
    String? location,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updatedAt': Timestamp.fromDate(DateTime.now()),
        if (shopName != null) 'shopName': shopName,
        if (description != null) 'description': description,
        if (bannerImageUrl != null) 'bannerImageUrl': bannerImageUrl,
        if (specializations != null) 'specializations': specializations,
        if (location != null) 'location': location,
      };
      
      await _artisansRef.doc(artisanId).update(updates);
      
      final doc = await _artisansRef.doc(artisanId).get();
      return Result.success(ArtisanModel.fromFirestore(doc));
    } catch (e) {
      return Result.failure(DatabaseFailure.fromFirestore(e));
    }
  }
  
  /// Upload banner image
  Future<Result<String>> uploadBannerImage({
    required String artisanId,
    required File imageFile,
  }) async {
    try {
      // Compress image
      final compressedFile = await Helpers.compressImage(imageFile);
      final uploadFile = compressedFile ?? imageFile;
      
      final filename = Helpers.generateUniqueFilename('banner.jpg');
      final ref = _storage
          .ref()
          .child(AppConstants.storefrontImagesPath)
          .child(artisanId)
          .child(filename);
      
      await ref.putFile(uploadFile);
      final url = await ref.getDownloadURL();
      
      // Update artisan profile with new banner URL
      await _artisansRef.doc(artisanId).update({
        'bannerImageUrl': url,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      
      return Result.success(url);
    } catch (e) {
      return Result.failure(StorageFailure.fromFirebaseStorage(e));
    }
  }
  
  /// Get all artisans (for browsing)
  Future<Result<List<ArtisanModel>>> getAllArtisans({
    int limit = AppConstants.defaultPageSize,
    DocumentSnapshot? startAfter,
    String? searchQuery,
    List<String>? specializations,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _artisansRef
          .orderBy('shopName')
          .limit(limit);
      
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }
      
      final snapshot = await query.get();
      var artisans = snapshot.docs
          .map((doc) => ArtisanModel.fromFirestore(doc))
          .toList();
      
      // Client-side filtering (for demo - use dedicated search in production)
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final searchLower = searchQuery.toLowerCase();
        artisans = artisans.where((a) =>
            a.shopName.toLowerCase().contains(searchLower) ||
            a.description.toLowerCase().contains(searchLower)
        ).toList();
      }
      
      if (specializations != null && specializations.isNotEmpty) {
        artisans = artisans.where((a) =>
            a.specializations.any((s) => specializations.contains(s))
        ).toList();
      }
      
      return Result.success(artisans);
    } catch (e) {
      return Result.failure(DatabaseFailure.fromFirestore(e));
    }
  }
  
  /// Get featured/verified artisans
  Future<Result<List<ArtisanModel>>> getFeaturedArtisans({
    int limit = 10,
  }) async {
    try {
      final snapshot = await _artisansRef
          .where('isVerified', isEqualTo: true)
          .orderBy('rating', descending: true)
          .limit(limit)
          .get();
      
      final artisans = snapshot.docs
          .map((doc) => ArtisanModel.fromFirestore(doc))
          .toList();
      
      return Result.success(artisans);
    } catch (e) {
      return Result.failure(DatabaseFailure.fromFirestore(e));
    }
  }
  
  /// Get top artisans by sales
  Future<Result<List<ArtisanModel>>> getTopArtisans({
    int limit = 10,
  }) async {
    try {
      final snapshot = await _artisansRef
          .orderBy('totalSales', descending: true)
          .limit(limit)
          .get();
      
      final artisans = snapshot.docs
          .map((doc) => ArtisanModel.fromFirestore(doc))
          .toList();
      
      return Result.success(artisans);
    } catch (e) {
      return Result.failure(DatabaseFailure.fromFirestore(e));
    }
  }
  
  /// Stream of artisan profile changes
  Stream<ArtisanModel?> artisanStream(String artisanId) {
    return _artisansRef
        .doc(artisanId)
        .snapshots()
        .map((doc) => doc.exists ? ArtisanModel.fromFirestore(doc) : null);
  }
  
  /// Get artisan dashboard stats
  Future<Result<Map<String, dynamic>>> getArtisanStats(
    String artisanId,
  ) async {
    try {
      final artisanDoc = await _artisansRef.doc(artisanId).get();
      
      if (!artisanDoc.exists) {
        return Result.failure(
          const DatabaseFailure(message: 'Artisan not found'),
        );
      }
      
      final artisan = ArtisanModel.fromFirestore(artisanDoc);
      
      // Get pending orders count
      final pendingOrdersSnapshot = await _firestore
          .collection(AppConstants.ordersCollection)
          .where('artisanId', isEqualTo: artisanId)
          .where('status', isEqualTo: 'pending')
          .count()
          .get();
      
      // Get active products count
      final activeProductsSnapshot = await _firestore
          .collection(AppConstants.productsCollection)
          .where('artisanId', isEqualTo: artisanId)
          .where('isActive', isEqualTo: true)
          .count()
          .get();
      
      // Get low stock products count (stock < 5)
      final lowStockSnapshot = await _firestore
          .collection(AppConstants.productsCollection)
          .where('artisanId', isEqualTo: artisanId)
          .where('stockQuantity', isLessThan: 5)
          .count()
          .get();
      
      return Result.success({
        'totalProducts': artisan.totalProducts,
        'totalOrders': artisan.totalOrders,
        'totalSales': artisan.totalSales,
        'rating': artisan.rating,
        'totalReviews': artisan.totalReviews,
        'pendingOrders': pendingOrdersSnapshot.count,
        'activeProducts': activeProductsSnapshot.count,
        'lowStockProducts': lowStockSnapshot.count,
      });
    } catch (e) {
      return Result.failure(DatabaseFailure.fromFirestore(e));
    }
  }
}
