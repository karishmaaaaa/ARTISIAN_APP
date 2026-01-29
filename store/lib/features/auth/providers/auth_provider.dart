import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/user_model.dart';
import '../../../repositories/auth_repository.dart';
import '../../../core/errors/result.dart';

/// Provider for the AuthRepository instance
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// Stream provider for Firebase authentication state changes
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

/// Provider for the current user profile from Firestore
final currentUserProvider = StateNotifierProvider<CurrentUserNotifier, UserModel?>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return CurrentUserNotifier(authRepo);
});

/// State notifier for managing the current user
class CurrentUserNotifier extends StateNotifier<UserModel?> {
  final AuthRepository _authRepository;
  
  CurrentUserNotifier(this._authRepository) : super(null) {
    _init();
  }
  
  Future<void> _init() async {
    if (_authRepository.isLoggedIn) {
      await loadUser();
    }
  }
  
  /// Load the current user from Firestore
  Future<void> loadUser() async {
    final result = await _authRepository.getCurrentUser();
    result.when(
      success: (user) => state = user,
      failure: (_) => state = null,
    );
  }
  
  /// Update the current user state
  void setUser(UserModel? user) {
    state = user;
  }
  
  /// Clear the current user state
  void clearUser() {
    state = null;
  }
}

/// Provider for authentication operations
final authControllerProvider = Provider<AuthController>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  final currentUserNotifier = ref.watch(currentUserProvider.notifier);
  return AuthController(authRepo, currentUserNotifier);
});

/// Controller for authentication operations
class AuthController {
  final AuthRepository _authRepository;
  final CurrentUserNotifier _currentUserNotifier;
  
  AuthController(this._authRepository, this._currentUserNotifier);
  
  /// Sign in with email and password
  Future<Result<UserModel>> signIn({
    required String email,
    required String password,
  }) async {
    final result = await _authRepository.signInWithEmail(
      email: email,
      password: password,
    );
    
    result.when(
      success: (user) => _currentUserNotifier.setUser(user),
      failure: (_) {},
    );
    
    return result;
  }
  
  /// Register a new user
  Future<Result<UserModel>> register({
    required String email,
    required String password,
    required String name,
    required String role,
    String? shopName,
    String? shopDescription,
  }) async {
    final result = await _authRepository.registerWithEmail(
      email: email,
      password: password,
      name: name,
      role: role,
      shopName: shopName,
      shopDescription: shopDescription,
    );
    
    result.when(
      success: (user) => _currentUserNotifier.setUser(user),
      failure: (_) {},
    );
    
    return result;
  }
  
  /// Sign out
  Future<Result<void>> signOut() async {
    final result = await _authRepository.signOut();
    
    result.when(
      success: (_) => _currentUserNotifier.clearUser(),
      failure: (_) {},
    );
    
    return result;
  }
  
  /// Send password reset email
  Future<Result<void>> sendPasswordReset(String email) {
    return _authRepository.sendPasswordResetEmail(email);
  }
  
  /// Update user profile
  Future<Result<UserModel>> updateProfile({
    required String userId,
    String? name,
    String? phone,
    String? address,
    String? profileImageUrl,
  }) async {
    final result = await _authRepository.updateUserProfile(
      userId: userId,
      name: name,
      phone: phone,
      address: address,
      profileImageUrl: profileImageUrl,
    );
    
    result.when(
      success: (user) => _currentUserNotifier.setUser(user),
      failure: (_) {},
    );
    
    return result;
  }
  
  /// Delete account
  Future<Result<void>> deleteAccount() async {
    final result = await _authRepository.deleteAccount();
    
    result.when(
      success: (_) => _currentUserNotifier.clearUser(),
      failure: (_) {},
    );
    
    return result;
  }
}

/// Provider to check if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.valueOrNull != null;
});

/// Provider to get user role
final userRoleProvider = Provider<String?>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.role;
});

/// Provider to check if user is an artisan
final isArtisanProvider = Provider<bool>((ref) {
  final role = ref.watch(userRoleProvider);
  return role == 'artisan';
});

/// Provider to check if user is a customer
final isCustomerProvider = Provider<bool>((ref) {
  final role = ref.watch(userRoleProvider);
  return role == 'customer';
});
