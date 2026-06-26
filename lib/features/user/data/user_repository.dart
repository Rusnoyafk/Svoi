import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/user_profile.dart';

/// Репозиторій профілів користувачів у Firestore (колекція `users`)
class UserRepository {
  final FirebaseFirestore _db;

  UserRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  /// Отримати профіль за uid
  Future<UserProfile?> getProfile(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) return null;
    return UserProfile.fromFirestore(doc);
  }

  /// Спостерігати за профілем у реальному часі
  Stream<UserProfile?> watchProfile(String uid) {
    return _users.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserProfile.fromFirestore(doc);
    });
  }

  /// При першому вході — створюємо профіль; при повторному — оновлюємо lastActiveAt
  Future<void> createOrUpdateOnSignIn(User user, bool isNewUser) async {
    final ref = _users.doc(user.uid);
    final now = DateTime.now();

    if (isNewUser) {
      final profile = UserProfile(
        uid: user.uid,
        displayName: user.displayName ?? '',
        email: user.email ?? '',
        photoUrl: user.photoURL,
        role: 'user',
        createdAt: now,
        lastActiveAt: now,
      );
      await ref.set(profile.toFirestore());
    } else {
      // Оновлюємо тільки змінені поля
      await ref.update({
        'lastActiveAt': Timestamp.fromDate(now),
        'displayName': user.displayName ?? '',
        'photoUrl': user.photoURL,
      });
    }
  }

  /// Оновити будь-які поля профілю
  Future<void> updateProfile(String uid, Map<String, dynamic> fields) async {
    await _users.doc(uid).update(fields);
  }

  /// Зберегти FCM токен у профіль
  Future<void> saveFcmToken(String uid, String token) async {
    await _users.doc(uid).update({'fcmToken': token});
  }
}
