import 'package:cloud_firestore/cloud_firestore.dart';

/// Профіль користувача у Firestore (колекція `users`)
class UserProfile {
  final String uid;
  final String displayName;
  final String email;
  final String? photoUrl;

  /// Поточне місцезнаходження
  final String? country;
  final String? city;

  /// Звідки родом (Україна)
  final String? originOblast;
  final String? originCity;

  /// Коротко про себе (до 200 символів)
  final String? bio;

  /// Роль: "user" | "organizer" | "admin"
  final String role;

  final DateTime createdAt;
  final DateTime lastActiveAt;

  /// Додаткові дані для організаторів
  final Map<String, dynamic>? organizerProfile;

  const UserProfile({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoUrl,
    this.country,
    this.city,
    this.originOblast,
    this.originCity,
    this.bio,
    required this.role,
    required this.createdAt,
    required this.lastActiveAt,
    this.organizerProfile,
  });

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      uid: doc.id,
      displayName: data['displayName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      photoUrl: data['photoUrl'] as String?,
      country: data['country'] as String?,
      city: data['city'] as String?,
      originOblast: data['originOblast'] as String?,
      originCity: data['originCity'] as String?,
      bio: data['bio'] as String?,
      role: data['role'] as String? ?? 'user',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastActiveAt: (data['lastActiveAt'] as Timestamp).toDate(),
      organizerProfile: data['organizerProfile'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'displayName': displayName,
        'email': email,
        'photoUrl': photoUrl,
        'country': country,
        'city': city,
        'originOblast': originOblast,
        'originCity': originCity,
        'bio': bio,
        'role': role,
        'createdAt': Timestamp.fromDate(createdAt),
        'lastActiveAt': Timestamp.fromDate(lastActiveAt),
        if (organizerProfile != null) 'organizerProfile': organizerProfile,
      };

  UserProfile copyWith({
    String? displayName,
    String? email,
    String? photoUrl,
    String? country,
    String? city,
    String? originOblast,
    String? originCity,
    String? bio,
    String? role,
    DateTime? lastActiveAt,
    Map<String, dynamic>? organizerProfile,
  }) =>
      UserProfile(
        uid: uid,
        displayName: displayName ?? this.displayName,
        email: email ?? this.email,
        photoUrl: photoUrl ?? this.photoUrl,
        country: country ?? this.country,
        city: city ?? this.city,
        originOblast: originOblast ?? this.originOblast,
        originCity: originCity ?? this.originCity,
        bio: bio ?? this.bio,
        role: role ?? this.role,
        createdAt: createdAt,
        lastActiveAt: lastActiveAt ?? this.lastActiveAt,
        organizerProfile: organizerProfile ?? this.organizerProfile,
      );
}
