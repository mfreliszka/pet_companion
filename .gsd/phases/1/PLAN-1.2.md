---
phase: 1
plan: 2
wave: 2
depends_on: [1.1]
files_modified:
  - mobile/lib/core/theme/app_colors.dart
  - mobile/lib/core/theme/app_typography.dart
  - mobile/lib/core/theme/app_spacing.dart
  - mobile/lib/core/theme/app_theme.dart
  - mobile/lib/core/widgets/buttons/primary_button.dart
  - mobile/lib/core/widgets/buttons/secondary_button.dart
  - mobile/lib/core/widgets/buttons/icon_button.dart
  - mobile/lib/core/widgets/cards/info_card.dart
  - mobile/lib/core/widgets/cards/list_tile_card.dart
  - mobile/lib/core/widgets/inputs/app_text_field.dart
  - mobile/lib/core/widgets/inputs/app_dropdown.dart
  - mobile/lib/core/widgets/dialogs/confirm_dialog.dart
  - mobile/lib/core/widgets/dialogs/bottom_sheet.dart
  - mobile/lib/core/widgets/loading/loading_spinner.dart
  - mobile/lib/core/widgets/loading/shimmer_loading.dart
  - mobile/lib/core/widgets/layout/app_drawer.dart
  - mobile/lib/core/widgets/layout/app_scaffold.dart
  - mobile/lib/core/widgets/layout/section_header.dart
  - mobile/lib/core/widgets/media/user_avatar.dart
autonomous: true

must_haves:
  truths:
    - "AppTheme provides both light and dark ThemeData with dark as default"
    - "All color, typography, and spacing tokens are centralized — no hardcoded values in widgets"
    - "Reusable widget components exist in core/widgets/ organized by category"
    - "App drawer widget is ready for navigation integration"
    - "Components render correctly in both light and dark mode"
  artifacts:
    - "mobile/lib/core/theme/app_theme.dart with light() and dark() static methods"
    - "mobile/lib/core/widgets/layout/app_drawer.dart"
    - "At least 12 reusable widget components across 6 categories"
---

# Plan 1.2: Design System + Reusable Component Library

<objective>
Build the complete custom design system (colors, typography, spacing, themes) and a reusable UI component library organized by category.

Purpose: Every screen in the app will use these components. Building them first ensures visual consistency and faster feature development in Phases 2-5.
Output: Light + Dark theme (dark default), color palette, typography scale, spacing system, 15+ reusable widgets.
</objective>

<context>
Load for context:
- .gsd/SPEC.md (tech stack)
- .gsd/ARCHITECTURE.md (folder structure for core/theme/ and core/widgets/)
- .gsd/DECISIONS.md (ADR-09: full custom design system, ADR-10: dark mode default, ADR-11: drawer nav)
- mobile/pubspec.yaml (to confirm google_fonts dependency)
</context>

<tasks>

<task type="auto">
  <name>Create design tokens: colors, typography, spacing, and theme</name>
  <files>
    mobile/lib/core/theme/app_colors.dart
    mobile/lib/core/theme/app_typography.dart
    mobile/lib/core/theme/app_spacing.dart
    mobile/lib/core/theme/app_theme.dart
  </files>
  <action>
    1. Create app_colors.dart:
       - Define a pet-themed color palette. Use warm, friendly tones:
         - Primary: Teal/Turquoise (#26A69A range) — trust, health, calm
         - Secondary: Warm amber/orange (#FFB74D range) — energy, warmth, pets
         - Error: Soft coral red
         - Surface/Background colors for both light and dark
       - Use a sealed class or static const class pattern, NOT Material extension
       - Dark mode palette: deep navy/charcoal backgrounds, slightly muted primary/secondary
       - Light mode palette: clean whites/light grays with vibrant primary/secondary
       - Include semantic colors: success, warning, error, info
       - Include pet mood colors: happy (green), sad (blue), anxious (amber), energetic (orange), calm (teal)

    2. Create app_typography.dart:
       - Use Google Fonts: 'Nunito' for headings (friendly, rounded), 'Inter' for body (clean, readable)
       - Define full type scale: displayLarge → labelSmall
       - All TextStyles reference AppColors for color
       - Include helper methods for different weights

    3. Create app_spacing.dart:
       - Define spacing scale: xs(4), sm(8), md(12), lg(16), xl(24), xxl(32), xxxl(48)
       - Define border radius scale: sm(8), md(12), lg(16), xl(24), pill(999)
       - Include EdgeInsets helpers: paddingAll, paddingHorizontal, paddingVertical
       - Include SizedBox gap helpers: verticalGap, horizontalGap

    4. Create app_theme.dart:
       - AppTheme class with static methods: light() and dark()
       - Dark mode is the default (used in main.dart)
       - Both ThemeData objects configured with:
         - ColorScheme from AppColors
         - TextTheme from AppTypography
         - AppBarTheme (transparent/surface, no elevation)
         - DrawerTheme
         - CardTheme (rounded, elevation, surface color)
         - ElevatedButtonTheme, OutlinedButtonTheme, TextButtonTheme
         - InputDecorationTheme (rounded, outlined)
         - BottomSheetTheme
         - DialogTheme
       - Use ThemeExtension for custom properties (AppColors accessible via Theme.of(context))

    AVOID: Don't use hardcoded hex colors anywhere outside app_colors.dart.
    AVOID: Don't use default Material colors (Colors.blue, etc.) — use the custom palette.
    NOTE: Use Nunito from Google Fonts — add google_fonts package to pubspec if not already there.
  </action>
  <verify>
    Files exist at the specified paths.
    app_theme.dart compiles without errors.
    Both light() and dark() return valid ThemeData.
    `cd mobile && flutter analyze` shows no errors in theme files.
  </verify>
  <done>
    Complete design token system: colors (light+dark), typography (Nunito+Inter), spacing, and ThemeData.
    Dark mode is default. All tokens centralized.
  </done>
</task>

<task type="auto">
  <name>Create reusable widget component library</name>
  <files>
    mobile/lib/core/widgets/buttons/primary_button.dart
    mobile/lib/core/widgets/buttons/secondary_button.dart
    mobile/lib/core/widgets/buttons/app_icon_button.dart
    mobile/lib/core/widgets/cards/info_card.dart
    mobile/lib/core/widgets/cards/list_tile_card.dart
    mobile/lib/core/widgets/inputs/app_text_field.dart
    mobile/lib/core/widgets/inputs/app_dropdown.dart
    mobile/lib/core/widgets/dialogs/confirm_dialog.dart
    mobile/lib/core/widgets/dialogs/app_bottom_sheet.dart
    mobile/lib/core/widgets/loading/loading_spinner.dart
    mobile/lib/core/widgets/loading/shimmer_loading.dart
    mobile/lib/core/widgets/layout/app_drawer.dart
    mobile/lib/core/widgets/layout/app_scaffold.dart
    mobile/lib/core/widgets/layout/section_header.dart
    mobile/lib/core/widgets/media/user_avatar.dart
  </files>
  <action>
    Create reusable widget components using ONLY the design tokens from Task 1.
    Every widget must use AppColors, AppTypography, AppSpacing — NO hardcoded values.

    **Buttons:**
    - PrimaryButton: filled, rounded, with loading state, optional icon
    - SecondaryButton: outlined variant, same API as PrimaryButton
    - AppIconButton: circular icon button with tooltip

    **Cards:**
    - InfoCard: rounded card with title, subtitle, optional icon and trailing widget
    - ListTileCard: card-wrapped list tile for settings/menus

    **Inputs:**
    - AppTextField: styled text field with label, hint, error state, optional prefix/suffix
    - AppDropdown: styled dropdown with same visual treatment as AppTextField

    **Dialogs:**
    - ConfirmDialog: title, message, confirm/cancel buttons — static show() method
    - AppBottomSheet: styled bottom sheet container — static show() method

    **Loading:**
    - LoadingSpinner: centered circular progress with optional message
    - ShimmerLoading: shimmer placeholder for loading states

    **Layout:**
    - AppDrawer: navigation drawer with:
      - User avatar + name + email at top (from auth state)
      - Navigation items: Home, My Pets, Family, Journal, Health, Schedule, Expenses, Contacts, Reports
      - Divider before Settings/Profile/Sign Out
      - Uses ListTile with icons for each item
      - Highlights current route
    - AppScaffold: wrapper that provides AppBar + Drawer + body with consistent styling
    - SectionHeader: bold section title with optional action button

    **Media:**
    - UserAvatar: circular avatar with fallback to initials, supports network image + cached

    AVOID: Don't import Material colors directly — use AppColors.
    AVOID: Don't hardcode any sizes — use AppSpacing.
    AVOID: Don't create stateful widgets unless truly necessary (prefer StatelessWidget).
  </action>
  <verify>
    All 15 widget files exist.
    `cd mobile && flutter analyze` shows no errors in widget files.
    All widgets reference AppColors/AppTypography/AppSpacing, not hardcoded values.
  </verify>
  <done>
    15 reusable widgets across 6 categories (buttons, cards, inputs, dialogs, loading, layout/media).
    All widgets use design tokens. AppDrawer ready for navigation integration.
  </done>
</task>

</tasks>

<verification>
After all tasks, verify:
- [ ] `cd mobile && flutter analyze` — no errors in core/theme/ and core/widgets/
- [ ] AppTheme.dark() and AppTheme.light() return valid ThemeData
- [ ] AppDrawer lists all navigation destinations
- [ ] No hardcoded colors, sizes, or font styles in any widget
- [ ] All 15+ widget files exist in organized subdirectories
</verification>

<success_criteria>
- [ ] All tasks verified
- [ ] Must-haves confirmed
- [ ] Design system is complete and ready for screen development
</success_criteria>
