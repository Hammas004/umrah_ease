import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/app_constants.dart';
import '../models/user_profile.dart';

class UserRepository {
  UserRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection(AppConstants.colUsers);

  /// Creates a new user document. Called immediately after Firebase Auth
  /// registration, before the profile-setup step.
  Future<void> createProfile(UserProfile profile) {
    _validateProfile(profile);
    return _col.doc(profile.uid).set(profile.toMap());
  }

  /// Partial update — use for experience-level changes and profile completion.
  /// Uses set+merge so it creates the document if it doesn't exist yet
  /// (handles the case where Firestore write failed silently during sign-up).
  Future<void> updateProfile(String uid, Map<String, dynamic> fields) {
    if (uid.isEmpty) throw ArgumentError('uid must not be empty');
    _validateFields(fields);
    return _col.doc(uid).set(fields, SetOptions(merge: true));
  }

  void _validateProfile(UserProfile profile) {
    if (profile.uid.isEmpty) throw ArgumentError('uid must not be empty');
    if (profile.displayName.trim().isEmpty) throw ArgumentError('displayName must not be empty');
    if (profile.displayName.length > 100) throw ArgumentError('displayName too long');
    if (profile.email.trim().isEmpty) throw ArgumentError('email must not be empty');
    if (profile.email.length > 254) throw ArgumentError('email too long');
    const validGroupSizes = {'single', 'family', 'group'};
    if (!validGroupSizes.contains(profile.groupSize)) {
      throw ArgumentError('Invalid groupSize: ${profile.groupSize}');
    }
  }

  void _validateFields(Map<String, dynamic> fields) {
    if (fields.isEmpty) throw ArgumentError('fields must not be empty');
    final displayName = fields['displayName'];
    if (displayName != null) {
      if (displayName is! String || displayName.trim().isEmpty) {
        throw ArgumentError('displayName must be a non-empty string');
      }
      if (displayName.length > 100) throw ArgumentError('displayName too long');
    }
    final groupSize = fields['groupSize'];
    if (groupSize != null) {
      const valid = {'single', 'family', 'group'};
      if (!valid.contains(groupSize)) throw ArgumentError('Invalid groupSize: $groupSize');
    }
  }

  /// One-shot fetch. Used for auth redirect checks.
  Future<UserProfile?> getProfile(String uid) async {
    final snap = await _col.doc(uid).get();
    if (!snap.exists || snap.data() == null) return null;
    return UserProfile.fromMap(snap.id, snap.data()!);
  }

  /// Real-time stream. Drives the router's redirect and profile-settings UI.
  Stream<UserProfile?> profileStream(String uid) =>
      _col.doc(uid).snapshots().map((snap) {
        if (!snap.exists || snap.data() == null) return null;
        return UserProfile.fromMap(snap.id, snap.data()!);
      });
}
