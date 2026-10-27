import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:widget_flutter/providers/auth_provider.dart';
import 'package:widget_flutter/providers/merchant_provider.dart';
import 'package:widget_flutter/core/constants/app_colors.dart';
import 'package:widget_flutter/screens/merchant/dashboard_screen.dart';
import 'package:widget_flutter/screens/merchant/restaurant_screen.dart';
import 'package:widget_flutter/screens/merchant/products_screen.dart';
import 'package:widget_flutter/screens/merchant/categories_screen.dart';
import 'package:widget_flutter/screens/merchant/orders_screen.dart';
import 'package:widget_flutter/services/push_notification_service.dart';

class MerchantMainNav extends StatefulWidget {
  const MerchantMainNav({super.key});

  @override
  State<MerchantMainNav> createState() => _MerchantMainNavState();
}

class _MerchantMainNavState extends State<MerchantMainNav> {
  int _currentIndex = 0;
  late final List<Widget> _pages;
  late final MerchantProvider _merchant;
  late final AuthProvider _auth;

  @override
  void initState() {
    super.initState();
    _pages = const [
      DashboardScreen(),
      RestaurantScreen(),
      ProductsScreen(),
      CategoriesScreen(),
      OrdersScreen(),
    ];
    _merchant = context.read<MerchantProvider>();
    _auth = context.read<AuthProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _merchant.loadAll(_auth);
      _merchant.startPolling(_auth);
      PushNotificationService.openPendingOrder();
    });
  }

  @override
  void dispose() {
    _merchant.stopPolling();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.storefront_outlined),
                if (_merchant.restaurant == null)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Center(
                        child: Text(
                          '!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            activeIcon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.storefront),
                if (_merchant.restaurant == null)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Center(
                        child: Text(
                          '!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Restaurant',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu_outlined),
            activeIcon: Icon(Icons.restaurant_menu),
            label: 'Products',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.category_outlined),
            activeIcon: Icon(Icons.category),
            label: 'Categories',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
        ],
      ),
    );
  }
}
