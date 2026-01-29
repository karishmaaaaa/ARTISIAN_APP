import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProductManagementScreen extends ConsumerWidget {
  const ProductManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Products'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/artisan/products/add'),
        child: const Icon(Icons.add),
      ),
      body: const Center(
        child: Text('Product Management Screen - Coming Soon'),
      ),
    );
  }
}
