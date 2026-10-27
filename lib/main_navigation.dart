import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:widget_flutter/core/widgets/app_buttom_nav.dart';
import 'package:widget_flutter/providers/auth_provider.dart';
import 'package:widget_flutter/providers/customer_order_provider.dart';
import 'package:widget_flutter/screens/customer/cart_screen.dart';
import 'package:widget_flutter/screens/customer/home_screen.dart';
import 'package:widget_flutter/screens/customer/profile_screen.dart';
import 'package:widget_flutter/screens/customer/search_screen.dart';
import 'package:widget_flutter/widgets/active_order_banner.dart';

class MainNavigationScreen extends StatefulWidget {

  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState
    extends State<MainNavigationScreen> {

  int _currentIndex = 0;
  late final CustomerOrderProvider _orderProvider;
  late final AuthProvider _auth;

  final List<Widget> _pages =  [
    HomeScreen(),
    SearchScreen(),
    CartScreen(),
    ProfileScreen(),
    
  ];

  @override
  void initState() {
    super.initState();
    _orderProvider = context.read<CustomerOrderProvider>();
    _auth = context.read<AuthProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _orderProvider.fetchOrders(_auth);
      _orderProvider.startPolling(_auth);
    });
  }

  @override
  void dispose() {
    _orderProvider.stopPolling();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: _pages,
            ),
          ),
          const ActiveOrderBanner(),
        ],
      ),

      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}