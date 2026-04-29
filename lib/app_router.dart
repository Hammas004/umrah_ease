import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'admin/add_hotel_screen.dart';
import 'admin/admin_dashboard_screen.dart';
import 'admin/admin_login_screen.dart';
import 'admin/view_hotels_screen.dart';
import 'core/constants/app_constants.dart';
import 'data/models/hotel.dart';
import 'features/accommodation/screens/hotel_details_screen.dart';
import 'features/accommodation/screens/select_stay_screen.dart';
import 'features/auth/providers/user_profile_provider.dart';
import 'features/auth/screens/onboarding_screen.dart';
import 'features/auth/screens/profile_setup_screen.dart';
import 'features/auth/screens/sign_in_screen.dart';
import 'features/auth/screens/sign_up_screen.dart';
import 'features/checklist/screens/packing_checklist_screen.dart';
import 'features/education/screens/education_hub_screen.dart';
import 'features/emergency/screens/emergency_screen.dart';
import 'features/family/screens/family_tracker_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/journey/screens/finalize_journey_screen.dart';
import 'features/permits/screens/permit_wallet_screen.dart';
import 'features/profile/screens/profile_screen.dart';
import 'features/rituals/screens/ritual_completion_screen.dart';
import 'features/rituals/screens/ritual_guide_screen.dart';
import 'features/rituals/screens/sai_guide_screen.dart';
import 'features/services/screens/services_screen.dart';
import 'features/shell/shell_screen.dart';
import 'features/transport/screens/select_transport_screen.dart';
import 'shared/providers/firebase_providers.dart';
import 'shared/providers/shared_prefs_provider.dart';

// ── Refresh notifier ──────────────────────────────────────────────────────────

/// Tells GoRouter to re-evaluate its redirect whenever auth state or the
/// user's Firestore profile changes.
class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(Ref ref) {
    ref.listen(authStateProvider, (_, __) => notifyListeners());
    ref.listen(currentUserProfileProvider, (_, __) => notifyListeners());
  }
}

// ── Router provider ───────────────────────────────────────────────────────────

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterRefreshNotifier(ref);
  ref.onDispose(notifier.dispose);

  return GoRouter(
    initialLocation: AppRoutes.onboarding,
    debugLogDiagnostics: false,
    refreshListenable: notifier,
    redirect: (context, state) => _redirect(ref, state),
    routes: [
      // ── Auth / onboarding (no shell) ─────────────────────────────────────
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.signIn,
        builder: (_, __) => const SignInScreen(),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        builder: (_, __) => const SignUpScreen(),
      ),
      GoRoute(
        path: AppRoutes.profileSetup,
        builder: (_, __) => const ProfileSetupScreen(),
      ),

      // ── Admin panel (no shell, self-managed auth) ─────────────────────────
      GoRoute(
        path: AppRoutes.adminLogin,
        builder: (_, __) => const AdminLoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminDashboard,
        builder: (_, __) => const AdminDashboardScreen(),
        routes: [
          GoRoute(
            path: 'add-hotel',
            builder: (context, state) {
              // Pass an existing Hotel via [extra] to enter edit mode.
              final hotel = state.extra as Hotel?;
              return AddHotelScreen(hotel: hotel);
            },
          ),
          GoRoute(
            path: 'view-hotels',
            builder: (_, __) => const ViewHotelsScreen(),
          ),
        ],
      ),

      // ── Authenticated shell with bottom nav ──────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ShellScreen(navigationShell: navigationShell),
        branches: [
          // ── Tab 0: Home ─────────────────────────────────────────────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (_, __) => const HomeScreen(),
                routes: [
                  GoRoute(
                    path: 'education',
                    builder: (_, __) => const EducationHubScreen(),
                  ),
                  GoRoute(
                    path: 'ritual-guide',
                    builder: (_, __) => const RitualGuideScreen(),
                    routes: [
                      GoRoute(
                        path: 'completion',
                        builder: (_, __) =>
                            const RitualCompletionScreen(),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'sai-guide',
                    builder: (_, __) => const SaiGuideScreen(),
                  ),
                  GoRoute(
                    path: 'family-tracker',
                    builder: (_, __) => const FamilyTrackerScreen(),
                  ),
                  GoRoute(
                    path: 'finalize',
                    builder: (_, __) => const FinalizeJourneyScreen(),
                  ),
                ],
              ),
            ],
          ),

          // ── Tab 1: Permits ──────────────────────────────────────────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.permits,
                builder: (_, __) => const PermitWalletScreen(),
              ),
            ],
          ),

          // ── Tab 2: Services ─────────────────────────────────────────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.services,
                builder: (_, __) => const ServicesScreen(),
                routes: [
                  GoRoute(
                    path: 'select-stay',
                    builder: (_, __) => const SelectStayScreen(),
                    routes: [
                      GoRoute(
                        path: 'hotel-details',
                        builder: (context, state) {
                          final extra = state.extra;
                          if (extra is! Hotel) {
                            // Fallback — should not happen in normal flow
                            return HotelDetailsScreen(
                                hotel: Hotel.mockList.first);
                          }
                          return HotelDetailsScreen(hotel: extra);
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'select-transport',
                    builder: (_, __) => const SelectTransportScreen(),
                  ),
                  GoRoute(
                    path: 'emergency',
                    builder: (_, __) => const EmergencyScreen(),
                  ),
                  GoRoute(
                    path: 'packing-checklist',
                    builder: (_, __) => const PackingChecklistScreen(),
                  ),
                ],
              ),
            ],
          ),

          // ── Tab 3: Profile ──────────────────────────────────────────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (_, __) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}, name: 'routerProvider');

// ── Redirect logic ────────────────────────────────────────────────────────────

String? _redirect(Ref ref, GoRouterState state) {
  final loc = state.uri.path;

  // Admin routes are self-managed; skip all normal redirect logic.
  if (loc.startsWith('/admin')) return null;

  final prefs = ref.read(sharedPrefsProvider);
  final authAsync = ref.read(authStateProvider);
  final profileAsync = ref.read(currentUserProfileProvider);

  if (authAsync.isLoading) return null;

  final user = authAsync.valueOrNull;

  // ── Unauthenticated ─────────────────────────────────────────────────────
  if (user == null) {
    const authScreens = {
      AppRoutes.onboarding,
      AppRoutes.signIn,
      AppRoutes.signUp,
    };
    if (authScreens.contains(loc)) return null;

    final onboardingDone =
        prefs.getBool(AppConstants.prefKeyOnboardingDone) ?? false;
    return onboardingDone ? AppRoutes.signIn : AppRoutes.onboarding;
  }

  // ── Authenticated ────────────────────────────────────────────────────────
  const authAndOnboarding = {
    AppRoutes.onboarding,
    AppRoutes.signIn,
    AppRoutes.signUp,
  };

  // Keep the cached flag up-to-date whenever fresh data arrives.
  if (profileAsync.hasValue) {
    prefs.setBool(
      AppConstants.prefKeyProfileComplete,
      profileAsync.valueOrNull?.profileComplete ?? false,
    );
  }

  // While the Firestore stream is still initializing, use the cached flag
  // so the user is not left stuck on the sign-in screen.
  if (profileAsync.isLoading) {
    final cachedComplete =
        prefs.getBool(AppConstants.prefKeyProfileComplete) ?? false;
    if (!cachedComplete) {
      if (loc == AppRoutes.profileSetup) return null;
      return AppRoutes.profileSetup;
    }
    if (authAndOnboarding.contains(loc) || loc == AppRoutes.profileSetup) {
      return AppRoutes.home;
    }
    return null;
  }

  final profile = profileAsync.valueOrNull;
  final profileIncomplete = profile == null || !profile.profileComplete;

  if (profileIncomplete) {
    if (loc == AppRoutes.profileSetup) return null;
    return AppRoutes.profileSetup;
  }

  // Profile complete — bounce out of auth/setup screens.
  if (authAndOnboarding.contains(loc) || loc == AppRoutes.profileSetup) {
    return AppRoutes.home;
  }

  return null;
}

// ── Route paths ───────────────────────────────────────────────────────────────

abstract final class AppRoutes {
  // Auth
  static const onboarding = '/onboarding';
  static const signIn = '/sign-in';
  static const signUp = '/sign-up';
  static const profileSetup = '/profile-setup';

  // Admin panel
  static const adminLogin = '/admin-login';
  static const adminDashboard = '/admin';
  static const addHotel = '/admin/add-hotel';
  static const viewHotels = '/admin/view-hotels';

  // Tab roots
  static const home = '/home';
  static const permits = '/permits';
  static const services = '/services';
  static const profile = '/profile';

  // Home branch
  static const educationHub = '/home/education';
  static const ritualGuide = '/home/ritual-guide';
  static const ritualCompletion = '/home/ritual-guide/completion';
  static const saiGuide = '/home/sai-guide';
  static const familyTracker = '/home/family-tracker';
  static const finalizeJourney = '/home/finalize';

  // Services branch
  static const selectStay = '/services/select-stay';
  static const hotelDetails = '/services/select-stay/hotel-details';
  static const selectTransport = '/services/select-transport';
  static const emergency = '/services/emergency';
  static const packingChecklist = '/services/packing-checklist';
}