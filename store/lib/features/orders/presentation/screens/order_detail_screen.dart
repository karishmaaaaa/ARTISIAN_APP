import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrderDetailScreen extends ConsumerWidget {
  final String orderId;
  final bool isArtisan;

  const OrderDetailScreen({
    super.key,
    required this.orderId,
    required this.isArtisan,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Order ID: $orderId'),
            Text('Is Artisan View: $isArtisan'),
            const SizedBox(height: 16),
            const Text('Order Detail Screen - Coming Soon'),
          ],
        ),
      ),
    );
  }
}
