import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

/// Navigation drawer with user header and route items.
class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    this.userName,
    this.userEmail,
    this.userPhotoUrl,
    required this.currentRoute,
    required this.onNavigate,
    this.onSignOut,
  });

  final String? userName;
  final String? userEmail;
  final String? userPhotoUrl;
  final String currentRoute;
  final void Function(String route) onNavigate;
  final VoidCallback? onSignOut;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // ── User Header ──
            Container(
              width: double.infinity,
              padding: AppSpacing.paddingAllXl,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: theme.dividerTheme.color ?? AppColors.darkDivider,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: AppSpacing.avatarLg / 2,
                    backgroundColor: theme.colorScheme.primary.withValues(
                      alpha: 0.15,
                    ),
                    backgroundImage: userPhotoUrl != null
                        ? NetworkImage(userPhotoUrl!)
                        : null,
                    child: userPhotoUrl == null
                        ? Text(
                            _getInitials(userName ?? '?'),
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          )
                        : null,
                  ),
                  AppSpacing.verticalGapMd,
                  Text(
                    userName ?? 'Pet Companion',
                    style: theme.textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (userEmail != null)
                    Text(
                      userEmail!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),

            // ── Navigation Items ──
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                children: [
                  _buildNavItem(
                    context,
                    icon: Icons.home_rounded,
                    label: 'Home',
                    route: '/',
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.pets_rounded,
                    label: 'My Pets',
                    route: '/pets',
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.family_restroom_rounded,
                    label: 'Family',
                    route: '/family',
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.book_rounded,
                    label: 'Journal',
                    route: '/journal',
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.favorite_rounded,
                    label: 'Health',
                    route: '/health',
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.calendar_month_rounded,
                    label: 'Schedule',
                    route: '/schedule',
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.receipt_long_rounded,
                    label: 'Expenses',
                    route: '/expenses',
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.contacts_rounded,
                    label: 'Contacts',
                    route: '/contacts',
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.description_rounded,
                    label: 'Reports',
                    route: '/reports',
                  ),
                  const Divider(),
                  _buildNavItem(
                    context,
                    icon: Icons.person_rounded,
                    label: 'Profile',
                    route: '/profile',
                  ),
                  if (onSignOut != null)
                    _buildNavItem(
                      context,
                      icon: Icons.logout_rounded,
                      label: 'Sign Out',
                      route: '__sign_out__',
                      iconColor: AppColors.error,
                      textColor: AppColors.error,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String route,
    Color? iconColor,
    Color? textColor,
  }) {
    final theme = Theme.of(context);
    final isSelected = currentRoute == route;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 1,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected
              ? theme.colorScheme.primary
              : iconColor ?? theme.colorScheme.onSurfaceVariant,
          size: AppSpacing.iconLg,
        ),
        title: Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            color: isSelected
                ? theme.colorScheme.primary
                : textColor ?? theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
        selected: isSelected,
        selectedTileColor: theme.colorScheme.primary.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusMd),
        onTap: () {
          Navigator.pop(context); // Close drawer
          if (route == '__sign_out__') {
            onSignOut?.call();
          } else {
            onNavigate(route);
          }
        },
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}
