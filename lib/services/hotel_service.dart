import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_constants.dart';
import '../data/models/hotel.dart';
import '../shared/providers/firebase_providers.dart';

/// Handles all Firestore CRUD operations for the [hotels] collection.
class HotelService {
  HotelService(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection(AppConstants.colHotels);

  // ── Read ──────────────────────────────────────────────────────────────────

  /// Real-time stream of all hotels, ordered by creation date (newest first).
  Stream<List<Hotel>> hotelsStream() {
    return _col
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => Hotel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// One-time fetch of all hotels.
  Future<List<Hotel>> getHotels() async {
    final snap = await _col.orderBy('createdAt', descending: true).get();
    return snap.docs
        .map((doc) => Hotel.fromMap(doc.data(), doc.id))
        .toList();
  }

  // ── Write ─────────────────────────────────────────────────────────────────

  /// Adds a new hotel document; Firestore auto-generates the ID.
  Future<void> addHotel(Hotel hotel) async {
    await _col.add(hotel.toCreateMap());
  }

  /// Updates an existing hotel document by [hotel.id].
  Future<void> updateHotel(Hotel hotel) async {
    await _col.doc(hotel.id).update(hotel.toUpdateMap());
  }

  /// Permanently deletes a hotel document.
  Future<void> deleteHotel(String id) async {
    await _col.doc(id).delete();
  }

  // ── Admin check ───────────────────────────────────────────────────────────

  /// Returns true when [uid] has a document in the [admins] collection.
  Future<bool> isAdmin(String uid) async {
    final doc = await _firestore.collection('admins').doc(uid).get();
    return doc.exists;
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

final hotelServiceProvider = Provider<HotelService>(
  (ref) => HotelService(ref.watch(firestoreProvider)),
  name: 'hotelServiceProvider',
);

/// Real-time stream of hotels from Firestore, used by the user-facing list.
final hotelsStreamProvider = StreamProvider<List<Hotel>>(
  (ref) => ref.watch(hotelServiceProvider).hotelsStream(),
  name: 'hotelsStreamProvider',
);

/// Returns true if the currently signed-in user is an admin.
/// Re-evaluates automatically when the auth state changes.
final isAdminProvider = FutureProvider<bool>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return false;
  return ref.read(hotelServiceProvider).isAdmin(user.uid);
}, name: 'isAdminProvider');