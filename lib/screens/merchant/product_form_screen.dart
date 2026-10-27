import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:widget_flutter/core/constants/app_colors.dart';
import 'package:widget_flutter/core/widgets/app_button.dart';
import 'package:widget_flutter/core/widgets/app_text_field.dart';
import 'package:widget_flutter/core/widgets/custom_app_bar.dart';
import 'package:widget_flutter/models/merchant/merchant_category.dart';
import 'package:widget_flutter/models/merchant/merchant_product.dart';
import 'package:widget_flutter/providers/auth_provider.dart';
import 'package:widget_flutter/providers/merchant_provider.dart';
import 'package:widget_flutter/widgets/cached_image.dart';

class ProductFormScreen extends StatefulWidget {
  final MerchantProduct? product;
  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();
  final _stockController = TextEditingController();
  File? _pickedImage;
  final ImagePicker _picker = ImagePicker();
  int? _categoryId;
  bool _available = true;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    if (p != null) {
      _nameController.text = p.name;
      _priceController.text = p.price.toString();
      _descController.text = p.description;
      _stockController.text = (p.stock ?? 0).toString();
      _categoryId = p.categoryId;
      _available = p.isAvailable;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (picked != null && mounted) {
        setState(() => _pickedImage = File(picked.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open image picker: $e')),
        );
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<MerchantProvider>();
    final isEdit = widget.product != null;

    if (!isEdit && _pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image')),
      );
      return;
    }
    if (_categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    final name = _nameController.text.trim();
    final description = _descController.text.trim();
    final price = double.parse(_priceController.text.trim());
    final stock = int.tryParse(_stockController.text.trim()) ?? 0;

    try {
      if (!isEdit) {
        await provider.createProduct(
          auth: context.read<AuthProvider>(),
          name: name,
          description: description,
          price: price,
          categoryId: _categoryId!,
          isAvailable: _available,
          image: _pickedImage!,
          restaurantId: provider.restaurant?.id,
          stock: stock,
        );
      } else {
        await provider.updateProduct(
          auth: context.read<AuthProvider>(),
          id: widget.product!.id,
          name: name,
          description: description,
          price: price,
          categoryId: _categoryId!,
          isAvailable: _available,
          image: _pickedImage,
          stock: stock,
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saved')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
        log(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<MerchantProvider>().categories;
    final isEdit = widget.product != null;
    final currentImage = widget.product?.image ?? '';
    return Scaffold(
      backgroundColor: const Color(0xffF8F8F8),
      appBar: CustomAppBar(
        showBackButton: true,
        showNotification: false,
        title: isEdit ? 'Edit Product' : 'New Product',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _field(
                isEdit ? 'Change Image (optional)' : 'Image',
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                      ),
                    ),
                    child: _pickedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(_pickedImage!, fit: BoxFit.cover),
                          )
                        : currentImage.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: CachedImage(currentImage, fit: BoxFit.cover),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_a_photo_outlined,
                                    size: 40,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(height: 8),
                                  const Text('Tap to select image'),
                                ],
                              ),
                  ),
                ),
              ),
              _field(
                'Name',
                AppTextField(
                  hintText: 'Product name',
                  controller: _nameController,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Required' : null,
                ),
              ),
              _field(
                'Price (\$)',
                AppTextField(
                  hintText: '0.00',
                  controller: _priceController,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (double.tryParse(v) == null) return 'Invalid number';
                    return null;
                  },
                ),
              ),
              _field(
                'Description',
                AppTextField(
                  hintText: 'Description',
                  controller: _descController,
                ),
              ),
              _field(
                'Stock',
                AppTextField(
                  hintText: '0',
                  controller: _stockController,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (int.tryParse(v) == null) return 'Invalid number';
                    return null;
                  },
                ),
              ),
              _field(
                'Category',
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int?>(
                      isExpanded: true,
                      value: _categoryId,
                      hint: const Text('Select category'),
                      items: categories
                          .map(
                            (MerchantCategory c) => DropdownMenuItem<int?>(
                              value: c.id,
                              child: Text(c.name),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _categoryId = v),
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Available'),
                    Switch(
                      value: _available,
                      activeColor: AppColors.primary,
                      onChanged: (v) => setState(() => _available = v),
                    ),
                  ],
                ),
              ),
              AppButton(text: 'Save', onPressed: () => _save()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(String label, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child:
              Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ),
        child,
        const SizedBox(height: 16),
      ],
    );
  }
}
