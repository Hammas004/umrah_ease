import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/checklist_item.dart';
import '../../../shared/providers/database_provider.dart';

// ── Default seed data ─────────────────────────────────────────────────────────

const _defaultItems = <Map<String, dynamic>>[
  // Documents
  {'category': 'Documents', 'item_name': 'Passport (valid 6+ months)', 'sort_order': 0},
  {'category': 'Documents', 'item_name': 'Nusuk / Umrah Visa', 'sort_order': 1},
  {'category': 'Documents', 'item_name': 'Flight Tickets (printed)', 'sort_order': 2},
  {'category': 'Documents', 'item_name': 'Hotel Booking Confirmation', 'sort_order': 3},
  {'category': 'Documents', 'item_name': 'Travel Insurance Card', 'sort_order': 4},
  {'category': 'Documents', 'item_name': 'Meningitis Vaccination Certificate', 'sort_order': 5},
  // Clothing
  {'category': 'Clothing', 'item_name': 'Ihram Garments (2 sets)', 'sort_order': 0},
  {'category': 'Clothing', 'item_name': 'Undershirts (5+)', 'sort_order': 1},
  {'category': 'Clothing', 'item_name': 'Underwear (5+)', 'sort_order': 2},
  {'category': 'Clothing', 'item_name': 'Comfortable Walking Shoes', 'sort_order': 3},
  {'category': 'Clothing', 'item_name': 'Sandals / Flip-Flops', 'sort_order': 4},
  {'category': 'Clothing', 'item_name': 'Prayer Cap / Kufi', 'sort_order': 5},
  {'category': 'Clothing', 'item_name': 'Light Jacket (for Masjid AC)', 'sort_order': 6},
  // Medications
  {'category': 'Medications', 'item_name': 'Pain Relievers (Paracetamol)', 'sort_order': 0},
  {'category': 'Medications', 'item_name': 'Antihistamine / Allergy Tablets', 'sort_order': 1},
  {'category': 'Medications', 'item_name': 'Blister Plasters', 'sort_order': 2},
  {'category': 'Medications', 'item_name': 'Oral Rehydration Salts', 'sort_order': 3},
  {'category': 'Medications', 'item_name': 'Sunscreen SPF 50+', 'sort_order': 4},
  {'category': 'Medications', 'item_name': 'Personal Prescription Meds', 'sort_order': 5},
  // Toiletries
  {'category': 'Toiletries', 'item_name': 'Unscented Soap (Ihram rule)', 'sort_order': 0},
  {'category': 'Toiletries', 'item_name': 'Unscented Shampoo (Ihram rule)', 'sort_order': 1},
  {'category': 'Toiletries', 'item_name': 'Toothbrush & Toothpaste', 'sort_order': 2},
  {'category': 'Toiletries', 'item_name': 'Unscented Deodorant', 'sort_order': 3},
  {'category': 'Toiletries', 'item_name': 'Wet Wipes (large pack)', 'sort_order': 4},
  {'category': 'Toiletries', 'item_name': 'Nail Clippers', 'sort_order': 5},
  // Electronics
  {'category': 'Electronics', 'item_name': 'Mobile Phone + Charger', 'sort_order': 0},
  {'category': 'Electronics', 'item_name': 'Power Bank (20000 mAh)', 'sort_order': 1},
  {'category': 'Electronics', 'item_name': 'Universal Travel Adapter', 'sort_order': 2},
  {'category': 'Electronics', 'item_name': 'Earphones / Earbuds', 'sort_order': 3},
  {'category': 'Electronics', 'item_name': 'Small Torch / Flashlight', 'sort_order': 4},
];

// ── Notifier ──────────────────────────────────────────────────────────────────

class ChecklistNotifier extends AsyncNotifier<List<ChecklistItem>> {
  @override
  Future<List<ChecklistItem>> build() async {
    try {
      final db = ref.read(databaseHelperProvider);
      final total = await db.getChecklistTotalCount();
      if (total == 0) await _seed(db);
      final rows = await db.getAllChecklistItems();
      return rows.map(ChecklistItem.fromMap).toList();
    } catch (e, st) {
      debugPrint('ChecklistNotifier.build error: $e\n$st');
      rethrow;
    }
  }

  Future<void> _seed(dynamic db) async {
    final now = DateTime.now().toUtc().toIso8601String();
    for (final item in _defaultItems) {
      await db.insertChecklistItem({
        ...item,
        'is_checked': 0,
        'is_custom': 0,
        'created_at': now,
      });
    }
  }

  Future<void> toggle(int id, bool value) async {
    final db = ref.read(databaseHelperProvider);
    await db.toggleChecklistItem(id, value);
    state = AsyncData(
      state.requireValue
          .map((item) => item.id == id ? item.copyWith(isChecked: value) : item)
          .toList(),
    );
  }

  Future<void> addCustom(String category, String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty || trimmed.length > 100) return;
    if (category.trim().isEmpty) return;
    final db = ref.read(databaseHelperProvider);
    final now = DateTime.now().toUtc().toIso8601String();
    await db.insertChecklistItem({
      'category': category.trim(),
      'item_name': trimmed,
      'is_checked': 0,
      'is_custom': 1,
      'sort_order': 999,
      'created_at': now,
    });
    final rows = await db.getAllChecklistItems();
    state = AsyncData(rows.map(ChecklistItem.fromMap).toList());
  }

  Future<void> delete(int id) async {
    final db = ref.read(databaseHelperProvider);
    await db.deleteChecklistItem(id);
    state = AsyncData(
      state.requireValue.where((item) => item.id != id).toList(),
    );
  }
}

final checklistProvider =
    AsyncNotifierProvider<ChecklistNotifier, List<ChecklistItem>>(
  ChecklistNotifier.new,
  name: 'checklistProvider',
);

/// Pre-computed progress: (checked, total) for the header badge.
final checklistProgressProvider = Provider<(int, int)>(
  (ref) {
    final items = ref.watch(checklistProvider).valueOrNull ?? [];
    final checked = items.where((i) => i.isChecked).length;
    return (checked, items.length);
  },
  name: 'checklistProgressProvider',
);
