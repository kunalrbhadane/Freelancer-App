import 'package:flutter/material.dart';
import 'package:freelance_app/app/core/utils/app_colors.dart'; // Import your colors

enum ButtonType { primary, secondary, text }

class CustomButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final IconData? icon;
  final ButtonType buttonType;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.icon,
    this.buttonType = ButtonType.primary,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return switch (buttonType) {
      ButtonType.primary => _buildPrimaryButton(context),
      ButtonType.secondary => _buildSecondaryButton(context),
      ButtonType.text => _buildTextButton(context),
    };
  }
  
  Widget _buildPrimaryButton(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      // The style is automatically taken from ElevatedButtonTheme in app_theme.dart
      child: isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
            )
          : Text(text),
    );
  }

  Widget _buildSecondaryButton(BuildContext context) {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
      child: isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3),
            )
          : Text(text),
    );
  }
  
  Widget _buildTextButton(BuildContext context) {
    return TextButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 3),
            )
          : Text(text),
    );
  }
}