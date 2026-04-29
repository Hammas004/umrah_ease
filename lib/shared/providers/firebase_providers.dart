import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Firebase Auth ────────────────────────────────────────────────────────────

final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
  name: 'firebaseAuthProvider',
);

/// Stream of the currently signed-in [User], or null when signed out.
final authStateProvider = StreamProvider<User?>(
  (ref) => ref.watch(firebaseAuthProvider).authStateChanges(),
  name: 'authStateProvider',
);

/// Convenience: returns the current [User] synchronously (may be null).
final currentUserProvider = Provider<User?>(
  (ref) => ref.watch(authStateProvider).valueOrNull,
  name: 'currentUserProvider',
);

// ── Firestore ────────────────────────────────────────────────────────────────

final firestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
  name: 'firestoreProvider',
);
