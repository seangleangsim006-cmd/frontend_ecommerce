import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:widget_flutter/core/constants/app_colors.dart';
import 'package:widget_flutter/core/widgets/custom_app_bar.dart';
import 'package:widget_flutter/models/merchant/merchant_product.dart';
import 'package:widget_flutter/providers/auth_provider.dart';
import 'package:widget_flutter/providers/merchant_provider.dart';
import 'package:widget_flutter/routes/app_route.dart';
import 'package:widget_flutter/widgets/cached_image.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final merchant = context.watch<MerchantProvider>();
    return Scaffold(
      backgroundColor: const Color(0xffF8F8F8),
      appBar: const CustomAppBar(
        showNotification: false,
        title: 'My Products',
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'products_fab',
        backgroundColor: AppColors.primary,
        onPressed: () => context.push(AppRoute.merchantProductForm),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: merchant.loading && merchant.products.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : merchant.products.isEmpty
              ? const Center(child: Text('No products yet'))
              : RefreshIndicator(
                  onRefresh: () =>
                      merchant.loadAll(context.read<AuthProvider>()),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: merchant.products.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final p = merchant.products[index];
                      return _ProductCard(product: p);
                    },
                  ),
                ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final MerchantProduct product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final merchant = context.read<MerchantProvider>();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 8,
          ),
          ClipRRect(
            borderRadius:
                const BorderRadius.horizontal(left: Radius.circular(16)),
            child: product.image.isNotEmpty
                ? CachedImage(product.image, width: 80, height: 80)
                : Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.fastfood, color: Colors.grey),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Switch(
                value: product.isAvailable,
                activeColor: AppColors.primary,
                onChanged: (_) => merchant.toggleProductAvailability(
                  context.read<AuthProvider>(),
                  product,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () => context.push(
                      AppRoute.merchantProductForm,
                      extra: product,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                    onPressed: () => _confirmDelete(context, product),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, MerchantProduct product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Delete "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await context
                    .read<MerchantProvider>()
                    .deleteProduct(
                      context.read<AuthProvider>(),
                      product.id,
                    );
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
