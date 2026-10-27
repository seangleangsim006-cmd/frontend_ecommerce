import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:widget_flutter/providers/auth_provider.dart';
import 'package:widget_flutter/providers/address_provider.dart';
import 'package:widget_flutter/providers/cart_provider.dart';
import 'package:widget_flutter/providers/customer_order_provider.dart';
import 'package:widget_flutter/providers/merchant_provider.dart';
import 'package:widget_flutter/providers/product_provider.dart';
import 'package:widget_flutter/providers/search_provider.dart';
import 'package:widget_flutter/routes/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
          ChangeNotifierProvider(create: (context) => AddressProvider()),
          ChangeNotifierProvider(create: (context) => CartProvider(),),
          ChangeNotifierProvider(create: (context) => SearchProvider(),),
          ChangeNotifierProvider(create: (context) => AuthProvider()),
          ChangeNotifierProvider(create: (context) => ProductProvider()),
          ChangeNotifierProvider(create: (context) => MerchantProvider()),
          ChangeNotifierProvider(create: (context) => CustomerOrderProvider()),
      ],
      
      child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routerConfig: appRouter,
    );
  }
}
