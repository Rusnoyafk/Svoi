import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/poll_model.dart';
import '../services/announcement_service.dart' show LimitExceededException;

const int kMaxFreePolls = 3;

/// Статус фільтру в списку опитувань
enum PollFilter { active, ended, my }

class PollService {
  final FirebaseFirestore _db;

  PollService({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _polls =>
      _db.collection('polls');

  CollectionReference<Map<String, dynamic>> get _votes =>
      _db.collection('votes');

  // ── Створення ─────────────────────────────────────────────────────────────

  Future<void> createPoll(PollModel poll) async {
    final activeCount = await _polls
        .where('authorUid', isEqualTo: poll.authorUid)
        .where('isActive', isEqualTo: true)
        .count()
        .get();

    if ((activeCount.count ?? 0) >= kMaxFreePolls) {
      throw LimitExceededException(
        'Ви можете мати не більше $kMaxFreePolls активних опитувань',
      );
    }

    await _polls.add(poll.toFirestore());
  }

  // ── Stream списку ──────────────────────────────────────────────────────────

  Stream<List<PollModel>> watchPolls({
    PollFilter filter = PollFilter.active,
    String? uid,
    String? country,
    String? city,
    int limit = 30,
  }) {
    Query<Map<String, dynamic>> q = _polls.where('isActive', isEqualTo: true);

    if (filter == PollFilter.my && uid != null) {
      q = q.where('authorUid', isEqualTo: uid);
    }

    if (country != null) q = q.where('country', isEqualTo: country);

    q = q.orderBy('createdAt', descending: true).limit(limit);

    return q.snapshots().map((snap) {
      final polls = snap.docs.map(PollModel.fromFirestore).toList();
      // Фільтр active/ended по endsAt робимо на клієнті (уникаємо composite index)
      if (filter == PollFilter.active) {
        return polls.where((p) => !p.isEnded).toList();
      } else if (filter == PollFilter.ended) {
        return polls.where((p) => p.isEnded).toList();
      }
      return polls;
    });
  }

  // ── Голосування (транзакція) ────────────────────────────────────────────────

  Future<void> vote({
    required String pollId,
    required String optionId,
    required String userId,
  }) async {
    final voteDocId = '${pollId}_$userId';
    final voteRef = _votes.doc(voteDocId);
    final pollRef = _polls.doc(pollId);

    await _db.runTransaction((tx) async {
      final voteSnap = await tx.get(voteRef);
      if (voteSnap.exists) {
        throw Exception('Ви вже проголосували в цьому опитуванні');
      }

      final pollSnap = await tx.get(pollRef);
      if (!pollSnap.exists) throw Exception('Опитування не знайдено');

      final poll = PollModel.fromFirestore(pollSnap);
      if (poll.isEnded) throw Exception('Опитування вже завершено');

      // Оновлюємо кількість голосів у конкретному варіанті
      final updatedOptions = poll.options.map((opt) {
        if (opt.id == optionId) return opt.copyWith(votes: opt.votes + 1);
        return opt;
      }).toList();

      tx.set(voteRef, PollVote(
        pollId: pollId,
        userId: userId,
        optionId: optionId,
        votedAt: DateTime.now(),
      ).toFirestore());

      tx.update(pollRef, {
        'options': updatedOptions.map((o) => o.toMap()).toList(),
        'totalVotes': FieldValue.increment(1),
      });
    });
  }

  // ── Перевірка чи голосував ────────────────────────────────────────────────

  Future<String?> getVotedOptionId(String pollId, String userId) async {
    final doc = await _votes.doc('${pollId}_$userId').get();
    if (!doc.exists) return null;
    return doc.data()?['optionId'] as String?;
  }

  Stream<String?> watchVotedOptionId(String pollId, String userId) {
    return _votes.doc('${pollId}_$userId').snapshots().map((doc) {
      if (!doc.exists) return null;
      return doc.data()?['optionId'] as String?;
    });
  }

  // ── Видалення (soft delete) ───────────────────────────────────────────────

  Future<void> deletePoll(String id) async {
    await _polls.doc(id).update({'isActive': false});
  }
}
