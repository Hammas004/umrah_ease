import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/models/user_profile.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../shared/providers/firebase_providers.dart';
import '../../../shared/providers/shared_prefs_provider.dart';

// ── Repository ────────────────────────────────────────────────────────────────

final userRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepository(ref.watch(firestoreProvider)),
  name: 'userRepositoryProvider',
);

// ── Profile Stream ────────────────────────────────────────────────────────────

/// Real-time [UserProfile] for the currently signed-in user.
/// Emits null when the user is signed out or has no Firestore doc yet.
final currentUserProfileProvider = StreamProvider<UserProfile?>(
  (ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) return Stream.value(null);
    return ref.watch(userRepositoryProvider).profileStream(user.uid);
  },
  name: 'currentUserProfileProvider',
);

// ── Profile-Setup Notifier ────────────────────────────────────────────────────

/// Handles the one-time profile-setup step after sign-up.
/// Calling [completeSetup] writes isFirstTimer + groupSize to Firestore and
/// flips profileComplete to true, which triggers the router redirect to /home.
class ProfileSetupNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> completeSetup({
    required String uid,
    required bool isFirstTimer,
    required String groupSize,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(userRepositoryProvider).updateProfile(uid, {
        'isFirstTimer': isFirstTimer,
        'groupSize': groupSize,
        'profileComplete': true,
      }),
    );
    // Cache the flag so the router can navigate instantly on next launch
    // without waiting for the Firestore stream to emit.
    if (!state.hasError) {
      await ref
          .read(sharedPrefsProvider)
          .setBool(AppConstants.prefKeyProfileComplete, true);
    }
  }
}

final profileSetupProvider =
    AsyncNotifierProvider<ProfileSetupNotifier, void>(
  ProfileSetupNotifier.new,
  name: 'profileSetupProvider',
);
