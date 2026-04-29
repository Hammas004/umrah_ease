import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// All text styles used across Umrah Ease, derived from the design screens.
///
/// Scale (Nunito):
///   displayLarge   32 / ExtraBold  — Welcome hero headline
///   displayMedium  28 / Bold       — Section hero headline
///   headlineLarge  24 / Bold       — Screen titles
///   headlineMedium 20 / SemiBold   — Card section titles
///   titleLarge     18 / SemiBold   — AppBar titles
///   titleMedium    16 / SemiBold   — List item titles
///   titleSmall     14 / SemiBold   — Sub-section labels
///   bodyLarge      16 / Regular    — Paragraph body
///   bodyMedium     14 / Regular    — Card body, descriptions
///   bodySmall      12 / Regular    — Captions, hints
///   labelLarge     14 / SemiBold   — Button text, tags
///   labelMedium    12 / SemiBold   — Nav labels, chips
///   labelSmall     10 / SemiBold   — Badges, tiny labels
class AppTextStyles {
  AppTextStyles._();

  // ── Display ─────────────────────────────────────────────────────────────────
  static TextStyle get displayLarge => GoogleFonts.nunito(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
        height: 1.2,
      );

  static TextStyle get displayMedium => GoogleFonts.nunito(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.25,
      );

  // ── Headline ────────────────────────────────────────────────────────────────
  static TextStyle get headlineLarge => GoogleFonts.nunito(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.3,
      );

  static TextStyle get headlineMedium => GoogleFonts.nunito(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.35,
      );

  // ── Title ───────────────────────────────────────────────────────────────────
  static TextStyle get titleLarge => GoogleFonts.nunito(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.4,
      );

  static TextStyle get titleMedium => GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.4,
      );

  static TextStyle get titleSmall => GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.4,
      );

  // ── Body ────────────────────────────────────────────────────────────────────
  static TextStyle get bodyLarge => GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.5,
      );

  static TextStyle get bodySmall => GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textMuted,
        height: 1.4,
      );

  // ── Label ───────────────────────────────────────────────────────────────────
  static TextStyle get labelLarge => GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: 0.6,
      );

  static TextStyle get labelMedium => GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 0.4,
      );

  static TextStyle get labelSmall => GoogleFonts.nunito(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: AppColors.textMuted,
        letterSpacing: 0.4,
      );

  // ── Specialised ─────────────────────────────────────────────────────────────

  /// Large countdown digits — Dashboard "14 Days, 08 Hours, 30 Mins"
  static TextStyle get countdownLarge => GoogleFonts.nunito(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        color: AppColors.primaryGold,
        height: 1.1,
        letterSpacing: -0.5,
      );

  /// Medium countdown digits for secondary use
  static TextStyle get countdownMedium => GoogleFonts.nunito(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.primaryGold,
        height: 1.2,
      );

  /// Gold-coloured label (tags, active nav, progress labels)
  static TextStyle get goldLabel => GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryGold,
        letterSpacing: 0.5,
      );

  /// Button text — used inside ElevatedButton & OutlinedButton
  static TextStyle get buttonText => GoogleFonts.nunito(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.0,
      );

  /// Arabic du'a / verse text — Live Ritual Guide screen
  static TextStyle get arabicText => const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 2.0,
        fontFamily: 'Scheherazade New',
      );

  /// Transliteration text beneath Arabic
  static TextStyle get transliterationText => GoogleFonts.nunito(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        fontStyle: FontStyle.italic,
        height: 1.6,
      );

  /// Permit / detail labels — Digital Permit Wallet
  static TextStyle get permitLabel => GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textMuted,
        letterSpacing: 0.3,
      );

  static TextStyle get permitValue => GoogleFonts.nunito(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  /// Price text — Hotel & Transport listings
  static TextStyle get priceText => GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.primaryGold,
      );
}
