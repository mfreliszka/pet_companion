import 'package:flutter/material.dart';

/// Pet Companion color palette.
///
/// Warm, friendly tones designed for a pet care app.
/// Primary: Teal — trust, health, calm
/// Secondary: Warm amber — energy, warmth, pets
class AppColors {
  AppColors._();

  // ── Primary (Teal) ─────────────────────────────────────
  static const Color primary = Color(0xFF26A69A);
  static const Color primaryLight = Color(0xFF64D8CB);
  static const Color primaryDark = Color(0xFF00796B);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // ── Secondary (Warm Amber) ─────────────────────────────
  static const Color secondary = Color(0xFFFFB74D);
  static const Color secondaryLight = Color(0xFFFFE97D);
  static const Color secondaryDark = Color(0xFFC88719);
  static const Color onSecondary = Color(0xFF1A1A1A);

  // ── Semantic Colors ────────────────────────────────────
  static const Color success = Color(0xFF66BB6A);
  static const Color warning = Color(0xFFFFA726);
  static const Color error = Color(0xFFEF5350);
  static const Color info = Color(0xFF42A5F5);
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color onWarning = Color(0xFF1A1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onInfo = Color(0xFFFFFFFF);

  // ── Pet Mood Colors ────────────────────────────────────
  static const Color moodHappy = Color(0xFF66BB6A);
  static const Color moodSad = Color(0xFF64B5F6);
  static const Color moodAnxious = Color(0xFFFFCA28);
  static const Color moodEnergetic = Color(0xFFFF7043);
  static const Color moodCalm = Color(0xFF26A69A);

  // ── Dark Theme ─────────────────────────────────────────
  static const Color darkBackground = Color(0xFF0F1419);
  static const Color darkSurface = Color(0xFF1A2027);
  static const Color darkSurfaceVariant = Color(0xFF232D36);
  static const Color darkCard = Color(0xFF1E2830);
  static const Color darkDivider = Color(0xFF2C3640);
  static const Color darkOnBackground = Color(0xFFE8ECF0);
  static const Color darkOnSurface = Color(0xFFD4DAE0);
  static const Color darkOnSurfaceVariant = Color(0xFF8B98A5);
  static const Color darkOutline = Color(0xFF3A4550);

  // ── Light Theme ────────────────────────────────────────
  static const Color lightBackground = Color(0xFFF8FAFB);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF0F3F5);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightDivider = Color(0xFFE0E5E8);
  static const Color lightOnBackground = Color(0xFF1A2027);
  static const Color lightOnSurface = Color(0xFF2C3640);
  static const Color lightOnSurfaceVariant = Color(0xFF5A6570);
  static const Color lightOutline = Color(0xFFCCD3D9);
}
