import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:widget_flutter/core/constants/app_colors.dart';
import 'package:widget_flutter/core/widgets/custom_app_bar.dart';
import 'package:widget_flutter/core/widgets/app_text_field.dart';
import 'package:widget_flutter/models/category.dart';
import 'package:widget_flutter/providers/auth_provider.dart';
import 'package:widget_flutter/providers/product_provider.dart';
import 'package:widget_flutter/routes/app_route.dart';
import 'package:widget_flutter/widgets/cached_image.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider = context.read<ProductProvider>();
      if (productProvider.product.isEmpty) {
        productProvider.getProduct();
      }
      if (productProvider.category.isEmpty) {
        productProvider.getCategory();
      }
      if (productProvider.restaurant.isEmpty) {
        productProvider.getRestaurant();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final authProvider = context.watch<AuthProvider>();
    final categories = productProvider.category;
    final uniqueCategories = categories.fold<List<Category>>([], (list, cat) {
      if (list.any((c) => c.name.toLowerCase() == cat.name.toLowerCase())) {
        return list;
      }
      return list..add(cat);
    });

    final isInitialLoad =
        productProvider.isLoading &&
        productProvider.product.isEmpty &&
        productProvider.restaurant.isEmpty &&
        productProvider.category.isEmpty;
    final hasError =
        productProvider.message != null &&
        !productProvider.isLoading &&
        productProvider.product.isEmpty &&
        productProvider.restaurant.isEmpty &&
        productProvider.category.isEmpty;

    return Scaffold(
      appBar: CustomAppBar(
        showBackButton: false,
        showNotification: true,
        isCustomer: true,
        profileImageUrl: authProvider.user?.avatar,
        hasUnreadNotifications: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final productProvider = context.read<ProductProvider>();
          await productProvider.getProduct();
          await productProvider.getCategory();
          await productProvider.getRestaurant();
        },
        child: isInitialLoad
            ? const Center(child: CircularProgressIndicator())
            : hasError
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.wifi_off_rounded,
                        size: 80,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Unable to load content',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        productProvider.message ??
                            'Please check your connection and try again.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final pp = context.read<ProductProvider>();
                          await pp.getProduct();
                          await pp.getCategory();
                          await pp.getRestaurant();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () => context.push(AppRoute.search),
                        child: AbsorbPointer(
                          child: AppTextField(
                            hintText: "Search for restaurant or food",
                            icon: Icons.search,
                            controller: _searchController,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Category",
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            "See All",
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 202,
                        child: GridView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: uniqueCategories.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisExtent: 92,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                          itemBuilder: (context, index) {
                            final cat = uniqueCategories[index];
                            return GestureDetector(
                              onTap: () => context.push(
                                AppRoute.categoryProducts,
                                extra: cat,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: CachedImage(
                                      cat.image,
                                      width: 60,
                                      height: 60,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    cat.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Restuarant",
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            "See All",
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 252,
                        width: double.infinity,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: productProvider.restaurant.length,
                          itemBuilder: (context, index) {
                            final res = productProvider.restaurant[index];
                            return Padding(
                              padding: const EdgeInsets.only(
                                right: 14,
                                top: 8,
                                bottom: 8,
                              ),
                              child: GestureDetector(
                                onTap: () => context.push(
                                  AppRoute.detailRestaurant,
                                  extra: res,
                                ),
                                child: Container(
                                  width: 260,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.08,
                                        ),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: 136,
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            res.logoUrl.isNotEmpty
                                                ? CachedImage(
                                                    res.logoUrl,
                                                    fit: BoxFit.cover,
                                                  )
                                                : Container(
                                                    color: const Color(
                                                      0xFFFFF1E6,
                                                    ),
                                                    child: Icon(
                                                      Icons.restaurant_rounded,
                                                      size: 46,
                                                      color: AppColors.primary
                                                          .withValues(alpha: 0.6),
                                                    ),
                                                  ),
                                            Positioned(
                                              left: 10,
                                              top: 10,
                                              child: _restaurantPill(
                                                icon: Icons.location_on_rounded,
                                                label: res.address,
                                              ),
                                            ),
                                            Positioned(
                                              right: 10,
                                              bottom: 10,
                                              child: _restaurantPill(
                                                icon: Icons.star_rounded,
                                                label: res.rating.toStringAsFixed(1),
                                                iconColor: const Color(
                                                  0xFFFFB300,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          12,
                                          10,
                                          12,
                                          11,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              res.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              res.tags.isNotEmpty
                                                  ? res.tags.take(2).join(' • ')
                                                  : 'Popular local restaurant',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 12,
                                              ),
                                            ),
                                            const SizedBox(height: 9),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.access_time_rounded,
                                                  size: 16,
                                                  color: AppColors.primary,
                                                ),
                                                const SizedBox(width: 5),
                                                Text(
                                                  res.deliveryTime,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(width: 9),
                                                Container(
                                                  width: 4,
                                                  height: 4,
                                                  decoration:
                                                      const BoxDecoration(
                                                        color: AppColors.primary,
                                                        shape: BoxShape.circle,
                                                      ),
                                                ),
                                                const SizedBox(width: 9),
                                                Text(
                                                  'Free delivery',
                                                  style: TextStyle(
                                                    color: Colors.grey.shade600,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Recommended for you",
                            style: TextStyle(fontSize: 20),
                          ),
                          TextButton(
                            onPressed: () =>
                                context.push(AppRoute.categoryProducts),
                            child: Text(
                              "See All",
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 246,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: productProvider.product.length > 10
                              ? 10
                              : productProvider.product.length,
                          itemBuilder: (context, index) {
                            final pro = productProvider.product[index];
                            return GestureDetector(
                              onTap: () => context.push(
                                AppRoute.detailProduct,
                                extra: pro,
                              ),
                              child: Container(
                                width: 178,
                                margin: const EdgeInsets.only(right: 14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.07),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: double.infinity,
                                      height: 140,
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          CachedImage(
                                            pro.image,
                                            fit: BoxFit.cover,
                                          ),
                                          Positioned(
                                            left: 10,
                                            top: 10,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 5,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withValues(
                                                  alpha: 0.92,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(9),
                                              ),
                                              child: Text(
                                                pro.category.name,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        11,
                                        10,
                                        10,
                                        10,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            pro.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            pro.restaurant.name,
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 11,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Text(
                                                "\$${pro.price.toStringAsFixed(2)}",
                                                style: const TextStyle(
                                                  color: AppColors.primary,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const Spacer(),
                                              Container(
                                                width: 30,
                                                height: 30,
                                                decoration: BoxDecoration(
                                                  color: AppColors.primary,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: const Center(
                                                  child: Icon(
                                                    Icons.add_rounded,
                                                    color: Colors.white,
                                                    size: 19,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _restaurantPill({
    required IconData icon,
    required String label,
    Color iconColor = AppColors.primary,
  }) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 170),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
