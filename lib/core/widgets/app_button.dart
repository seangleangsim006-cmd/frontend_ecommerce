import 'package:flutter/material.dart';
import 'package:widget_flutter/core/constants/app_colors.dart';

class AppButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Future<void>? Function()? onPressed;
  final bool? isLoading;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final loading = isLoading ?? false;

    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: AppColors.primary,
      ),
      onPressed: loading || onPressed == null ? null : () async => onPressed!(),
      icon: loading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : (icon != null ? Icon(icon, size: 20, color: Colors.white) : const SizedBox.shrink()),
      label: Text(
        loading ? 'Please wait...' : text,
        style: const TextStyle(fontSize: 15, color: Colors.white),
      ),
    );
  }
}
