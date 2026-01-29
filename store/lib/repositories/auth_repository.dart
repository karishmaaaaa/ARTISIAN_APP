import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/constants/app_constants.dart';
import '../core/errors/failures.dart';
import '../core/errors/result.dart';
import '../models/user_model.dart';
import '../models/artisan_model.dart';

/// Repository for authentication and user management.
/// 
/// Handles all Firebase Auth operations and user profile management
/// in Firestore. Implements role-based user creation.
class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  
  AuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;
  
  /// Stream of authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  /// Get current Firebase user
  User? get currentFirebaseUser => _auth.currentUser;
  
  /// Check if user is logged in
  bool get isLoggedIn => _auth.currentUser != null;
  
  /// Sign in with email and password
  Future<Result<UserModel>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user == null) {
        return Result.failure(
          const AuthFailure(message: 'Sign in failed. Please try again.'),
        );
      }
      
      // Fetch user profile from Firestore
      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(credential.user!.uid)
          .get();
      
      if (!userDoc.exists) {
        return Result.failure(
          const AuthFailure(message: 'User profile not found.'),
        );
      }
      
      return Result.success(UserModel.fromFirestore(userDoc));
    } on FirebaseAuthException catch (e) {
      return Result.failure(AuthFailure.fromFirebaseAuth(e));
    } catch (e) {
      return Result.failure(UnexpectedFailure.fromException(e));
    }
  }
  
  /// Register a new user with email and password
  Future<Result<UserModel>> registerWithEmail({
    required String email,
    required String password,
    required String name,
    required String role,
    String? shopName, // Required for artisans
    String? shopDescription,
  }) async {
    try {
      // Create Firebase Auth user
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user == null) {
        return Result.failure(
          const AuthFailure(message: 'Registration failed. Please try again.'),
        );
      }
      
      final userId = credential.user!.uid;
      final now = DateTime.now();
      
      // Create user profile
      final user = UserModel(
        id: userId,
        email: email,
        name: name,
        role: role,
        createdAt: now,
        updatedAt: now,
      );
      
      // Save user to Firestore
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .set(user.toJson());
      
      // If artisan, create artisan profile
      if (role == UserRole.artisan.value && shopName != null) {
        final artisan = ArtisanModel(
          id: userId,
          userId: userId,
          shopName: shopName,
          description: shopDescription ?? '',
          createdAt: now,
          updatedAt: now,
        );
        
        await _firestore
            .collection(AppConstants.artisansCollection)
            .doc(userId)
            .set(artisan.toJson());
      }
      
      // Update display name in Firebase Auth
      await credential.user!.updateDisplayName(name);
      
      return Result.success(user);
    } on FirebaseAuthException catch (e) {
      return Result.failure(AuthFailure.fromFirebaseAuth(e));
    } catch (e) {
      return Result.failure(UnexpectedFailure.fromException(e));
    }
  }
  
  /// Sign out the current user
  Future<Result<void>> signOut() async {
    try {
      await _auth.signOut();
      return Result.success(null);
    } catch (e) {
      return Result.failure(UnexpectedFailure.fromException(e));
    }
  }
  
  /// Get current user profile from Firestore
  Future<Result<UserModel>> getCurrentUser() async {
    try {
      final firebaseUser = _auth.currentUser;
      
      if (firebaseUser == null) {
        return Result.failure(
          const AuthFailure(message: 'Not authenticated'),
        );
      }
      
      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(firebaseUser.uid)
          .get();
      
      if (!userDoc.exists) {
        return Result.failure(
          const AuthFailure(message: 'User profile not found'),
        );
      }
      
      return Result.success(UserModel.fromFirestore(userDoc));
    } catch (e) {
      return Result.failure(UnexpectedFailure.fromException(e));
    }
  }
  
  /// Update user profile
  Future<Result<UserModel>> updateUserProfile({
    required String userId,
    String? name,
    String? phone,
    String? address,
    String? profileImageUrl,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updatedAt': Timestamp.fromDate(DateTime.now()),
        if (name != null) 'name': name,
        if (phone != null) 'phone': phone,
        if (address != null) 'address': address,
        if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
      };
      
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update(updates);
      
      // Fetch updated user
      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();
      
      return Result.success(UserModel.fromFirestore(userDoc));
    } catch (e) {
      return Result.failure(DatabaseFailure.fromFirestore(e));
    }
  }
  
  /// Send password reset email
  Future<Result<void>> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return Result.success(null);
    } on FirebaseAuthException catch (e) {
      return Result.failure(AuthFailure.fromFirebaseAuth(e));
    } catch (e) {
      return Result.failure(UnexpectedFailure.fromException(e));
    }
  }
  
  /// Delete user account
  Future<Result<void>> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      
      if (user == null) {
        return Result.failure(
          const AuthFailure(message: 'Not authenticated'),
        );
      }
      
      // Delete user data from Firestore
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .delete();
      
      // Delete artisan profile if exists
      await _firestore
          .collection(AppConstants.artisansCollection)
          .doc(user.uid)
          .delete();
      
      // Delete Firebase Auth user
      await user.delete();
      
      return Result.success(null);
    } on FirebaseAuthException catch (e) {
      return Result.failure(AuthFailure.fromFirebaseAuth(e));
    } catch (e) {
      return Result.failure(UnexpectedFailure.fromException(e));
    }
  }
  
  /// Stream of user document changes
  Stream<UserModel?> userStream(String userId) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }
}
