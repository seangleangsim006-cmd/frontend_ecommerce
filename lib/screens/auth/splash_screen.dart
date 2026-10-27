import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:widget_flutter/providers/auth_provider.dart';
import 'package:widget_flutter/routes/app_route.dart';
import 'package:widget_flutter/screens/auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      final authProvider = context.read<AuthProvider>();
      await authProvider.initPrefs();
      if (!mounted) return;
      final token = authProvider.token;
      print('Splash screen token check: $token');
      if (token != null && token.isNotEmpty) {
        print('Navigating to main-nav');
        final role = authProvider.user?.role;
        if (role == 'merchant') {
          context.go(AppRoute.merchantNav);
        } else {
          context.go(AppRoute.mianNav);
        }
      } else {
        print('Navigating to login');
        context.go(AppRoute.login);
      }
    } catch (e) {
      print('Splash screen error: $e');
      if (!mounted) return;
      context.go(AppRoute.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          "assets/logo/my_logo.png",
          width: 200,
        ),
        
      ),
    );
  }
}