import 'package:flutter/material.dart';

/// Design token colors extracted from the Umrah Ease design screens.
///
/// Palette overview:
///   - Background  : Very dark warm black  #1A1812
///   - Surface      : Dark card surfaces    #252320
///   - Primary      : Rich gold accent      #C9A84C
///   - Text Primary : White                 #FFFFFF
///   - Text Second  : Warm gray             #9E9C94
///   - Error/SOS    : Emergency red         #E53935
///   - Success      : Completion green      #4CAF50
class AppColors {
  AppColors._();

  // ── Backgrounds ─────────────────────────────────────────────────────────────
  static const Color backgroundDark = Color(0xFF1A1812);
  static const Color surface = Color(0xFF252320);
  static const Color surfaceVariant = Color(0xFF302E28);
  static const Color surfaceElevated = Color(0xFF2A2822);

  // ── Primary Gold ────────────────────────────────────────────────────────────
  static const Color primaryGold = Color(0xFFC9A84C);
  static const Color primaryGoldLight = Color(0xFFD4B55C);
  static const Color primaryGoldDark = Color(0xFFA88930);
  static const Color primaryGoldMuted = Color(0xFF7A6320);

  // ── Text ────────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9E9C94);
  static const Color textMuted = Color(0xFF6E6A62);
  static const Color textOnGold = Color(0xFF1A1812);

  // ── Status ──────────────────────────────────────────────────────────────────
  static const Color error = Color(0xFFE53935);
  static const Color errorDark = Color(0xFFB71C1C);
  static const Color success = Color(0xFF4CAF50);
  static const Color successDark = Color(0xFF388E3C);
  static const Color warning = Color(0xFFFFA726);

  // ── UI Elements ─────────────────────────────────────────────────────────────
  static const Color divider = Color(0xFF3A3830);
  static const Color cardBorder = Color(0xFF3A3830);
  static const Color iconDefault = Color(0xFF9E9C94);
  static const Color iconActive = Color(0xFFC9A84C);
  static const Color shimmerBase = Color(0xFF252320);
  static const Color shimmerHighlight = Color(0xFF302E28);

  // ── Navigation Bar ──────────────────────────────────────────────────────────
  static const Color navBackground = Color(0xFF1A1812);
  static const Color navActive = Color(0xFFC9A84C);
  static const Color navInactive = Color(0xFF6E6A62);

  // ── Map / Special Screens ───────────────────────────────────────────────────
  static const Color mapBackground = Color(0xFF1E1E2A);
  static const Color sosButton = Color(0xFFE53935);
  static const Color sosButtonDark = Color(0xFFB71C1C);

  // ── Gradients ───────────────────────────────────────────────────────────────
  static const LinearGradient goldGradient = LinearGradient(
    colors: [primaryGoldLight, primaryGold, primaryGoldDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkOverlayGradient = LinearGradient(
    colors: [Colors.transparent, Color(0xCC1A1812)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient welcomeGradient = LinearGradient(
    colors: [Color(0x001A1812), Color(0xE61A1812)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.3, 1.0],
  );
}
