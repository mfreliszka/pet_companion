import 'package:flutter/material.dart';
import '../../theme/app_spacing.dart';

/// Styled bottom sheet container with drag handle.
class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet({super.key, required this.child, this.title});

  final Widget child;
  final String? title;

  /// Shows a styled bottom sheet.
  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    String? title,
    bool isScrollControlled = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      builder: (_) => AppBottomSheet(title: title, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppSpacing.verticalGapSm,
            // Drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.3,
                ),
                borderRadius: AppSpacing.borderRadiusPill,
              ),
            ),
            if (title != null) ...[
              AppSpacing.verticalGapLg,
              Padding(
                padding: AppSpacing.paddingHorizontalLg,
                child: Text(title!, style: theme.textTheme.titleLarge),
              ),
            ],
            AppSpacing.verticalGapMd,
            child,
            AppSpacing.verticalGapLg,
          ],
        ),
      ),
    );
  }
}
