import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:widget_flutter/core/constants/app_colors.dart';
import 'package:widget_flutter/core/widgets/app_button.dart';
import 'package:widget_flutter/core/widgets/app_text_field.dart';
import 'package:widget_flutter/providers/auth_provider.dart';
import 'package:widget_flutter/routes/app_route.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _navigateByRole(AuthProvider authProvider) {
    final role = authProvider.user?.role?.trim().toLowerCase();

    if (role == 'merchant') {
      context.go(AppRoute.merchantNav);
    } else if (role == 'customer') {
      context.go(AppRoute.mianNav);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unsupported account role: ${role ?? 'unknown'}'),
        ),
      );
    }
  }

  Future<void> _submitLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();

    await authProvider.login(
      email: _emailController.text.trim().contains('@')
          ? _emailController.text.trim()
          : null,
      phone: _emailController.text.trim().contains('@')
          ? null
          : _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (!mounted) return;

    if (authProvider.user != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Login successfully")));

      _navigateByRole(authProvider);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login failed: ${authProvider.message}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isLoading = authProvider.loading ?? false;

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFFDF8F5),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;
            final formWidth = isWide ? 440.0 : constraints.maxWidth * 0.9;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: SizedBox(
                    width: isWide ? 1100 : constraints.maxWidth * 0.96,
                    child: Padding(
                      padding: EdgeInsets.all(isWide ? 28 : 20),
                      child: isWide
                          ? Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(28.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          "assets/logo/my_logo.png",
                                          width: 100,
                                        ),
                                        const SizedBox(height: 28),
                                        const Text(
                                          "Welcome to",
                                          style: TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF1F1F1F),
                                          ),
                                        ),
                                        const Text(
                                          "KitchenFlow",
                                          style: TextStyle(
                                            fontSize: 38,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          "Manage food orders, track your kitchen, and keep everything moving smoothly.",
                                          style: TextStyle(
                                            color: AppColors.neutral,
                                            fontSize: 16,
                                            height: 1.6,
                                          ),
                                        ),
                                        const SizedBox(height: 28),
                                        Wrap(
                                          spacing: 12,
                                          runSpacing: 12,
                                          children: [
                                            _FeatureChip(
                                              icon: Icons.delivery_dining,
                                              label: "Fast delivery",
                                            ),
                                            _FeatureChip(
                                              icon: Icons.storefront,
                                              label: "Order tracking",
                                            ),
                                            _FeatureChip(
                                              icon: Icons.analytics_outlined,
                                              label: "Smart insights",
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 24),
                                SizedBox(
                                  width: formWidth,
                                  child: Container(
                                    padding: const EdgeInsets.all(30.0),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(24),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.06,
                                          ),
                                          blurRadius: 20,
                                          offset: const Offset(0, 12),
                                        ),
                                      ],
                                    ),
                                    child: Form(
                                      key: _formKey,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "Welcome back",
                                            style: TextStyle(
                                              fontSize: 28,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF1F1F1F),
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            "Sign in to continue managing your orders.",
                                            style: TextStyle(
                                              color: AppColors.neutral,
                                              fontSize: 14,
                                              height: 1.5,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          const _SecureSignInNote(),
                                          if (authProvider.message != null) ...[
                                            const SizedBox(height: 14),
                                            _LoginErrorBanner(
                                              message: authProvider.message!,
                                            ),
                                          ],
                                          const SizedBox(height: 28),
                                          const Text(
                                            "Email or Phone",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF303030),
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          AppTextField(
                                            hintText:
                                                "Enter your email or phone number",
                                            icon: Icons.alternate_email,
                                            controller: _emailController,
                                            keyboardType: TextInputType.text,
                                            textInputAction:
                                                TextInputAction.next,
                                            validator: (value) {
                                              if (value == null ||
                                                  value.trim().isEmpty) {
                                                return "Please enter your email or phone number";
                                              }
                                              return null;
                                            },
                                          ),
                                          const SizedBox(height: 22),
                                          const Text(
                                            "Password",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF303030),
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          AppTextField(
                                            hintText: "Enter your password",
                                            icon: Icons.lock_outline,
                                            controller: _passwordController,
                                            isPassword: true,
                                            textInputAction:
                                                TextInputAction.done,
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return "Please enter password";
                                              }
                                              if (value.length < 6) {
                                                return "Password should be at least 6 characters";
                                              }
                                              return null;
                                            },
                                          ),
                                          const SizedBox(height: 14),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: TextButton(
                                              onPressed: isLoading
                                                  ? null
                                                  : () => context.go(
                                                      AppRoute.forgotPassword,
                                                    ),
                                              child: const Text(
                                                "Forgot password?",
                                                style: TextStyle(
                                                  color: AppColors.primary,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 14),
                                          AppButton(
                                            text: "Login",
                                            isLoading: isLoading,
                                            onPressed: isLoading
                                                ? null
                                                : _submitLogin,
                                          ),
                                          const SizedBox(height: 18),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Text(
                                                "Don't have an account?",
                                                style: TextStyle(
                                                  color: Color(0xFF555555),
                                                ),
                                              ),
                                              InkWell(
                                                onTap: isLoading
                                                    ? null
                                                    : () => context.go(
                                                        AppRoute.register,
                                                      ),
                                                child: Text(
                                                  " Register",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    color: AppColors.primary,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "assets/logo/my_logo.png",
                                  width: 110,
                                ),
                                const SizedBox(height: 18),
                                SizedBox(
                                  width: formWidth,
                                  child: Container(
                                    padding: const EdgeInsets.all(24.0),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(22),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.06,
                                          ),
                                          blurRadius: 18,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: Form(
                                      key: _formKey,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "Welcome back",
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF1F1F1F),
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            "Sign in to continue managing your orders.",
                                            style: TextStyle(
                                              color: AppColors.neutral,
                                              fontSize: 14,
                                              height: 1.5,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          const _SecureSignInNote(),
                                          if (authProvider.message != null) ...[
                                            const SizedBox(height: 14),
                                            _LoginErrorBanner(
                                              message: authProvider.message!,
                                            ),
                                          ],
                                          const SizedBox(height: 24),
                                          const Text("Email or Phone"),
                                          const SizedBox(height: 10),
                                          AppTextField(
                                            hintText:
                                                "Enter your email or phone number",
                                            icon: Icons.alternate_email,
                                            controller: _emailController,
                                            keyboardType: TextInputType.text,
                                            textInputAction:
                                                TextInputAction.next,
                                            validator: (value) {
                                              if (value == null ||
                                                  value.trim().isEmpty) {
                                                return "Please enter your email or phone number";
                                              }
                                              return null;
                                            },
                                          ),
                                          const SizedBox(height: 20),
                                          const Text("Password"),
                                          const SizedBox(height: 10),
                                          AppTextField(
                                            hintText: "Enter your password",
                                            icon: Icons.lock_outline,
                                            controller: _passwordController,
                                            isPassword: true,
                                            textInputAction:
                                                TextInputAction.done,
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return "Please enter password";
                                              }
                                              if (value.length < 6) {
                                                return "Password should be at least 6 characters";
                                              }
                                              return null;
                                            },
                                          ),
                                          const SizedBox(height: 14),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: TextButton(
                                              onPressed: isLoading
                                                  ? null
                                                  : () => context.go(
                                                      AppRoute.forgotPassword,
                                                    ),
                                              child: const Text(
                                                "Forgot password?",
                                                style: TextStyle(
                                                  color: AppColors.primary,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 14),
                                          AppButton(
                                            text: "Login",
                                            isLoading: isLoading,
                                            onPressed: isLoading
                                                ? null
                                                : _submitLogin,
                                          ),
                                          const SizedBox(height: 18),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Text(
                                                "Don't have an account?",
                                              ),
                                              InkWell(
                                                onTap: isLoading
                                                    ? null
                                                    : () => context.go(
                                                        AppRoute.register,
                                                      ),
                                                child: Text(
                                                  " Register",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    color: AppColors.primary,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2B2B2B),
            ),
          ),
        ],
      ),
    );
  }
}

class _SecureSignInNote extends StatelessWidget {
  const _SecureSignInNote();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.verified_user_outlined,
          size: 16,
          color: Colors.green.shade700,
        ),
        const SizedBox(width: 7),
        Text(
          'Secure sign in for your account',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}

class _LoginErrorBanner extends StatelessWidget {
  final String message;

  const _LoginErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    final text = message.replaceFirst('Exception: ', '');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, size: 18, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
