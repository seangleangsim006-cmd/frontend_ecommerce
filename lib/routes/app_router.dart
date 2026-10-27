import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:widget_flutter/main_navigation.dart';
import 'package:widget_flutter/models/merchant/merchant_order.dart';
import 'package:widget_flutter/models/product.dart';
import 'package:widget_flutter/models/restaurant.dart';
import 'package:widget_flutter/models/category.dart';
import 'package:widget_flutter/models/customer_order.dart';
import 'package:widget_flutter/routes/app_route.dart';
import 'package:widget_flutter/screens/auth/login_screen.dart';
import 'package:widget_flutter/screens/auth/forgot_password_screen.dart';
import 'package:widget_flutter/screens/auth/reset_password_screen.dart';
import 'package:widget_flutter/screens/auth/register_screen.dart';
import 'package:widget_flutter/screens/auth/verify_otp_screen.dart';
import 'package:widget_flutter/screens/auth/splash_screen.dart';
import 'package:widget_flutter/screens/customer/cart_screen.dart';
import 'package:widget_flutter/screens/customer/checkout_screen.dart';
import 'package:widget_flutter/screens/customer/detail_product_screen.dart';
import 'package:widget_flutter/screens/customer/detail_restaurant_screen.dart';
import 'package:widget_flutter/screens/customer/map/google_map_screen.dart';
import 'package:widget_flutter/screens/customer/home_screen.dart';
import 'package:widget_flutter/screens/customer/addresses_screen.dart';
import 'package:widget_flutter/screens/customer/favorites_screen.dart';
import 'package:widget_flutter/screens/customer/orders_screen.dart';
import 'package:widget_flutter/screens/customer/order_history_screen.dart';
import 'package:widget_flutter/screens/customer/payments_screen.dart';
import 'package:widget_flutter/screens/customer/notifications_screen.dart';
import 'package:widget_flutter/screens/customer/search_screen.dart';
import 'package:widget_flutter/screens/customer/help_screen.dart';
import 'package:widget_flutter/screens/customer/about_screen.dart';
import 'package:widget_flutter/screens/customer/category_products_screen.dart';
import 'package:widget_flutter/screens/customer/tracking_order_screen.dart';
import 'package:widget_flutter/models/merchant/merchant_product.dart';
import 'package:widget_flutter/models/merchant/merchant_category.dart';
import 'package:widget_flutter/screens/merchant/merchant_main_nav.dart';
import 'package:widget_flutter/screens/merchant/restaurant_screen.dart';
import 'package:widget_flutter/screens/merchant/products_screen.dart';
import 'package:widget_flutter/screens/merchant/product_form_screen.dart';
import 'package:widget_flutter/screens/merchant/categories_screen.dart';
import 'package:widget_flutter/screens/merchant/category_form_screen.dart';
import 'package:widget_flutter/screens/merchant/orders_screen.dart';
import 'package:widget_flutter/screens/merchant/order_detail_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoute.splash,
  routes: [
    GoRoute(
      path: AppRoute.splash,
      builder: (context, state) => const SplashScreen(),
    ),

    GoRoute(
      path: AppRoute.register,
      builder: (context, state) => RegisterScreen(
        draft: state.extra is RegistrationDraft
            ? state.extra as RegistrationDraft
            : null,
      ),
    ),
    GoRoute(
      path: AppRoute.verifyOtp,
      builder: (context, state) {
        final extra = state.extra;
        final draft = extra is RegistrationDraft ? extra : null;
        final phone = draft?.phone ?? (extra is String ? extra : null);
        if (phone == null || phone.isEmpty) {
          return const Scaffold(
            body: Center(child: Text('Phone number not found')),
          );
        }
        return VerifyOtpScreen(phone: phone, draft: draft);
      },
    ),

    GoRoute(path: AppRoute.login, builder: (context, state) => LoginScreen()),
    GoRoute(
      path: AppRoute.forgotPassword,
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: AppRoute.resetPassword,
      builder: (context, state) => ResetPasswordScreen(
        email: state.uri.queryParameters['email'] ?? '',
        token: state.uri.queryParameters['token'] ?? '',
      ),
    ),
    GoRoute(path: AppRoute.home, builder: (context, state) => HomeScreen()),
    GoRoute(
      path: AppRoute.mianNav,
      builder: (context, state) => MainNavigationScreen(),
    ),
    GoRoute(
      path: AppRoute.detailRestaurant,
      builder: (context, state) {
        final res = state.extra as Restaurant;
        return DetailRestaurantScreen(res: res);
      },
    ),
    GoRoute(
      path: AppRoute.detailProduct,
      builder: (context, state) {
        final pro = state.extra as Product;
        return DetailProductScreen(pro: pro);
      },
    ),
    GoRoute(path: AppRoute.cart, builder: (context, state) => CartScreen()),

    GoRoute(
      path: AppRoute.checkout,
      builder: (context, state) {
        return CheckoutScreen();
      },
    ),
    GoRoute(
      path: AppRoute.map,
      builder: (context, state) => ProLocationPicker(),
    ),
    GoRoute(
      path: AppRoute.orders,
      builder: (context, state) => const OrderScreen(),
    ),
    GoRoute(
      path: AppRoute.orderHistory,
      builder: (context, state) => const OrderHistoryScreen(),
    ),
    GoRoute(
      path: AppRoute.orderDetail,
      builder: (context, state) {
        final order = state.extra as CustomerOrder;
        return CustomerOrderDetailScreen(order: order);
      },
    ),
    GoRoute(
      path: AppRoute.addresses,
      builder: (context, state) => const AddressesScreen(),
    ),
    GoRoute(
      path: AppRoute.favorites,
      builder: (context, state) => const FavoritesScreen(),
    ),
    GoRoute(
      path: AppRoute.payments,
      builder: (context, state) => const PaymentsScreen(),
    ),
    GoRoute(
      path: AppRoute.notifications,
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: AppRoute.search,
      builder: (context, state) => const SearchScreen(),
    ),
    GoRoute(
      path: AppRoute.help,
      builder: (context, state) => const HelpScreen(),
    ),
    GoRoute(
      path: AppRoute.about,
      builder: (context, state) => const AboutScreen(),
    ),
    GoRoute(
      path: AppRoute.categoryProducts,
      builder: (context, state) {
        final category = state.extra as Category?;
        if (category == null) {
          return const Scaffold(
            body: Center(child: Text('Category not found')),
          );
        }
        return CategoryProductsScreen(
          categoryId: category.id,
          categoryName: category.name,
        );
      },
    ),

    // Merchant
    GoRoute(
      path: AppRoute.merchantNav,
      builder: (context, state) => const MerchantMainNav(),
    ),
    GoRoute(
      path: AppRoute.merchantRestaurant,
      builder: (context, state) => const RestaurantScreen(),
    ),
    GoRoute(
      path: AppRoute.merchantProducts,
      builder: (context, state) => const ProductsScreen(),
    ),
    GoRoute(
      path: AppRoute.merchantProductForm,
      builder: (context, state) {
        final product = state.extra as MerchantProduct?;
        return ProductFormScreen(product: product);
      },
    ),
    GoRoute(
      path: AppRoute.merchantCategories,
      builder: (context, state) => const CategoriesScreen(),
    ),
    GoRoute(
      path: AppRoute.merchantCategoryForm,
      builder: (context, state) {
        final category = state.extra as MerchantCategory?;
        return CategoryFormScreen(category: category);
      },
    ),
    GoRoute(
      path: '/merchant/orders/:id',
      builder: (context, state) {
        final order = state.extra;
        return MerchantOrderDetailScreen(
          order: order is MerchantOrder ? order : null,
          orderId: int.tryParse(state.pathParameters['id'] ?? ''),
        );
      },
    ),
    GoRoute(
      path: AppRoute.merchantOrders,
      builder: (context, state) => const OrdersScreen(),
    ),
  ],
);
