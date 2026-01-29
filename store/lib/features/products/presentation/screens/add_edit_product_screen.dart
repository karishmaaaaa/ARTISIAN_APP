import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddEditProductScreen extends ConsumerStatefulWidget {
  final String? productId;

  const AddEditProductScreen({super.key, this.productId});

  @override
  ConsumerState<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends ConsumerState<AddEditProductScreen> {
  @override
  Widget build(BuildContext context) {
    final isEditing = widget.productId != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Product' : 'Add Product'),
      ),
      body: const Center(
        child: Text('Add/Edit Product Screen - Coming Soon'),
      ),
    );
  }
}
