import 'package:cloud_firestore/cloud_firestore.dart';
import '../app_category.dart';
import '../models/event_model.dart';
import 'announcement_service.dart' show LimitExceededException;

const int kMaxFreeEvents = 3;

/// Сервіс для роботи з івентами у Firestore
class EventService {
  final FirebaseFirestore _db;

  EventService({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('events');

  /// Створити івент. Повертає помилку якщо перевищено ліміт.
  Future<void> createEvent(EventModel model) async {
    final count = await _countActiveByUser(model.authorUid);
    if (count >= kMaxFreeEvents) {
      throw LimitExceededException(
        'Ви можете мати не більше $kMaxFreeEvents активних івентів',
      );
    }
    await _col.add(model.toFirestore());
  }

  Future<int> _countActiveByUser(String uid) async {
    final snap = await _col
        .where('authorUid', isEqualTo: uid)
        .where('isActive', isEqualTo: true)
        .count()
        .get();
    return snap.count ?? 0;
  }

  /// Stream івентів з фільтром по категорії — сортування за датою (найближчі першими)
  Stream<List<EventModel>> watchEvents({
    EventCategory? category,
    String? country,
    int limit = 30,
  }) {
    final now = Timestamp.fromDate(DateTime.now());
    Query<Map<String, dynamic>> q = _col
        .where('isActive', isEqualTo: true)
        .where('eventDate', isGreaterThanOrEqualTo: now)
        .orderBy('eventDate')
        .limit(limit);

    if (category != null) q = q.where('category', isEqualTo: category.name);
    if (country != null) q = q.where('country', isEqualTo: country);

    return q.snapshots().map(
          (snap) => snap.docs.map(EventModel.fromFirestore).toList(),
        );
  }

  /// Мої івенти (створені мною)
  Stream<List<EventModel>> watchMyEvents(String uid) {
    return _col
        .where('authorUid', isEqualTo: uid)
        .where('isActive', isEqualTo: true)
        .orderBy('eventDate')
        .snapshots()
        .map((s) => s.docs.map(EventModel.fromFirestore).toList());
  }

  /// Оновити поля івенту
  Future<void> updateEvent(String id, Map<String, dynamic> data) async {
    await _col.doc(id).update(data);
  }

  /// М'яке видалення
  Future<void> deleteEvent(String id) async {
    await _col.doc(id).update({'isActive': false});
  }

  /// Приєднатися до івенту
  Future<void> joinEvent(String eventId, String uid) async {
    await _col.doc(eventId).update({
      'participantUids': FieldValue.arrayUnion([uid]),
    });
  }

  /// Відписатися від івенту
  Future<void> leaveEvent(String eventId, String uid) async {
    await _col.doc(eventId).update({
      'participantUids': FieldValue.arrayRemove([uid]),
    });
  }
}
