import 'package:firebase_auth/firebase_auth.dart';

/// Base class for all application failures.
/// 
/// Provides a consistent way to handle errors throughout the app
/// with user-friendly messages.
abstract class Failure {
  final String message;
  final String? code;
  
  const Failure({required this.message, this.code});
  
  @override
  String toString() => 'Failure: $message (code: $code)';
}

/// Failure related to authentication operations
class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.code});
  
  /// Creates an AuthFailure from a FirebaseAuthException
  factory AuthFailure.fromFirebaseAuth(FirebaseAuthException e) {
    return AuthFailure(
      message: _mapFirebaseAuthError(e.code),
      code: e.code,
    );
  }
  
  static String _mapFirebaseAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'weak-password':
        return 'Please choose a stronger password.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'requires-recent-login':
        return 'Please sign in again to complete this action.';
      default:
        return 'An authentication error occurred. Please try again.';
    }
  }
}

/// Failure related to Firestore database operations
class DatabaseFailure extends Failure {
  const DatabaseFailure({required super.message, super.code});
  
  factory DatabaseFailure.fromFirestore(dynamic error) {
    String message = 'A database error occurred.';
    String? code;
    
    if (error is FirebaseException) {
      code = error.code;
      switch (error.code) {
        case 'permission-denied':
          message = 'You don\'t have permission to perform this action.';
          break;
        case 'not-found':
          message = 'The requested data was not found.';
          break;
        case 'already-exists':
          message = 'This item already exists.';
          break;
        case 'resource-exhausted':
          message = 'Too many requests. Please try again later.';
          break;
        case 'unavailable':
          message = 'Service temporarily unavailable. Please try again.';
          break;
        default:
          message = error.message ?? 'A database error occurred.';
      }
    }
    
    return DatabaseFailure(message: message, code: code);
  }
}

/// Failure related to Firebase Storage operations
class StorageFailure extends Failure {
  const StorageFailure({required super.message, super.code});
  
  factory StorageFailure.fromFirebaseStorage(dynamic error) {
    String message = 'A storage error occurred.';
    String? code;
    
    if (error is FirebaseException) {
      code = error.code;
      switch (error.code) {
        case 'storage/unauthorized':
          message = 'You don\'t have permission to access this file.';
          break;
        case 'storage/canceled':
          message = 'Upload was cancelled.';
          break;
        case 'storage/unknown':
          message = 'An unknown error occurred during upload.';
          break;
        case 'storage/object-not-found':
          message = 'File not found.';
          break;
        case 'storage/bucket-not-found':
          message = 'Storage bucket not found.';
          break;
        case 'storage/quota-exceeded':
          message = 'Storage quota exceeded.';
          break;
        case 'storage/retry-limit-exceeded':
          message = 'Upload failed. Please try again.';
          break;
        default:
          message = 'Failed to upload file. Please try again.';
      }
    }
    
    return StorageFailure(message: message, code: code);
  }
}

/// Failure related to network operations
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection. Please check your network.',
    super.code = 'network-error',
  });
}

/// Failure related to input validation
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, super.code = 'validation-error'});
}

/// Failure for unexpected errors
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({
    super.message = 'An unexpected error occurred. Please try again.',
    super.code = 'unexpected-error',
  });
  
  factory UnexpectedFailure.fromException(dynamic e) {
    return UnexpectedFailure(message: e.toString());
  }
}

/// Failure for cache operations
class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Failed to access cached data.',
    super.code = 'cache-error',
  });
}
