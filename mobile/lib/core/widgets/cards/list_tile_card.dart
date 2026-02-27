import 'package:flutter/material.dart';
import '../../theme/app_spacing.dart';

/// Card-wrapped list tile for settings, menus, and options.
class ListTileCard extends StatelessWidget {
  const ListTileCard({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: ListTile(
        title: Text(title, style: theme.textTheme.titleSmall),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            : null,
        leading: leading,
        trailing:
            trailing ??
            const Icon(Icons.chevron_right, size: AppSpacing.iconLg),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusMd),
      ),
    );
  }
}
