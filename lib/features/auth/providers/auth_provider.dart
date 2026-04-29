import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/user_profile.dart';
import '../../../shared/providers/firebase_providers.dart';
import 'user_profile_provider.dart';

// ── State ─────────────────────────────────────────────────────────────────────

enum AuthStatus { initial, authenticated, unauthenticated, loading, error }

class AuthState {
  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  final AuthStatus status;
  final User? user;
  final String? errorMessage;

  bool get isLoading => status == AuthStatus.loading;
  bool get hasError => status == AuthStatus.error;

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
  }) =>
      AuthState(
        status: status ?? this.status,
        user: user ?? this.user,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  AuthState clearError() => AuthState(status: status, user: user);
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    ref.listen<AsyncValue<User?>>(authStateProvider, (_, next) {
      next.when(
        data: (user) => state = AuthState(
          status: user != null
              ? AuthStatus.authenticated
              : AuthStatus.unauthenticated,
          user: user,
        ),
        loading: () => state = state.copyWith(status: AuthStatus.loading),
        error: (_, __) => state = AuthState(
          status: AuthStatus.error,
          errorMessage: 'Something went wrong. Please try again.',
        ),
      );
    });
    return const AuthState();
  }

  FirebaseAuth get _auth => ref.read(firebaseAuthProvider);

  // ── Sign In ────────────────────────────────────────────────────────────────

  Future<void> signInWithEmail(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      // authStateProvider listener will update state to authenticated.
    } on FirebaseAuthException catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: _friendlyError(e.code),
      );
    }
  }

  // ── Sign Up ────────────────────────────────────────────────────────────────

  /// Creates a Firebase Auth user, sets the display name, and writes a minimal
  /// Firestore profile doc with [profileComplete] = false so the router
  /// redirects to the profile-setup screen.
  Future<void> signUpWithEmail(
      String name, String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      // Persist display name on the Auth user object.
      await cred.user?.updateDisplayName(name);

      // Create the Firestore stub so the router can determine
      // profileComplete == false and redirect to /profile-setup.
      final profile = UserProfile(
        uid: cred.user!.uid,
        displayName: name,
        email: email,
        isFirstTimer: true,
        groupSize: 'single',
        language: 'English',
        profileComplete: false,
        createdAt: DateTime.now(),
      );
      await ref.read(userRepositoryProvider).createProfile(profile);
      // authStateProvider listener finalises the state.
    } on FirebaseAuthException catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: _friendlyError(e.code),
      );
    } catch (_) {
      // Auth succeeded but Firestore write failed. Surface a non-blocking
      // warning; profile-setup screen will create the doc on submission.
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: 'Account created but profile save failed. Please complete setup.',
      );
    }
  }

  // ── Password Reset ─────────────────────────────────────────────────────────

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: _friendlyError(e.code),
      );
    }
  }

  // ── Sign Out ───────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _friendlyError(String code) => switch (code) {
        // user-not-found merged with wrong-password to prevent email enumeration
        'user-not-found' || 'wrong-password' || 'invalid-credential' =>
          'Incorrect email or password.',
        'email-already-in-use' =>
          'Sign-up failed. Try signing in or use a different email.',
        'invalid-email' => 'Please enter a valid email address.',
        'weak-password' => 'Password must be at least 6 characters.',
        'network-request-failed' =>
          'No internet connection. Please try again.',
        'too-many-requests' =>
          'Too many attempts. Please try again later.',
        _ => 'Something went wrong. Please try again.',
      };
}

final authNotifierProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
