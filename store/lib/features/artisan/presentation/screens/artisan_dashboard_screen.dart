import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../orders/providers/order_provider.dart';
import '../../providers/artisan_provider.dart';
import '../widgets/stat_card.dart';
import '../widgets/recent_orders_list.dart';

/// Main dashboard for artisans showing stats and quick actions.
class ArtisanDashboardScreen extends ConsumerWidget {
  const ArtisanDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final artisanAsync = ref.watch(currentArtisanProvider);
    final statsAsync = ref.watch(artisanStatsProvider);
    final pendingCount = ref.watch(pendingOrdersCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Implement notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push(AppRoutes.artisanProfile),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(artisanStatsProvider);
          ref.invalidate(artisanOrdersStreamProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome section
              _buildWelcomeSection(context, user?.name ?? 'Artisan', artisanAsync),
              const SizedBox(height: 24),
              // Stats grid
              _buildStatsGrid(context, statsAsync, pendingCount),
              const SizedBox(height: 24),
              // Quick actions
              _buildQuickActions(context),
              const SizedBox(height: 24),
              // Recent orders
              _buildRecentOrdersSection(context, ref),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context, pendingCount),
    );
  }

  Widget _buildWelcomeSection(
    BuildContext context,
    String name,
    AsyncValue artisanAsync,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: const Icon(Icons.storefront, color: AppColors.primary, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back,',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  Text(
                    name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  artisanAsync.when(
                    data: (artisan) => Text(
                      artisan?.shopName ?? '',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(
    BuildContext context,
    AsyncValue<Map<String, dynamic>> statsAsync,
    int pendingCount,
  ) {
    return statsAsync.when(
      data: (stats) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overview',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              StatCard(
                title: 'Total Sales',
                value: '\$${(stats['totalSales'] ?? 0.0).toStringAsFixed(2)}',
                icon: Icons.attach_money,
                color: AppColors.success,
              ),
              StatCard(
                title: 'Total Orders',
                value: '${stats['totalOrders'] ?? 0}',
                icon: Icons.shopping_cart,
                color: AppColors.info,
              ),
              StatCard(
                title: 'Pending Orders',
                value: '$pendingCount',
                icon: Icons.pending_actions,
                color: AppColors.warning,
                showBadge: pendingCount > 0,
              ),
              StatCard(
                title: 'Products',
                value: '${stats['totalProducts'] ?? 0}',
                icon: Icons.inventory_2,
                color: AppColors.primary,
              ),
            ],
          ),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error loading stats: $e')),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionButton(
                icon: Icons.add_box,
                label: 'Add Product',
                onTap: () => context.push(AppRoutes.artisanAddProduct),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.inventory,
                label: 'View Products',
                onTap: () => context.push(AppRoutes.artisanProducts),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.receipt_long,
                label: 'View Orders',
                onTap: () => context.push(AppRoutes.artisanOrders),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentOrdersSection(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Orders',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton(
              onPressed: () => context.push(AppRoutes.artisanOrders),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const RecentOrdersList(limit: 5),
      ],
    );
  }

  Widget _buildBottomNav(BuildContext context, int pendingCount) {
    return BottomNavigationBar(
      currentIndex: 0,
      onTap: (index) {
        switch (index) {
          case 0:
            // Already on dashboard
            break;
          case 1:
            context.go(AppRoutes.artisanProducts);
            break;
          case 2:
            context.go(AppRoutes.artisanOrders);
            break;
          case 3:
            context.go(AppRoutes.artisanProfile);
            break;
        }
      },
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.inventory_2),
          label: 'Products',
        ),
        BottomNavigationBarItem(
          icon: Badge(
            isLabelVisible: pendingCount > 0,
            label: Text('$pendingCount'),
            child: const Icon(Icons.receipt_long),
          ),
          label: 'Orders',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
