import '../constants/app_constants.dart';

/// Centralized input validation utilities.
/// 
/// Provides consistent validation logic across the application
/// with user-friendly error messages.
class Validators {
  Validators._();
  
  /// Validates an email address
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }
  
  /// Validates a password
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < AppConstants.minPasswordLength) {
      return 'Password must be at least ${AppConstants.minPasswordLength} characters';
    }
    
    // Check for at least one letter and one number
    if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)').hasMatch(value)) {
      return 'Password must contain letters and numbers';
    }
    
    return null;
  }
  
  /// Validates password confirmation
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    
    if (value != password) {
      return 'Passwords do not match';
    }
    
    return null;
  }
  
  /// Validates a required field
  static String? validateRequired(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
  
  /// Validates a name (no special characters)
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    
    if (value.length > 50) {
      return 'Name must be less than 50 characters';
    }
    
    return null;
  }
  
  /// Validates a phone number
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Phone is optional
    }
    
    // Remove common formatting characters
    final cleanedValue = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(cleanedValue)) {
      return 'Please enter a valid phone number';
    }
    
    return null;
  }
  
  /// Validates a product name
  static String? validateProductName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Product name is required';
    }
    
    if (value.length < 3) {
      return 'Product name must be at least 3 characters';
    }
    
    if (value.length > AppConstants.maxProductNameLength) {
      return 'Product name must be less than ${AppConstants.maxProductNameLength} characters';
    }
    
    return null;
  }
  
  /// Validates a product description
  static String? validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Description is required';
    }
    
    if (value.length < 10) {
      return 'Description must be at least 10 characters';
    }
    
    if (value.length > AppConstants.maxDescriptionLength) {
      return 'Description must be less than ${AppConstants.maxDescriptionLength} characters';
    }
    
    return null;
  }
  
  /// Validates a price
  static String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Price is required';
    }
    
    final price = double.tryParse(value);
    
    if (price == null) {
      return 'Please enter a valid price';
    }
    
    if (price < AppConstants.minProductPrice) {
      return 'Price must be at least \$${AppConstants.minProductPrice}';
    }
    
    if (price > AppConstants.maxProductPrice) {
      return 'Price cannot exceed \$${AppConstants.maxProductPrice}';
    }
    
    return null;
  }
  
  /// Validates stock quantity
  static String? validateStock(String? value) {
    if (value == null || value.isEmpty) {
      return 'Stock quantity is required';
    }
    
    final stock = int.tryParse(value);
    
    if (stock == null) {
      return 'Please enter a valid number';
    }
    
    if (stock < 0) {
      return 'Stock cannot be negative';
    }
    
    if (stock > 99999) {
      return 'Stock cannot exceed 99,999';
    }
    
    return null;
  }
  
  /// Validates an address
  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Address is required';
    }
    
    if (value.length < 10) {
      return 'Please enter a complete address';
    }
    
    if (value.length > 200) {
      return 'Address is too long';
    }
    
    return null;
  }
  
  /// Validates a URL
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null; // URL is optional
    }
    
    final urlPattern = RegExp(
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
      caseSensitive: false,
    );
    
    if (!urlPattern.hasMatch(value)) {
      return 'Please enter a valid URL';
    }
    
    return null;
  }
}
