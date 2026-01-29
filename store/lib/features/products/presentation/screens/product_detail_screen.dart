import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../models/product_model.dart';
import '../../../../core/utils/extensions.dart';
import '../../providers/product_provider.dart';
import '../../../cart/providers/cart_provider.dart';

typedef Product = ProductModel;

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _currentImageIndex = 0;
  int _quantity = 1;
  bool _isWishlisted = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final productAsync = ref.watch(productByIdProvider(widget.productId));

    return Scaffold(
      body: productAsync.when(
        data: (product) {
          if (product == null) {
            return const Center(child: Text('Product not found'));
          }
          return _buildProductDetail(context, product);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              Text('Error loading product', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.invalidate(productByIdProvider(widget.productId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductDetail(BuildContext context, Product product) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return CustomScrollView(
      slivers: [
        // Image gallery
        SliverAppBar(
          expandedHeight: size.height * 0.45,
          pinned: true,
          actions: [
            IconButton(
              icon: Icon(
                _isWishlisted ? Icons.favorite : Icons.favorite_border,
                color: _isWishlisted ? Colors.red : null,
              ),
              onPressed: () => setState(() => _isWishlisted = !_isWishlisted),
            ),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                // Share product
              },
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              children: [
                PageView.builder(
                  itemCount: product.imageUrls.isNotEmpty ? product.imageUrls.length : 1,
                  onPageChanged: (index) => setState(() => _currentImageIndex = index),
                  itemBuilder: (context, index) {
                    if (product.imageUrls.isEmpty) {
                      return Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.image,
                          size: 100,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                        ),
                      );
                    }
                    return CachedNetworkImage(
                      imageUrl: product.imageUrls[index],
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: const Icon(Icons.error),
                      ),
                    );
                  },
                ),
                if (product.imageUrls.length > 1)
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        product.imageUrls.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentImageIndex == index ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentImageIndex == index
                                ? theme.colorScheme.primary
                                : Colors.white.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        // Product details
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and price
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (product.rating > 0)
                            Row(
                              children: [
                                ...List.generate(
                                  5,
                                  (index) => Icon(
                                    index < product.rating.floor()
                                        ? Icons.star
                                        : index < product.rating
                                            ? Icons.star_half
                                            : Icons.star_border,
                                    size: 18,
                                    color: Colors.amber.shade600,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${product.rating} (${product.totalReviews} reviews)',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (product.compareAtPrice != null &&
                            product.compareAtPrice! > product.price)
                          Text(
                            product.compareAtPrice!.toCurrency(),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              decoration: TextDecoration.lineThrough,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                        Text(
                          product.price.toCurrency(),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Artisan info
                _buildArtisanSection(context, product),
                const SizedBox(height: 24),

                // Description
                Text(
                  'Description',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  product.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),

                // Product details
                _buildDetailsSection(context, product),
                const SizedBox(height: 24),

                // Quantity selector
                _buildQuantitySection(context, product),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildArtisanSection(BuildContext context, Product product) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => context.push('/artisans/${product.artisanId}'),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(Icons.person, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Artisan Name',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'View artisan profile',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsSection(BuildContext context, Product product) {
    final theme = Theme.of(context);
    final attributes = product.attributes;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _DetailRow(
            icon: Icons.category_outlined,
            label: 'Category',
            value: product.category,
          ),
          if (attributes != null && attributes['materials'] != null) ...[
            const Divider(),
            _DetailRow(
              icon: Icons.palette_outlined,
              label: 'Materials',
              value: attributes['materials'].toString(),
            ),
          ],
          if (attributes != null && attributes['dimensions'] != null) ...[
            const Divider(),
            _DetailRow(
              icon: Icons.straighten,
              label: 'Dimensions',
              value: attributes['dimensions'].toString(),
            ),
          ],
          const Divider(),
          _DetailRow(
            icon: Icons.inventory_2_outlined,
            label: 'In Stock',
            value: product.stockQuantity > 0
                ? '${product.stockQuantity} available'
                : 'Out of stock',
            valueColor: product.stockQuantity > 0 ? Colors.green : theme.colorScheme.error,
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySection(BuildContext context, Product product) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(
          'Quantity',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: _quantity > 1
                    ? () => setState(() => _quantity--)
                    : null,
              ),
              SizedBox(
                width: 40,
                child: Text(
                  '$_quantity',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: _quantity < product.stockQuantity
                    ? () => setState(() => _quantity++)
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: valueColor ?? theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
