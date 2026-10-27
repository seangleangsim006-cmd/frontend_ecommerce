import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:widget_flutter/core/constants/app_colors.dart';
import 'package:widget_flutter/core/widgets/app_button.dart';
import 'package:widget_flutter/core/widgets/app_text_field.dart';
import 'package:widget_flutter/providers/auth_provider.dart';
import 'package:widget_flutter/routes/app_route.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, this.draft});

  final RegistrationDraft? draft;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();

  bool _usePhone = false;
  bool _showProfileStep = false;
  bool _phoneVerified = false;
  String? _profileImagePath;

  @override
  void initState() {
    super.initState();
    final draft = widget.draft;
    if (draft != null) {
      _nameController.text = draft.name;
      _phoneController.text = draft.phone;
      _passwordController.text = draft.password;
      _usePhone = true;
      _phoneVerified = true;
      _showProfileStep = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image != null && mounted) {
      setState(() => _profileImagePath = image.path);
    }
  }

  Future<void> _continueToProfile() async {
    if (!_formKey.currentState!.validate()) return;

    if (_usePhone) {
      final authProvider = context.read<AuthProvider>();
      final phone = _phoneController.text.trim();
      final sent = await authProvider.sendOtp(phone: phone);
      if (!mounted) return;
      if (sent) {
        context.go(
          AppRoute.verifyOtp,
          extra: RegistrationDraft(
            name: _nameController.text.trim(),
            phone: phone,
            password: _passwordController.text.trim(),
          ),
        );
      } else {
        context.go(
          AppRoute.verifyOtp,
          extra: RegistrationDraft(
            name: _nameController.text.trim(),
            phone: phone,
            password: _passwordController.text.trim(),
          ),
        );
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text('Could not send OTP: ${authProvider.message}'),
        //   ),
        // );
      }
      return;
    }

    setState(() => _showProfileStep = true);
  }

  Future<void> _register() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.register(
      name: _nameController.text.trim(),
      email: _usePhone ? null : _emailController.text.trim(),
      phone: _usePhone ? _phoneController.text.trim() : null,
      password: _passwordController.text.trim(),
      profileImagePath: _profileImagePath,
      saveToken: !_usePhone || _phoneVerified,
    );

    if (!mounted) return;
    if (authProvider.user != null) {
      if (_usePhone && !_phoneVerified) {
        final sent = await authProvider.sendOtp(
          phone: _phoneController.text.trim(),
        );
        if (!mounted) return;
        if (sent) {
          context.go(AppRoute.verifyOtp, extra: _phoneController.text.trim());
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not send OTP: ${authProvider.message}'),
            ),
          );
        }
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Register successfully')));
      context.go(AppRoute.mianNav);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Register failed: ${authProvider.message}')),
      );
    }
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
                      const SizedBox(height: 22),
                      // Row(
                      //   children: [
                      //     _StepIndicator(number: 1, active: !_showProfileStep),
                      //     Expanded(child: Divider(color: Colors.grey.shade300)),
                      //     _StepIndicator(number: 2, active: _showProfileStep),
                      //   ],
                      // ),
                      const SizedBox(height: 22),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: _showProfileStep
                            ? _buildProfileStep(isLoading)
                            : _buildAccountStep(isLoading),
                      ),
                      const SizedBox(height: 18),
                      Center(
                        child: TextButton(
                          onPressed: isLoading
                              ? null
                              : () => context.go(AppRoute.login),
                          child: const Text('Already have an account? Login'),
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

  Widget _buildAccountStep(bool isLoading) {
    return Column(
      key: const ValueKey('account-step'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Create your account',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          'Choose how you want to sign in to your account.',
          style: TextStyle(color: AppColors.neutral),
        ),
        const SizedBox(height: 22),
        Text(
          'Register with',
          style: TextStyle(
            color: Colors.grey.shade800,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment<bool>(
              value: false,
              icon: Icon(Icons.email_outlined),
              label: Text('Email address'),
            ),
            ButtonSegment<bool>(
              value: true,
              icon: Icon(Icons.phone_outlined),
              label: Text('Phone number'),
            ),
          ],
          selected: {_usePhone},
          expandedInsets: EdgeInsets.zero,
          showSelectedIcon: false,
          style: ButtonStyle(
            minimumSize: const WidgetStatePropertyAll(Size.fromHeight(54)),
            padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 12),
            ),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
            ),
            side: WidgetStateProperty.resolveWith((states) {
              return BorderSide(
                color: states.contains(WidgetState.selected)
                    ? AppColors.primary
                    : Colors.grey.shade300,
                width: states.contains(WidgetState.selected) ? 1.4 : 1,
              );
            }),
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              return states.contains(WidgetState.selected)
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : Colors.grey.shade50;
            }),
            foregroundColor: WidgetStateProperty.resolveWith((states) {
              return states.contains(WidgetState.selected)
                  ? AppColors.primary
                  : Colors.grey.shade700;
            }),
            textStyle: const WidgetStatePropertyAll(
              TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
          onSelectionChanged: isLoading
              ? null
              : (selection) => setState(() => _usePhone = selection.first),
        ),
        const SizedBox(height: 8),
        Text(
          _usePhone
              ? 'We will use your phone number to sign you in.'
              : 'We will use your email address to sign you in.',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        const SizedBox(height: 22),
        const Text('Full Name'),
        const SizedBox(height: 10),
        AppTextField(
          hintText: 'Enter your full name',
          icon: Icons.person_outline,
          controller: _nameController,
          textInputAction: TextInputAction.next,
          validator: (value) => value == null || value.trim().isEmpty
              ? 'Please enter your full name'
              : null,
        ),
        const SizedBox(height: 18),
        Text(_usePhone ? 'Phone Number' : 'Email Address'),
        const SizedBox(height: 10),
        AppTextField(
          hintText: _usePhone
              ? 'Enter your phone number'
              : 'Enter your email address',
          icon: _usePhone ? Icons.phone_outlined : Icons.email_outlined,
          controller: _usePhone ? _phoneController : _emailController,
          keyboardType: _usePhone
              ? TextInputType.phone
              : TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your ${_usePhone ? 'phone number' : 'email address'}';
            }
            if (!_usePhone && !value.contains('@')) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
        const SizedBox(height: 18),
        const Text('Password'),
        const SizedBox(height: 10),
        AppTextField(
          hintText: 'Create a password',
          icon: Icons.lock_outline,
          controller: _passwordController,
          isPassword: true,
          textInputAction: TextInputAction.done,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a password';
            }
            if (value.length < 8) {
              return 'Password should be at least 8 characters';
            }
            return null;
          },
        ),
        const SizedBox(height: 26),
        AppButton(
          text: 'Continue to profile',
          isLoading: false,
          onPressed: isLoading ? null : () async => _continueToProfile(),
        ),
      ],
    );
  }

  Widget _buildProfileStep(bool isLoading) {
    return Column(
      key: const ValueKey('profile-step'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: isLoading
                  ? null
                  : () => setState(() => _showProfileStep = false),
              icon: const Icon(Icons.arrow_back),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 10),
            const Text(
              'Add your profile photo',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Add a photo so restaurants can recognize you. This step is optional.',
          style: TextStyle(color: AppColors.neutral, height: 1.4),
        ),
        const SizedBox(height: 28),
        Center(
          child: GestureDetector(
            onTap: isLoading ? null : _pickProfileImage,
            child: Container(
              width: 132,
              height: 132,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.1),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: _profileImagePath == null
                  ? Icon(
                      Icons.add_a_photo_outlined,
                      size: 38,
                      color: AppColors.primary,
                    )
                  : ClipOval(
                      child: Image.file(
                        File(_profileImagePath!),
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Center(
          child: TextButton.icon(
            onPressed: isLoading ? null : _pickProfileImage,
            icon: const Icon(Icons.photo_library_outlined),
            label: Text(
              _profileImagePath == null ? 'Choose photo' : 'Change photo',
            ),
          ),
        ),
        const SizedBox(height: 22),
        AppButton(
          text: 'Create account',
          isLoading: isLoading,
          onPressed: isLoading ? null : _register,
        ),
        const SizedBox(height: 8),
        Center(
          child: TextButton(
            onPressed: isLoading ? null : _register,
            child: const Text('Skip for now'),
          ),
        ),
      ],
    );
  }
}

class RegistrationDraft {
  const RegistrationDraft({
    required this.name,
    required this.phone,
    required this.password,
  });

  final String name;
  final String phone;
  final String password;
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.number, required this.active});

  final int number;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 15,
      backgroundColor: active ? AppColors.primary : Colors.grey.shade200,
      child: Text(
        '$number',
        style: TextStyle(
          color: active ? Colors.white : Colors.grey.shade600,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
