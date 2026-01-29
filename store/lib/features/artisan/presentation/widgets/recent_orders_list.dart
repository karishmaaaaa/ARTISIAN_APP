import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../models/order_model.dart';
import '../../../orders/providers/order_provider.dart';

/// Widget showing recent orders for artisan dashboard.
class RecentOrdersList extends ConsumerWidget {
  final int limit;

  const RecentOrdersList({
    super.key,
    this.limit = 5,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(artisanOrdersStreamProvider);

    return ordersAsync.when(
      data: (orders) {
        if (orders.isEmpty) {
          return _buildEmptyState(context);
        }

        final limitedOrders = orders.take(limit).toList();

        return Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: limitedOrders.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              return _OrderTile(order: limitedOrders[index]);
            },
          ),
        );
      },
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, _) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(child: Text('Error loading orders: $error')),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No orders yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Orders will appear here when customers purchase your products',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  final OrderModel order;

  const _OrderTile({required this.order});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        context.push('/artisan/orders/${order.id}');
      },
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.getOrderStatusColor(order.status.value).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          order.status.icon,
          color: AppColors.getOrderStatusColor(order.status.value),
          size: 20,
        ),
      ),
      title: Text(
        'Order #${order.id.substring(0, 8).toUpperCase()}',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '${order.totalItems} items - ${order.createdAt.toRelativeTime()}',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            order.total.toCurrency(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.getOrderStatusColor(order.status.value).withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              order.status.displayName,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppColors.getOrderStatusColor(order.status.value),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
