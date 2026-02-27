import 'package:flutter/material.dart';
import '../../theme/app_spacing.dart';

/// Secondary outlined button with loading state and optional icon.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isExpanded = false,
    this.foregroundColor,
    this.borderColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isExpanded;
  final Color? foregroundColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final button = OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: (foregroundColor != null || borderColor != null)
          ? OutlinedButton.styleFrom(
              foregroundColor: foregroundColor,
              side: borderColor != null
                  ? BorderSide(color: borderColor!, width: 1.5)
                  : null,
            )
          : null,
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
