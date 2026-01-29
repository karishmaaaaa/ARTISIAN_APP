import 'package:share_plus/share_plus.dart';

import '../core/errors/failures.dart';
import '../core/errors/result.dart';

/// Service for sharing content (storefront links, products).
/// 
/// Enables artisans to share their storefront URLs and
/// customers to share products they like.
class ShareService {
  /// Share artisan storefront link
  Future<Result<void>> shareStorefront({
    required String artisanId,
    required String shopName,
  }) async {
    try {
      final url = _generateStorefrontUrl(artisanId);
      final text = 'Check out $shopName\'s handmade products on Artisan Marketplace!\n$url';
      
      await Share.share(
        text,
        subject: '$shopName - Artisan Marketplace',
      );
      
      return Result.success(null);
    } catch (e) {
      return Result.failure(UnexpectedFailure.fromException(e));
    }
  }
  
  /// Share product
  Future<Result<void>> shareProduct({
    required String productId,
    required String productName,
    required String shopName,
  }) async {
    try {
      final url = _generateProductUrl(productId);
      final text = 'Check out "$productName" by $shopName on Artisan Marketplace!\n$url';
      
      await Share.share(
        text,
        subject: '$productName - Artisan Marketplace',
      );
      
      return Result.success(null);
    } catch (e) {
      return Result.failure(UnexpectedFailure.fromException(e));
    }
  }
  
  /// Share app download link
  Future<Result<void>> shareApp() async {
    try {
      const text = 'Discover unique handmade products from local artisans on Artisan Marketplace!\n'
          'Download the app: [App Store/Play Store Link]';
      
      await Share.share(
        text,
        subject: 'Artisan Marketplace',
      );
      
      return Result.success(null);
    } catch (e) {
      return Result.failure(UnexpectedFailure.fromException(e));
    }
  }
  
  /// Generate deep link URL for storefront
  String _generateStorefrontUrl(String artisanId) {
    // TODO: Replace with actual deep link domain
    return 'https://artisanmarketplace.com/storefront/$artisanId';
  }
  
  /// Generate deep link URL for product
  String _generateProductUrl(String productId) {
    // TODO: Replace with actual deep link domain
    return 'https://artisanmarketplace.com/product/$productId';
  }
  
  /// Get shareable storefront URL
  String getStorefrontUrl(String artisanId) {
    return _generateStorefrontUrl(artisanId);
  }
  
  /// Get shareable product URL
  String getProductUrl(String productId) {
    return _generateProductUrl(productId);
  }
}
