import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_constants.dart';
import '../theme/app_colors.dart';

/// DateTime extensions for formatting
extension DateTimeExtensions on DateTime {
  /// Formats date as "Jan 15, 2024"
  String toFormattedDate() {
    return DateFormat(AppConstants.dateFormat).format(this);
  }
  
  /// Formats date and time as "Jan 15, 2024 14:30"
  String toFormattedDateTime() {
    return DateFormat(AppConstants.dateTimeFormat).format(this);
  }
  
  /// Formats time only as "14:30"
  String toFormattedTime() {
    return DateFormat(AppConstants.timeFormat).format(this);
  }
  
  /// Returns relative time string like "2 hours ago"
  String toRelativeTime() {
    final now = DateTime.now();
    final difference = now.difference(this);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} year${difference.inDays >= 730 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month${difference.inDays >= 60 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
  
  /// Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
  
  /// Check if date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }
}

/// String extensions
extension StringExtensions on String {
  /// Capitalizes the first letter
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
  
  /// Capitalizes each word
  String capitalizeWords() {
    return split(' ').map((word) => word.capitalize()).join(' ');
  }
  
  /// Truncates string with ellipsis
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - 3)}...';
  }
  
  /// Converts to slug format
  String toSlug() {
    return toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'[\s-]+'), '-')
        .trim();
  }
  
  /// Check if string is a valid email
  bool get isValidEmail {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(this);
  }
  
  /// Check if string is a valid URL
  bool get isValidUrl {
    return RegExp(r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$')
        .hasMatch(this);
  }
}

/// Double extensions for currency formatting
extension DoubleExtensions on double {
  /// Formats as currency string
  String toCurrency({String symbol = '\$', int decimalDigits = 2}) {
    final formatter = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: decimalDigits,
    );
    return formatter.format(this);
  }
  
  /// Formats as compact number
  String toCompact() {
    return NumberFormat.compact().format(this);
  }
}

/// Integer extensions
extension IntExtensions on int {
  /// Formats with thousand separators
  String toFormatted() {
    return NumberFormat('#,###').format(this);
  }
  
  /// Formats as compact number
  String toCompact() {
    return NumberFormat.compact().format(this);
  }
}

/// OrderStatus extensions for UI
extension OrderStatusExtensions on OrderStatus {
  /// Returns the color associated with this status
  Color get color => AppColors.getOrderStatusColor(value);
  
  /// Returns an icon for this status
  IconData get icon {
    switch (this) {
      case OrderStatus.pending:
        return Icons.hourglass_empty;
      case OrderStatus.accepted:
        return Icons.check_circle_outline;
      case OrderStatus.shipped:
        return Icons.local_shipping;
      case OrderStatus.completed:
        return Icons.done_all;
      case OrderStatus.cancelled:
        return Icons.cancel;
    }
  }
}

/// BuildContext extensions for common operations
extension BuildContextExtensions on BuildContext {
  /// Shows a snackbar with the given message
  void showSnackBar(
    String message, {
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(this).hideCurrentSnackBar();
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : null,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
  
  /// Shows a success snackbar
  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(this).hideCurrentSnackBar();
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
  
  /// Shows an error snackbar
  void showErrorSnackBar(String message) {
    showSnackBar(message, isError: true);
  }
  
  /// Gets the screen size
  Size get screenSize => MediaQuery.of(this).size;
  
  /// Checks if the device is in landscape mode
  bool get isLandscape => MediaQuery.of(this).orientation == Orientation.landscape;
  
  /// Checks if the device is a tablet (width >= 600)
  bool get isTablet => screenSize.shortestSide >= 600;
}

/// List extensions
extension ListExtensions<T> on List<T> {
  /// Returns the list with null values removed
  List<T> get withoutNulls => where((item) => item != null).toList();
  
  /// Chunks the list into sublists of the given size
  List<List<T>> chunked(int size) {
    final result = <List<T>>[];
    for (var i = 0; i < length; i += size) {
      result.add(sublist(i, i + size > length ? length : i + size));
    }
    return result;
  }
}
