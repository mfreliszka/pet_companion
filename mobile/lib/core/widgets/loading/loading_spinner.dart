import 'package:flutter/material.dart';
import '../../theme/app_spacing.dart';

/// Centered loading spinner with optional message.
class LoadingSpinner extends StatelessWidget {
  const LoadingSpinner({
    super.key,
    this.message,
    this.size = AppSpacing.avatarMd,
  });

  final String? message;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: theme.colorScheme.primary,
            ),
          ),
          if (message != null) ...[
            AppSpacing.verticalGapLg,
            Text(
              message!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
