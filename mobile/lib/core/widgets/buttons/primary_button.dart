import 'package:flutter/material.dart';
import '../../theme/app_spacing.dart';

/// Primary filled button with loading state and optional icon.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isExpanded = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              height: AppSpacing.iconMd,
              width: AppSpacing.iconMd,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : icon != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: AppSpacing.iconMd),
                AppSpacing.horizontalGapSm,
                Text(label),
              ],
            )
          : Text(label),
    );

    return isExpanded
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }
}
