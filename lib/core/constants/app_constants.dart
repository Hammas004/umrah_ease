/// App-wide constants for Umrah Ease.
class AppConstants {
  AppConstants._();

  // ── App Info ─────────────────────────────────────────────────────────────
  static const String appName = 'Umrah Ease';
  static const String appTagline = 'Your Guide for Sacred Journeys';

  // ── Spacing ───────────────────────────────────────────────────────────────
  static const double spaceXS = 4.0;
  static const double spaceSM = 8.0;
  static const double spaceMD = 16.0;
  static const double spaceLG = 24.0;
  static const double spaceXL = 32.0;
  static const double spaceXXL = 48.0;

  // ── Border Radius ─────────────────────────────────────────────────────────
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusFull = 999.0;

  // ── Icon Sizes ────────────────────────────────────────────────────────────
  static const double iconSM = 16.0;
  static const double iconMD = 24.0;
  static const double iconLG = 32.0;
  static const double iconXL = 48.0;

  // ── Animation Durations ──────────────────────────────────────────────────
  static const Duration animFast = Duration(milliseconds: 150);
  static const Duration animNormal = Duration(milliseconds: 300);
  static const Duration animSlow = Duration(milliseconds: 500);

  // ── Local DB ─────────────────────────────────────────────────────────────
  static const String dbName = 'umrah_ease.db';
  static const int dbVersion = 4;

  // ── Shared Prefs Keys ────────────────────────────────────────────────────
  static const String prefKeyOnboardingDone = 'onboarding_done';
  static const String prefKeyProfileComplete = 'profile_complete';
  static const String prefKeyThemeMode = 'theme_mode';
  static const String prefKeyLanguage = 'language_code';
  static const String prefKeyUserId = 'user_id';

  // ── Firestore Collections ────────────────────────────────────────────────
  static const String colUsers = 'users';
  static const String colJourneys = 'journeys';
  static const String colPermits = 'permits';
  static const String colHotels = 'hotels';
  static const String colTransport = 'transport';
  static const String colRituals = 'rituals';
  static const String colUmrahGuides = 'umrah_guides';

  // ── Ritual Names ─────────────────────────────────────────────────────────
  static const String ritualNiyyah = 'Niyyah';
  static const String ritualIhram = 'Ihram';
  static const String ritualTawaf = 'Tawaf';
  static const String ritualSai = "Sa'i";
  static const String ritualMina = 'Mina & Arafat';

  // ── Bottom Nav Indices ───────────────────────────────────────────────────
  static const int navHome = 0;
  static const int navPermits = 1;
  static const int navServices = 2;
  static const int navProfile = 3;
}
