import 'package:flutter/material.dart';
import '../../theme/app_spacing.dart';

/// Circular icon button with tooltip.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.size = AppSpacing.iconXl,
    this.color,
    this.backgroundColor,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final double size;
  final Color? color;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: size * 0.6),
      tooltip: tooltip,
      color: color ?? theme.colorScheme.onSurface,
      style: backgroundColor != null
          ? IconButton.styleFrom(backgroundColor: backgroundColor)
          : null,
      constraints: BoxConstraints(minWidth: size, minHeight: size),
    );
  }
}
