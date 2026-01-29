import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../models/product_model.dart';
import '../../../../models/category_model.dart';
import '../../../../core/utils/validators.dart';
import '../../../products/providers/product_provider.dart';
import '../../providers/artisan_provider.dart';

class AddEditProductScreen extends ConsumerStatefulWidget {
  final String? productId;

  const AddEditProductScreen({super.key, this.productId});

  @override
  ConsumerState<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends ConsumerState<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _materialsController = TextEditingController();
  final _dimensionsController = TextEditingController();
  
  Category? _selectedCategory;
  ProductStatus _status = ProductStatus.draft;
  List<String> _imageUrls = [];
  List<File> _newImages = [];
  bool _isLoading = false;
  bool _isCustomizable = false;
  int _productionDays = 7;

  bool get isEditing => widget.productId != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _loadProduct();
    }
  }

  Future<void> _loadProduct() async {
    final product = await ref.read(productByIdProvider(widget.productId!).future);
    if (product != null && mounted) {
      setState(() {
        _nameController.text = product.name;
        _descriptionController.text = product.description;
        _priceController.text = product.price.toString();
        _stockController.text = product.stockQuantity.toString();
        _materialsController.text = product.materials.join(', ');
        _dimensionsController.text = product.dimensions ?? '';
        _status = product.status;
        _imageUrls = List.from(product.images);
        _isCustomizable = product.isCustomizable;
        _productionDays = product.productionDays;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _materialsController.dispose();
    _dimensionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Product' : 'Add Product'),
        actions: [
          if (isEditing)
            TextButton(
              onPressed: _status == ProductStatus.draft ? _publishProduct : null,
              child: const Text('Publish'),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Image Section
            _buildImageSection(theme),
            const SizedBox(height: 24),

            // Basic Info Section
            _buildSectionHeader('Basic Information', theme),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Product Name *',
                hintText: 'Enter product name',
              ),
              validator: Validators.required('Product name is required'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description *',
                hintText: 'Describe your product...',
                alignLabelWithHint: true,
              ),
              validator: Validators.required('Description is required'),
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            categoriesAsync.when(
              data: (categories) => DropdownButtonFormField<Category>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category *',
                ),
                items: categories.map((cat) => DropdownMenuItem(
                  value: cat,
                  child: Text(cat.name),
                )).toList(),
                onChanged: (value) => setState(() => _selectedCategory = value),
                validator: (value) => value == null ? 'Please select a category' : null,
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const Text('Error loading categories'),
            ),
            const SizedBox(height: 24),

            // Pricing Section
            _buildSectionHeader('Pricing & Stock', theme),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'Price *',
                      prefixText: '\$ ',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    validator: Validators.combine([
                      Validators.required('Price is required'),
                      Validators.minValue(0.01, 'Price must be greater than 0'),
                    ]),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _stockController,
                    decoration: const InputDecoration(
                      labelText: 'Stock Quantity *',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: Validators.required('Stock quantity is required'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Details Section
            _buildSectionHeader('Product Details', theme),
            const SizedBox(height: 12),
            TextFormField(
              controller: _materialsController,
              decoration: const InputDecoration(
                labelText: 'Materials',
                hintText: 'e.g., Cotton, Wood, Leather',
                helperText: 'Separate materials with commas',
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _dimensionsController,
              decoration: const InputDecoration(
                labelText: 'Dimensions',
                hintText: 'e.g., 10cm x 15cm x 5cm',
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Customizable'),
              subtitle: const Text('Allow customers to request customizations'),
              value: _isCustomizable,
              onChanged: (value) => setState(() => _isCustomizable = value),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Production Time',
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: _productionDays > 1
                          ? () => setState(() => _productionDays--)
                          : null,
                    ),
                    Text(
                      '$_productionDays days',
                      style: theme.textTheme.titleMedium,
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: _productionDays < 60
                          ? () => setState(() => _productionDays++)
                          : null,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Status Section
            _buildSectionHeader('Status', theme),
            const SizedBox(height: 12),
            SegmentedButton<ProductStatus>(
              segments: const [
                ButtonSegment(
                  value: ProductStatus.draft,
                  label: Text('Draft'),
                  icon: Icon(Icons.edit_note),
                ),
                ButtonSegment(
                  value: ProductStatus.active,
                  label: Text('Active'),
                  icon: Icon(Icons.check_circle_outline),
                ),
              ],
              selected: {_status},
              onSelectionChanged: (values) => setState(() => _status = values.first),
            ),
            const SizedBox(height: 32),

            // Submit Button
            FilledButton(
              onPressed: _isLoading ? null : _saveProduct,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(isEditing ? 'Update Product' : 'Create Product'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildImageSection(ThemeData theme) {
    final allImages = [
      ..._imageUrls.map((url) => _ImageItem(url: url)),
      ..._newImages.map((file) => _ImageItem(file: file)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Product Images', theme),
        const SizedBox(height: 8),
        Text(
          'Add up to 5 images. First image will be the cover.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              if (allImages.length < 5)
                _AddImageButton(onTap: _pickImages),
              ...allImages.asMap().entries.map((entry) => _ImageTile(
                item: entry.value,
                isCover: entry.key == 0,
                onRemove: () => _removeImage(entry.key),
              )),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage(
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );

    if (images.isNotEmpty) {
      final totalImages = _imageUrls.length + _newImages.length + images.length;
      final imagesToAdd = totalImages <= 5 
          ? images 
          : images.take(5 - _imageUrls.length - _newImages.length).toList();
      
      setState(() {
        _newImages.addAll(imagesToAdd.map((xfile) => File(xfile.path)));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      if (index < _imageUrls.length) {
        _imageUrls.removeAt(index);
      } else {
        _newImages.removeAt(index - _imageUrls.length);
      }
    });
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageUrls.isEmpty && _newImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one image')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final materials = _materialsController.text
          .split(',')
          .map((m) => m.trim())
          .where((m) => m.isNotEmpty)
          .toList();

      final product = Product(
        id: widget.productId ?? '',
        artisanId: '', // Will be set by repository
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text),
        categoryId: _selectedCategory?.id ?? '',
        images: _imageUrls,
        stockQuantity: int.parse(_stockController.text),
        status: _status,
        materials: materials,
        dimensions: _dimensionsController.text.trim().isNotEmpty 
            ? _dimensionsController.text.trim() 
            : null,
        isCustomizable: _isCustomizable,
        productionDays: _productionDays,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (isEditing) {
        await ref.read(productNotifierProvider.notifier).updateProduct(product);
      } else {
        await ref.read(productNotifierProvider.notifier).createProduct(product);
      }

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? 'Product updated successfully' : 'Product created successfully'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _publishProduct() async {
    setState(() => _status = ProductStatus.active);
    await _saveProduct();
  }
}

class _ImageItem {
  final String? url;
  final File? file;

  _ImageItem({this.url, this.file});
}

class _AddImageButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddImageButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.outline,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 32,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 4),
            Text(
              'Add Image',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageTile extends StatelessWidget {
  final _ImageItem item;
  final bool isCover;
  final VoidCallback onRemove;

  const _ImageTile({
    required this.item,
    required this.isCover,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: isCover
                ? Border.all(color: theme.colorScheme.primary, width: 2)
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(isCover ? 10 : 12),
            child: item.url != null
                ? Image.network(item.url!, fit: BoxFit.cover)
                : Image.file(item.file!, fit: BoxFit.cover),
          ),
        ),
        if (isCover)
          Positioned(
            bottom: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Cover',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
          ),
        Positioned(
          top: 4,
          right: 12,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: theme.colorScheme.error,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                size: 14,
                color: theme.colorScheme.onError,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
