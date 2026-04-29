import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/umrah_guide.dart';
import '../../../data/repositories/guide_repository.dart';
import '../../../shared/providers/database_provider.dart';
import '../../../shared/providers/firebase_providers.dart';

// ── Repository provider ───────────────────────────────────────────────────────

final guideRepositoryProvider = Provider<GuideRepository>(
  (ref) => GuideRepository(
    firestore: ref.watch(firestoreProvider),
    db: ref.watch(databaseHelperProvider),
  ),
  name: 'guideRepositoryProvider',
);

// ── Training state ────────────────────────────────────────────────────────────

/// Categorised view of guides, keyed by [UmrahGuide.category].
typedef GuidesByCategory = Map<String, List<UmrahGuide>>;

// ── Notifier ──────────────────────────────────────────────────────────────────

/// Loads Umrah guides with a cache-first strategy:
///
/// 1. Check the local sqflite `umrah_guides` table.
/// 2. If rows exist → return them immediately (works fully offline).
/// 3. If empty → fetch from Firestore, cache locally, then return.
///
/// Call [refresh] to force a Firestore re-fetch (e.g. pull-to-refresh).
class TrainingNotifier extends AsyncNotifier<List<UmrahGuide>> {
  @override
  Future<List<UmrahGuide>> build() => _load();

  Future<List<UmrahGuide>> _load() =>
      ref.read(guideRepositoryProvider).loadGuides();

  /// Force-refreshes from Firestore and re-caches locally.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(guideRepositoryProvider).refreshGuides(),
    );
  }
}

final trainingProvider =
    AsyncNotifierProvider<TrainingNotifier, List<UmrahGuide>>(
  TrainingNotifier.new,
  name: 'trainingProvider',
);

// ── Derived providers ─────────────────────────────────────────────────────────

/// Guides grouped by [UmrahGuide.category], preserving insertion order.
final guidesByCategoryProvider = Provider<AsyncValue<GuidesByCategory>>(
  (ref) {
    return ref.watch(trainingProvider).whenData((guides) {
      final map = <String, List<UmrahGuide>>{};
      for (final guide in guides) {
        map.putIfAbsent(guide.category, () => []).add(guide);
      }
      return map;
    });
  },
  name: 'guidesByCategoryProvider',
);

/// Guides filtered to a single [category].
final guidesByCategoryNameProvider =
    Provider.family<AsyncValue<List<UmrahGuide>>, String>(
  (ref, category) {
    return ref.watch(trainingProvider).whenData(
          (guides) =>
              guides.where((g) => g.category == category).toList(),
        );
  },
  name: 'guidesByCategoryNameProvider',
);
