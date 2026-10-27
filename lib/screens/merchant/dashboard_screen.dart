import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:widget_flutter/core/constants/app_colors.dart';
import 'package:widget_flutter/providers/auth_provider.dart';
import 'package:widget_flutter/providers/merchant_provider.dart';
import 'package:widget_flutter/routes/app_route.dart';
import 'package:widget_flutter/core/widgets/custom_app_bar.dart';
import 'package:widget_flutter/widgets/cached_image.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final merchant = context.watch<MerchantProvider>();

    return Scaffold(
      backgroundColor: const Color(0xffF8F8F8),
      appBar: const CustomAppBar(showNotification: false),
      body: merchant.loading && merchant.restaurant == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => merchant.loadAll(authProvider),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _RestaurantCard(restaurant: merchant.restaurant),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _StatCard(
                          value: '${merchant.products.length}',
                          title: 'Products',
                          icon: Icons.restaurant_menu,
                          onTap: () => context.push(AppRoute.merchantProducts),
                        ),
                        const SizedBox(width: 12),
                        _StatCard(
                          value: '${merchant.categories.length}',
                          title: 'Categories',
                          icon: Icons.category,
                          onTap: () => context.push(AppRoute.merchantCategories),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _StatCard(
                          value: '${merchant.orders.length}',
                          title: 'Orders',
                          icon: Icons.receipt_long,
                          onTap: () => context.push(AppRoute.merchantOrders),
                        ),
                        const SizedBox(width: 12),
                        _StatCard(
                          value:
                              '${merchant.orders.where((o) => o.status == 'pending').length}',
                          title: 'Pending',
                          icon: Icons.hourglass_empty,
                          onTap: () => context.push(AppRoute.merchantOrders),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const _SectionTitle('Quick Actions'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _ActionTile(
                            icon: Icons.add_circle_outline,
                            label: 'Add Product',
                            onTap: () =>
                                context.push(AppRoute.merchantProductForm),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionTile(
                            icon: Icons.add_box_outlined,
                            label: 'Add Category',
                            onTap: () =>
                                context.push(AppRoute.merchantCategoryForm),
                          ),
                        ),
                      ],
                    ),
                    if (merchant.restaurant == null) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => context.push(AppRoute.merchantRestaurant),
                          icon: const Icon(Icons.storefront_outlined),
                          label: const Text('Add Restaurant'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    const _SectionTitle('Recent Orders'),
                    const SizedBox(height: 12),
                    ...merchant.orders.take(3).map(
                          (o) => _OrderPreview(order: o),
                        ),
                    if (merchant.orders.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            'No orders yet',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await authProvider.logout();
                          if (context.mounted) {
                            context.go(AppRoute.login);
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.logout),
                        label: const Text('Logout'),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
    );
  }
}

class _RestaurantCard extends StatelessWidget {
  final dynamic restaurant;
  const _RestaurantCard({this.restaurant});

  @override
  Widget build(BuildContext context) {
    final has = restaurant != null;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: has && restaurant.logoUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CachedImage(restaurant.logoUrl, fit: BoxFit.cover),
                  )
                : const Icon(Icons.store, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  has ? restaurant.name : 'No restaurant yet',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  has ? restaurant.address : 'Create your restaurant profile',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => context.push(AppRoute.merchantRestaurant),
            icon: const Icon(Icons.edit, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _StatCard({
    required this.value,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderPreview extends StatelessWidget {
  final dynamic order;
  const _OrderPreview({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.receipt_long, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order #${order.id}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  order.customerName ?? 'Customer',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _statusColor(order.status).withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              order.status.toUpperCase(),
              style: TextStyle(
                color: _statusColor(order.status),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'accepted':
        return Colors.blue;
      default:
        return AppColors.primary;
    }
  }
}
