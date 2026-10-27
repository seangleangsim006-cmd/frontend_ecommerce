import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:widget_flutter/core/constants/app_colors.dart';
import 'package:widget_flutter/core/widgets/app_button.dart';
import 'package:widget_flutter/core/widgets/app_text_field.dart';
import 'package:widget_flutter/providers/auth_provider.dart';
import 'package:widget_flutter/routes/app_route.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({
    required this.email,
    required this.token,
    super.key,
  });

  final String email;
  final String token;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _reset = false;

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.email;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (widget.token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reset token is missing or invalid')),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.resetPassword(
      email: _emailController.text.trim(),
      token: widget.token,
      password: _passwordController.text,
      passwordConfirmation: _confirmationController.text,
    );
    if (!mounted) return;

    if (success) {
      setState(() => _reset = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_cleanMessage(authProvider.message))),
      );
    }
  }

  String _cleanMessage(String? message) {
    if (message == null || message.isEmpty) return 'Password reset failed';
    return message.startsWith('Exception: ')
        ? message.substring('Exception: '.length)
        : message;
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
                  child: _reset ? _buildSuccess() : _buildForm(isLoading),
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
          'Create a new password',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose a strong password for your account.',
          style: TextStyle(color: AppColors.neutral, height: 1.4),
        ),
        const SizedBox(height: 24),
        const Text('Email address'),
        const SizedBox(height: 10),
        AppTextField(
          hintText: 'Enter your email address',
          icon: Icons.email_outlined,
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          validator: (value) {
            final email = value?.trim() ?? '';
            if (email.isEmpty) return 'Please enter your email address';
            if (!email.contains('@')) return 'Please enter a valid email';
            return null;
          },
        ),
        const SizedBox(height: 18),
        const Text('New password'),
        const SizedBox(height: 10),
        AppTextField(
          hintText: 'Enter your new password',
          icon: Icons.lock_outline,
          controller: _passwordController,
          isPassword: true,
          textInputAction: TextInputAction.next,
          validator: (value) => value == null || value.length < 8
              ? 'Password should be at least 8 characters'
              : null,
        ),
        const SizedBox(height: 18),
        const Text('Confirm password'),
        const SizedBox(height: 10),
        AppTextField(
          hintText: 'Confirm your new password',
          icon: Icons.lock_reset_outlined,
          controller: _confirmationController,
          isPassword: true,
          textInputAction: TextInputAction.done,
          validator: (value) => value != _passwordController.text
              ? 'Passwords do not match'
              : null,
        ),
        const SizedBox(height: 24),
        AppButton(
          text: 'Reset password',
          icon: Icons.lock_reset_outlined,
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
          Icons.check_circle_outline,
          size: 58,
          color: AppColors.primary,
        ),
        const SizedBox(height: 18),
        const Text(
          'Password reset successfully',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          context.read<AuthProvider>().message ??
              'You can now log in with your new password.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.neutral, height: 1.4),
        ),
        const SizedBox(height: 24),
        AppButton(
          text: 'Go to login',
          onPressed: () async => context.go(AppRoute.login),
        ),
      ],
    );
  }

  Widget _buildLogo() {
    return Center(child: Image.asset('assets/logo/my_logo.png', width: 92));
  }
}
