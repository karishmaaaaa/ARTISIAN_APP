import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/product_model.dart';
import '../../../repositories/product_repository.dart';
import '../../../core/errors/result.dart';
import '../../auth/providers/auth_provider.dart';

/// Provider for the ProductRepository instance
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository();
});

/// Provider for products by artisan (for artisan's product management)
final artisanProductsProvider = StreamProvider.family<List<ProductModel>, String>(
  (ref, artisanId) {
    final repo = ref.watch(productRepositoryProvider);
    return repo.productsStreamByArtisan(artisanId);
  },
);

/// Provider for current artisan's products
final myProductsProvider = StreamProvider<List<ProductModel>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null || !user.isArtisan) {
    return const Stream.empty();
  }
  
  final repo = ref.watch(productRepositoryProvider);
  return repo.productsStreamByArtisan(user.id);
});

/// Provider for a single product
final productProvider = FutureProvider.family<ProductModel?, String>(
  (ref, productId) async {
    final repo = ref.watch(productRepositoryProvider);
    final result = await repo.getProduct(productId);
    return result.dataOrNull;
  },
);

/// Provider for featured products
final featuredProductsProvider = FutureProvider<List<ProductModel>>((ref) async {
  final repo = ref.watch(productRepositoryProvider);
  final result = await repo.getFeaturedProducts();
  return result.getOrElse([]);
});

/// State for product browsing with filters
class ProductBrowseState {
  final List<ProductModel> products;
  final bool isLoading;
  final bool hasMore;
  final String? error;
  final String? category;
  final String? searchQuery;
  final double? minPrice;
  final double? maxPrice;
  final String sortBy;
  final bool descending;

  const ProductBrowseState({
    this.products = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.error,
    this.category,
    this.searchQuery,
    this.minPrice,
    this.maxPrice,
    this.sortBy = 'createdAt',
    this.descending = true,
  });

  ProductBrowseState copyWith({
    List<ProductModel>? products,
    bool? isLoading,
    bool? hasMore,
    String? error,
    String? category,
    String? searchQuery,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    bool? descending,
  }) {
    return ProductBrowseState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error,
      category: category ?? this.category,
      searchQuery: searchQuery ?? this.searchQuery,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      sortBy: sortBy ?? this.sortBy,
      descending: descending ?? this.descending,
    );
  }
}

/// Notifier for product browsing
class ProductBrowseNotifier extends StateNotifier<ProductBrowseState> {
  final ProductRepository _repository;

  ProductBrowseNotifier(this._repository) : super(const ProductBrowseState()) {
    loadProducts();
  }

  /// Load products with current filters
  Future<void> loadProducts({bool refresh = false}) async {
    if (state.isLoading) return;

    state = state.copyWith(
      isLoading: true,
      error: null,
      products: refresh ? [] : state.products,
    );

    final result = await _repository.getProducts(
      category: state.category,
      searchQuery: state.searchQuery,
      minPrice: state.minPrice,
      maxPrice: state.maxPrice,
      sortBy: state.sortBy,
      descending: state.descending,
    );

    result.when(
      success: (products) {
        state = state.copyWith(
          products: products,
          isLoading: false,
          hasMore: products.length >= 12,
        );
      },
      failure: (error) {
        state = state.copyWith(
          isLoading: false,
          error: error.message,
        );
      },
    );
  }

  /// Set category filter
  void setCategory(String? category) {
    state = state.copyWith(category: category);
    loadProducts(refresh: true);
  }

  /// Set search query
  void setSearchQuery(String? query) {
    state = state.copyWith(searchQuery: query);
    loadProducts(refresh: true);
  }

  /// Set price range filter
  void setPriceRange(double? min, double? max) {
    state = state.copyWith(minPrice: min, maxPrice: max);
    loadProducts(refresh: true);
  }

  /// Set sort option
  void setSort(String sortBy, bool descending) {
    state = state.copyWith(sortBy: sortBy, descending: descending);
    loadProducts(refresh: true);
  }

  /// Clear all filters
  void clearFilters() {
    state = const ProductBrowseState();
    loadProducts(refresh: true);
  }
}

/// Provider for product browsing with filters
final productBrowseProvider =
    StateNotifierProvider<ProductBrowseNotifier, ProductBrowseState>((ref) {
  final repo = ref.watch(productRepositoryProvider);
  return ProductBrowseNotifier(repo);
});

/// Controller for product CRUD operations
class ProductController {
  final ProductRepository _repository;

  ProductController(this._repository);

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
  }) {
    return _repository.createProduct(
      artisanId: artisanId,
      name: name,
      description: description,
      price: price,
      compareAtPrice: compareAtPrice,
      category: category,
      tags: tags,
      stockQuantity: stockQuantity,
      images: images,
      attributes: attributes,
    );
  }

  /// Update a product
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
  }) {
    return _repository.updateProduct(
      productId: productId,
      name: name,
      description: description,
      price: price,
      compareAtPrice: compareAtPrice,
      category: category,
      tags: tags,
      stockQuantity: stockQuantity,
      imageUrls: imageUrls,
      newImages: newImages,
      isActive: isActive,
      isFeatured: isFeatured,
      attributes: attributes,
    );
  }

  /// Delete a product
  Future<Result<void>> deleteProduct({
    required String productId,
    required String artisanId,
  }) {
    return _repository.deleteProduct(
      productId: productId,
      artisanId: artisanId,
    );
  }

  /// Delete a product image
  Future<Result<void>> deleteProductImage({
    required String productId,
    required String imageUrl,
  }) {
    return _repository.deleteProductImage(
      productId: productId,
      imageUrl: imageUrl,
    );
  }
}

/// Provider for product controller
final productControllerProvider = Provider<ProductController>((ref) {
  final repo = ref.watch(productRepositoryProvider);
  return ProductController(repo);
});
