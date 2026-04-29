import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/permit.dart';
import '../../../shared/providers/firebase_providers.dart';

/// Loads the current user's permits from the Firestore `permits` collection.
/// Returns an empty list when the user has no permits yet.
class PermitNotifier extends AsyncNotifier<List<Permit>> {
  @override
  Future<List<Permit>> build() async {
    final user = ref.watch(currentUserProvider);
    if (user == null) return [];

    final fs = ref.read(firestoreProvider);
    final snap = await fs
        .collection('permits')
        .where('uid', isEqualTo: user.uid)
        .get();

    return snap.docs
        .map((doc) => Permit.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = ref.read(currentUserProvider);
      if (user == null) return <Permit>[];
      final fs = ref.read(firestoreProvider);
      final snap = await fs
          .collection('permits')
          .where('uid', isEqualTo: user.uid)
          .get();
      return snap.docs
          .map((doc) => Permit.fromMap(doc.id, doc.data()))
          .toList();
    });
  }
}

final permitProvider =
    AsyncNotifierProvider<PermitNotifier, List<Permit>>(
  PermitNotifier.new,
  name: 'permitProvider',
);
