import 'package:flutter/material.dart';
import 'package:widget_flutter/core/constants/app_colors.dart';

class AppTextField extends StatefulWidget {
  final String hintText;
  final IconData? icon;
  final bool? obscureText;
  final bool isPassword;
  final String? Function(String?)? validator;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final Widget? suffix;

  const AppTextField({
    super.key,
    required this.hintText,
    this.icon,
    required this.controller,
    this.obscureText,
    this.isPassword = false,
    this.validator,
    this.onChanged,
    this.keyboardType,
    this.textInputAction,
    this.focusNode,
    this.suffix,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.isPassword || widget.obscureText == true;
  }

  @override
  Widget build(BuildContext context) {
    final shouldHideText = widget.isPassword
        ? _isObscured
        : widget.obscureText ?? false;

    return SizedBox(
      height: 50,
      child: TextFormField(
        controller: widget.controller,
        onChanged: widget.onChanged,
        focusNode: widget.focusNode,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        obscureText: shouldHideText,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(
            fontSize: 13,
            color: AppColors.neutral.withOpacity(0.8),
            fontWeight: FontWeight.w400,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          prefixIcon: widget.icon != null
              ? Padding(
                  padding: const EdgeInsets.only(left: 8, right: 4),
                  child: Icon(widget.icon, size: 20, color: AppColors.primary),
                )
              : null,
          prefixIconConstraints: const BoxConstraints(minWidth: 40),
          suffixIcon: widget.isPassword
              ? IconButton(
                  onPressed: () {
                    setState(() => _isObscured = !_isObscured);
                  },
                  icon: Icon(
                    _isObscured ? Icons.visibility_off : Icons.visibility,
                    size: 20,
                  ),
                  color: AppColors.neutral,
                  splashRadius: 20,
                )
              : widget.suffix,
          filled: true,
          fillColor: AppColors.primary.withOpacity(0.08),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary.withOpacity(0.2)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary.withOpacity(0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
        ),
        validator: widget.validator,
      ),
    );
  }
}
