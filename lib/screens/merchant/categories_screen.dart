import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:widget_flutter/core/constants/app_colors.dart';
import 'package:widget_flutter/core/widgets/custom_app_bar.dart';
import 'package:widget_flutter/models/merchant/merchant_category.dart';
import 'package:widget_flutter/providers/auth_provider.dart';
import 'package:widget_flutter/providers/merchant_provider.dart';
import 'package:widget_flutter/routes/app_route.dart';
import 'package:widget_flutter/widgets/cached_image.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final merchant = context.watch<MerchantProvider>();
    return Scaffold(
      backgroundColor: const Color(0xffF8F8F8),
      appBar: const CustomAppBar(
        showNotification: false,
        title: 'My Categories',
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'categories_fab',
        backgroundColor: AppColors.primary,
        onPressed: () => context.push(AppRoute.merchantCategoryForm),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: merchant.loading && merchant.categories.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : merchant.categories.isEmpty
              ? const Center(child: Text('No categories yet'))
              : RefreshIndicator(
                  onRefresh: () =>
                      merchant.loadAll(context.read<AuthProvider>()),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: merchant.categories.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final c = merchant.categories[index];
                      return _CategoryCard(category: c);
                    },
                  ),
                ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final MerchantCategory category;
  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    final count = context
        .watch<MerchantProvider>()
        .products
        .where((p) => p.categoryId == category.id)
        .length;
    return Container(
      padding: const EdgeInsets.all(12),
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
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: category.image.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: CachedImage(category.image, fit: BoxFit.cover),
                  )
                : Icon(Icons.category, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  '$count products',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, size: 20),
            onPressed: () => context.push(
              AppRoute.merchantCategoryForm,
              extra: category,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, size: 20, color: Colors.red),
            onPressed: () => _confirmDelete(context, category),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, MerchantCategory category) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Delete "${category.name}"?'),
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
                    .deleteCategory(
                      context.read<AuthProvider>(),
                      category.id,
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
