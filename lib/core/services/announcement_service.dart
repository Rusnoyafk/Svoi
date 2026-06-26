import 'package:cloud_firestore/cloud_firestore.dart';
import '../app_category.dart';
import '../models/announcement_model.dart';

/// Максимальна кількість безкоштовних активних оголошень
const int kMaxFreeAnnouncements = 3;

/// Сервіс для роботи з оголошеннями у Firestore
class AnnouncementService {
  final FirebaseFirestore _db;

  AnnouncementService({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('announcements');

  /// Створити оголошення. Повертає помилку якщо перевищено ліміт.
  Future<void> createAnnouncement(AnnouncementModel model) async {
    final activeCount = await _countActiveByUser(model.authorUid);
    if (activeCount >= kMaxFreeAnnouncements) {
      throw LimitExceededException(
        'Ви можете мати не більше $kMaxFreeAnnouncements активних оголошень',
      );
    }
    await _col.add(model.toFirestore());
  }

  /// Кількість активних оголошень користувача
  Future<int> _countActiveByUser(String uid) async {
    final snap = await _col
        .where('authorUid', isEqualTo: uid)
        .where('isActive', isEqualTo: true)
        .count()
        .get();
    return snap.count ?? 0;
  }

  /// Список оголошень з фільтрацією. Підтримує пагінацію через [startAfter].
  Future<List<AnnouncementModel>> getAnnouncements({
    AnnouncementCategory? category,
    String? country,
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    Query<Map<String, dynamic>> q = _col
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (category != null) q = q.where('category', isEqualTo: category.name);
    if (country != null) q = q.where('country', isEqualTo: country);
    if (startAfter != null) q = q.startAfterDocument(startAfter);

    final snap = await q.get();
    return snap.docs.map(AnnouncementModel.fromFirestore).toList();
  }

  /// Stream оголошень (з фільтром по категорії)
  Stream<List<AnnouncementModel>> watchAnnouncements({
    AnnouncementCategory? category,
    String? country,
    int limit = 30,
  }) {
    Query<Map<String, dynamic>> q = _col
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (category != null) q = q.where('category', isEqualTo: category.name);
    if (country != null) q = q.where('country', isEqualTo: country);

    return q.snapshots().map(
          (snap) => snap.docs.map(AnnouncementModel.fromFirestore).toList(),
        );
  }

  /// Оголошення поточного юзера
  Stream<List<AnnouncementModel>> watchMyAnnouncements(String uid) {
    return _col
        .where('authorUid', isEqualTo: uid)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(AnnouncementModel.fromFirestore).toList());
  }

  /// Оновити поля оголошення
  Future<void> updateAnnouncement(String id, Map<String, dynamic> data) async {
    await _col.doc(id).update(data);
  }

  /// М'яке видалення (isActive = false)
  Future<void> deleteAnnouncement(String id) async {
    await _col.doc(id).update({'isActive': false});
  }
}

/// Виняток при перевищенні ліміту оголошень
class LimitExceededException implements Exception {
  final String message;
  const LimitExceededException(this.message);

  @override
  String toString() => message;
}
