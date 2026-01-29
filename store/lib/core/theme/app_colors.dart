import 'package:flutter/material.dart';

/// Centralized color constants for the application.
/// 
/// These colors complement the Material 3 theme and provide
/// additional semantic colors for specific use cases.
class AppColors {
  AppColors._();

  // Primary Brand Colors
  static const Color primary = Color(0xFF8B4513);
  static const Color primaryLight = Color(0xFFBC714A);
  static const Color primaryDark = Color(0xFF5C1A00);
  
  // Secondary Colors
  static const Color secondary = Color(0xFFD2691E);
  static const Color secondaryLight = Color(0xFFFF9A4D);
  static const Color secondaryDark = Color(0xFF9C3B00);
  
  // Accent Colors
  static const Color accent = Color(0xFFF4A460);
  static const Color accentLight = Color(0xFFFFD690);
  static const Color accentDark = Color(0xFFBF7532);
  
  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);
  
  // Semantic Colors
  static const Color success = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFF60AD5E);
  static const Color successDark = Color(0xFF005005);
  
  static const Color error = Color(0xFFB00020);
  static const Color errorLight = Color(0xFFE94948);
  static const Color errorDark = Color(0xFF790000);
  
  static const Color warning = Color(0xFFF57C00);
  static const Color warningLight = Color(0xFFFFAD42);
  static const Color warningDark = Color(0xFFBB4D00);
  
  static const Color info = Color(0xFF0288D1);
  static const Color infoLight = Color(0xFF5EB8FF);
  static const Color infoDark = Color(0xFF005B9F);
  
  // Order Status Colors
  static const Color statusPending = Color(0xFFFFA726);
  static const Color statusAccepted = Color(0xFF42A5F5);
  static const Color statusShipped = Color(0xFF7E57C2);
  static const Color statusCompleted = Color(0xFF66BB6A);
  static const Color statusCancelled = Color(0xFFEF5350);
  
  // Background Colors
  static const Color backgroundLight = Color(0xFFFFFBF8);
  static const Color backgroundDark = Color(0xFF1A1A1A);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF2D2D2D);
  
  // Gradient Definitions
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, secondary],
  );
  
  /// Returns the appropriate color for an order status
  static Color getOrderStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return statusPending;
      case 'accepted':
        return statusAccepted;
      case 'shipped':
        return statusShipped;
      case 'completed':
        return statusCompleted;
      case 'cancelled':
        return statusCancelled;
      default:
        return grey500;
    }
  }
}
