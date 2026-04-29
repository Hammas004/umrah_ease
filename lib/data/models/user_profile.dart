import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  const UserProfile({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.isFirstTimer,
    required this.groupSize,
    required this.language,
    required this.profileComplete,
    required this.createdAt,
  });

  final String uid;
  final String displayName;
  final String email;

  /// true = First-Timer, false = Experienced.
  final bool isFirstTimer;

  /// One of: 'single' | 'family' | 'group'
  final String groupSize;

  final String language;
  final bool profileComplete;
  final DateTime createdAt;

  factory UserProfile.fromMap(String uid, Map<String, dynamic> map) {
    return UserProfile(
      uid: uid,
      displayName: map['displayName'] as String? ?? '',
      email: map['email'] as String? ?? '',
      isFirstTimer: map['isFirstTimer'] as bool? ?? true,
      groupSize: map['groupSize'] as String? ?? 'single',
      language: map['language'] as String? ?? 'English',
      profileComplete: map['profileComplete'] as bool? ?? false,
      createdAt:
          (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'displayName': displayName,
        'email': email,
        'isFirstTimer': isFirstTimer,
        'groupSize': groupSize,
        'language': language,
        'profileComplete': profileComplete,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  UserProfile copyWith({
    String? displayName,
    bool? isFirstTimer,
    String? groupSize,
    String? language,
    bool? profileComplete,
  }) =>
      UserProfile(
        uid: uid,
        displayName: displayName ?? this.displayName,
        email: email,
        isFirstTimer: isFirstTimer ?? this.isFirstTimer,
        groupSize: groupSize ?? this.groupSize,
        language: language ?? this.language,
        profileComplete: profileComplete ?? this.profileComplete,
        createdAt: createdAt,
      );
}
