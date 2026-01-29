import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../models/product_model.dart';
import '../../../products/providers/product_provider.dart';
import '../../providers/artisan_provider.dart';
import '../widgets/product_management_card.dart';

class ProductManagementScreen extends ConsumerStatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  ConsumerState<ProductManagementScreen> createState() => _ProductManagementScreenState();
}

class _ProductManagementScreenState extends ConsumerState<ProductManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  ProductStatus? _statusFilter;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(artisanProductsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/artisan/products/add'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Active'),
            Tab(text: 'Draft'),
            Tab(text: 'Out of Stock'),
          ],
          onTap: (index) {
            setState(() {
              switch (index) {
                case 0:
                  _statusFilter = null;
                  break;
                case 1:
                  _statusFilter = ProductStatus.active;
                  break;
                case 2:
                  _statusFilter = ProductStatus.draft;
                  break;
                case 3:
                  _statusFilter = ProductStatus.outOfStock;
                  break;
              }
            });
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          Expanded(
            child: productsAsync.when(
              data: (products) {
                final filteredProducts = products.where((p) {
                  final matchesSearch = p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                      p.description.toLowerCase().contains(_searchQuery.toLowerCase());
                  final matchesStatus = _statusFilter == null || p.status == _statusFilter;
                  return matchesSearch && matchesStatus;
                }).toList();

                if (filteredProducts.isEmpty) {
                  return _buildEmptyState(context);
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(artisanProductsProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return ProductManagementCard(
                        product: product,
                        onEdit: () => context.push('/artisan/products/edit/${product.id}'),
                        onDelete: () => _showDeleteDialog(context, product),
                        onToggleStatus: () => _toggleProductStatus(product),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
                    const SizedBox(height: 16),
                    Text('Error loading products', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => ref.invalidate(artisanProductsProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/artisan/products/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No products found',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start adding products to your shop',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => context.push('/artisan/products/add'),
            icon: const Icon(Icons.add),
            label: const Text('Add First Product'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteDialog(BuildContext context, Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      ref.read(productNotifierProvider.notifier).deleteProduct(product.id);
    }
  }

  Future<void> _toggleProductStatus(Product product) async {
    final newStatus = product.status == ProductStatus.active
        ? ProductStatus.inactive
        : ProductStatus.active;
    
    ref.read(productNotifierProvider.notifier).updateProduct(
      product.copyWith(status: newStatus),
    );
  }
}
