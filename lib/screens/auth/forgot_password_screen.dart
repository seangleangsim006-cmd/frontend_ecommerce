import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:widget_flutter/core/constants/app_colors.dart';
import 'package:widget_flutter/core/widgets/app_button.dart';
import 'package:widget_flutter/core/widgets/app_text_field.dart';
import 'package:widget_flutter/providers/auth_provider.dart';
import 'package:widget_flutter/routes/app_route.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _submitted = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final sent = await authProvider.forgotPassword(
      email: _emailController.text.trim(),
    );
    if (!mounted) return;

    if (sent) {
      setState(() => _submitted = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.message ?? 'Request failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().loading ?? false;
    final width = MediaQuery.sizeOf(context).width;

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFFDF8F5),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 28),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.sizeOf(context).height - 56,
            ),
            child: Center(
              child: Container(
                width: width > 600 ? 500 : width * 0.9,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: _submitted ? _buildSuccess() : _buildForm(isLoading),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLogo(),
        const SizedBox(height: 28),
        const Text(
          'Forgot password?',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter your email and we will send you a link to reset your password.',
          style: TextStyle(color: AppColors.neutral, height: 1.4),
        ),
        const SizedBox(height: 26),
        const Text('Email address'),
        const SizedBox(height: 10),
        AppTextField(
          hintText: 'Enter your email address',
          icon: Icons.email_outlined,
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          validator: (value) {
            final email = value?.trim() ?? '';
            if (email.isEmpty) return 'Please enter your email address';
            if (!email.contains('@')) return 'Please enter a valid email';
            return null;
          },
        ),
        const SizedBox(height: 24),
        AppButton(
          text: 'Send reset link',
          icon: Icons.mail_outline,
          isLoading: isLoading,
          onPressed: isLoading ? null : _submit,
        ),
        const SizedBox(height: 8),
        Center(
          child: TextButton(
            onPressed: isLoading ? null : () => context.go(AppRoute.login),
            child: const Text('Back to login'),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccess() {
    return Column(
      children: [
        _buildLogo(),
        const SizedBox(height: 28),
        const Icon(
          Icons.mark_email_read_outlined,
          size: 58,
          color: AppColors.primary,
        ),
        const SizedBox(height: 18),
        const Text(
          'Check your email',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          context.read<AuthProvider>().message ??
              'If an account exists for this email, a password reset link has been sent.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.neutral, height: 1.4),
        ),
        const SizedBox(height: 24),
        AppButton(
          text: 'Back to login',
          onPressed: () async => context.go(AppRoute.login),
        ),
      ],
    );
  }

  Widget _buildLogo() {
    return Center(child: Image.asset('assets/logo/my_logo.png', width: 92));
  }
}
