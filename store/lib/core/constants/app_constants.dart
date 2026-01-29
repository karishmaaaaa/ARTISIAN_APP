/// Application-wide constants and configuration values.
class AppConstants {
  AppConstants._();
  
  // App Info
  static const String appName = 'Artisan Marketplace';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'A digital storefront for local artisans';
  
  // Firebase Collection Names
  static const String usersCollection = 'users';
  static const String artisansCollection = 'artisans';
  static const String productsCollection = 'products';
  static const String ordersCollection = 'orders';
  static const String orderItemsCollection = 'orderItems';
  static const String categoriesCollection = 'categories';
  static const String cartCollection = 'cart';
  static const String reviewsCollection = 'reviews';
  
  // Firebase Storage Paths
  static const String productImagesPath = 'products';
  static const String profileImagesPath = 'profiles';
  static const String storefrontImagesPath = 'storefronts';
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int productsPerPage = 12;
  static const int ordersPerPage = 15;
  
  // Image Constraints
  static const int maxImageWidth = 1200;
  static const int maxImageHeight = 1200;
  static const int imageQuality = 85;
  static const int maxProductImages = 5;
  static const int maxFileSizeMB = 5;
  
  // Validation
  static const int minPasswordLength = 8;
  static const int maxProductNameLength = 100;
  static const int maxDescriptionLength = 1000;
  static const int minProductPrice = 1;
  static const int maxProductPrice = 1000000;
  
  // Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000;
  
  // Cache Duration
  static const int cacheDurationMinutes = 30;
  
  // Date Formats
  static const String dateFormat = 'MMM dd, yyyy';
  static const String dateTimeFormat = 'MMM dd, yyyy HH:mm';
  static const String timeFormat = 'HH:mm';
}

/// User roles in the application
enum UserRole {
  artisan('artisan'),
  customer('customer');
  
  const UserRole(this.value);
  final String value;
  
  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.customer,
    );
  }
}

/// Order status enum with display values
enum OrderStatus {
  pending('pending', 'Pending'),
  accepted('accepted', 'Accepted'),
  shipped('shipped', 'Shipped'),
  completed('completed', 'Completed'),
  cancelled('cancelled', 'Cancelled');
  
  const OrderStatus(this.value, this.displayName);
  final String value;
  final String displayName;
  
  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (status) => status.value == value.toLowerCase(),
      orElse: () => OrderStatus.pending,
    );
  }
  
  /// Get the next possible status transitions
  List<OrderStatus> get nextStatuses {
    switch (this) {
      case OrderStatus.pending:
        return [OrderStatus.accepted, OrderStatus.cancelled];
      case OrderStatus.accepted:
        return [OrderStatus.shipped, OrderStatus.cancelled];
      case OrderStatus.shipped:
        return [OrderStatus.completed];
      case OrderStatus.completed:
      case OrderStatus.cancelled:
        return [];
    }
  }
}

/// Product categories
class ProductCategories {
  ProductCategories._();
  
  static const List<String> defaultCategories = [
    'Jewelry',
    'Pottery',
    'Textiles',
    'Woodwork',
    'Paintings',
    'Sculptures',
    'Leather Goods',
    'Glassware',
    'Candles',
    'Home Decor',
    'Clothing',
    'Accessories',
    'Food & Beverages',
    'Bath & Beauty',
    'Stationery',
    'Other',
  ];
}
