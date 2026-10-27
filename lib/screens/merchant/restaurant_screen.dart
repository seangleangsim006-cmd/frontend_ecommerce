import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:widget_flutter/core/constants/app_colors.dart';
import 'package:widget_flutter/core/widgets/app_button.dart';
import 'package:widget_flutter/core/widgets/app_text_field.dart';
import 'package:widget_flutter/core/widgets/custom_app_bar.dart';
import 'package:widget_flutter/models/merchant/merchant_restaurant.dart';
import 'package:widget_flutter/providers/auth_provider.dart';
import 'package:widget_flutter/providers/merchant_provider.dart';
import 'package:widget_flutter/widgets/cached_image.dart';

class RestaurantScreen extends StatefulWidget {
  const RestaurantScreen({super.key});

  @override
  State<RestaurantScreen> createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends State<RestaurantScreen> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _deliveryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  File? _pickedLogo;
  bool _initialized = false;
  bool _editing = false;

  void _populateFields() {
    final r = context.read<MerchantProvider>().restaurant;
    if (r == null) return;
    _nameController.text = r.name;
    _addressController.text = r.address;
    _deliveryController.text = r.deliveryTime;
    _descriptionController.text = r.description ?? '';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final r = context.watch<MerchantProvider>().restaurant;
      if (r != null) {
        _populateFields();
        _initialized = true;
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (picked != null && mounted) {
        setState(() {
          _pickedLogo = File(picked.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open image picker: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _deliveryController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<MerchantProvider>();
    final existing = provider.restaurant;
    final restaurant = MerchantRestaurant(
      id: existing?.id ?? 0,
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
      deliveryTime: _deliveryController.text.trim(),
      description: _descriptionController.text.trim(),
      logo: existing?.logo,
    );
    try {
      await provider.saveRestaurant(
        context.read<AuthProvider>(),
        restaurant,
        image: _pickedLogo,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Restaurant saved'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _editing = false;
          _pickedLogo = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MerchantProvider>();
    final r = provider.restaurant;
    if (!_initialized && r != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _populateFields();
          setState(() {
            _initialized = true;
          });
        }
      });
    }

    final isEditing = _editing || r == null;

    return Scaffold(
      backgroundColor: const Color(0xffF8F8F8),
      appBar: const CustomAppBar(
        showBackButton: true,
        showNotification: false,
        title: 'My Restaurant',
      ),
      floatingActionButton: isEditing
          ? null
          : FloatingActionButton(
              heroTag: 'restaurant_fab',
              backgroundColor: AppColors.primary,
              onPressed: () => setState(() => _editing = true),
              child: const Icon(Icons.edit, color: Colors.white),
            ),
      body: isEditing
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(26),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: _pickedLogo != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.file(_pickedLogo!, fit: BoxFit.cover),
                                )
                              : r != null && r.logoUrl.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: CachedImage(r.logoUrl, fit: BoxFit.cover),
                                    )
                                  : Icon(
                                      Icons.store,
                                      size: 48,
                                      color: AppColors.primary,
                                    ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap to select logo',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(height: 24),
                    _Label('Restaurant Name'),
                    AppTextField(
                      hintText: 'Name',
                      controller: _nameController,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    _Label('Address'),
                    AppTextField(
                      hintText: 'Address',
                      controller: _addressController,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    _Label('Delivery Time'),
                    AppTextField(
                      hintText: 'e.g. 30 min',
                      controller: _deliveryController,
                    ),
                    const SizedBox(height: 16),
                    _Label('Description'),
                    AppTextField(
                      hintText: 'Short description',
                      controller: _descriptionController,
                    ),
                    const SizedBox(height: 28),
                    AppButton(
                      text: provider.loading ? 'Saving...' : 'Save Changes',
                      onPressed: provider.loading ? null : () => _save(),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: provider.loading
                          ? null
                          : () => setState(() => _editing = false),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: () => provider.loadAll(context.read<AuthProvider>()),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(10),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: r.logoUrl.isNotEmpty
                              ? CachedImage(
                                  r.logoUrl,
                                  width: double.infinity,
                                  height: 180,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  width: double.infinity,
                                  height: 180,
                                  color: Colors.grey.shade200,
                                  child: const Icon(
                                    Icons.store,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                                ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                r.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(r.address),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.schedule, size: 16),
                                  const SizedBox(width: 6),
                                  Text(r.deliveryTime),
                                ],
                              ),
                              if (r.description != null && r.description!.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Text(r.description!),
                              ],
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () => setState(() => _editing = true),
                                icon: const Icon(Icons.edit),
                                label: const Text('Edit'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
