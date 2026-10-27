import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:widget_flutter/core/constants/app_colors.dart';
import 'package:widget_flutter/core/widgets/app_button.dart';
import 'package:widget_flutter/core/widgets/app_text_field.dart';
import 'package:widget_flutter/providers/auth_provider.dart';
import 'package:widget_flutter/routes/app_route.dart';
import 'package:widget_flutter/screens/auth/register_screen.dart';

class VerifyOtpScreen extends StatefulWidget {
  const VerifyOtpScreen({required this.phone, this.draft, super.key});

  final String phone;
  final RegistrationDraft? draft;

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
     context.go(AppRoute.register, extra: widget.draft);
    // if (!_formKey.currentState!.validate()) return;
    // final authProvider = context.read<AuthProvider>();
    // final verified = await authProvider.verifyOtp(
    //   phone: widget.phone,
    //   otp: _otpController.text.trim(),
    //   saveToken: widget.draft == null,
    // );
    // if (!mounted) return;
    // if (verified) {
    //   if (widget.draft != null) {
    //     context.go(AppRoute.register, extra: widget.draft);
    //   } else {
    //     ScaffoldMessenger.of(
    //       context,
    //     ).showSnackBar(const SnackBar(content: Text('Phone number verified')));
    //     context.go(AppRoute.mianNav);
    //   }
    // } else {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Verification failed: ${authProvider.message}')),
    //   );
    // }
  }

  Future<void> _resend() async {
    final authProvider = context.read<AuthProvider>();
    final sent = await authProvider.sendOtp(phone: widget.phone);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          sent
              ? 'A new OTP was sent'
              : 'Could not resend OTP: ${authProvider.message}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().loading ?? false;
    final width = MediaQuery.sizeOf(context).width;

    return SafeArea(
      child: Scaffold(
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Image.asset(
                          'assets/logo/my_logo.png',
                          width: 92,
                        ),
                      ),
                      const SizedBox(height: 28),
                      const Text(
                        'Verify your phone',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter the 6-digit code sent to ${widget.phone}.',
                        style: TextStyle(color: AppColors.neutral, height: 1.4),
                      ),
                      const SizedBox(height: 26),
                      const Text('Verification code'),
                      const SizedBox(height: 10),
                      AppTextField(
                        hintText: 'Enter OTP',
                        icon: Icons.lock_clock_outlined,
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        validator: (value) => value == null || value.length != 6
                            ? 'Please enter the 6-digit OTP'
                            : null,
                      ),
                      const SizedBox(height: 24),
                      AppButton(
                        text: 'Verify phone number',
                        isLoading: isLoading,
                        onPressed: isLoading ? null : _verify,
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: TextButton(
                          onPressed: isLoading ? null : _resend,
                          child: const Text('Resend OTP'),
                        ),
                      ),
                      Center(
                        child: TextButton(
                          onPressed: isLoading
                              ? null
                              : () => context.go(AppRoute.register),
                          child: const Text('Use a different phone number'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
