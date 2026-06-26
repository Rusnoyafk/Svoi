import 'package:cloud_firestore/cloud_firestore.dart';

/// Гео-скоуп опитування
enum GeoScope {
  city,
  country,
  all;

  String get label => switch (this) {
        GeoScope.city => 'Моє місто',
        GeoScope.country => 'Моя країна',
        GeoScope.all => 'Усі українці',
      };
}

/// Один варіант відповіді у опитуванні
class PollOption {
  final String id;
  final String text;
  final int votes;

  const PollOption({
    required this.id,
    required this.text,
    this.votes = 0,
  });

  factory PollOption.fromMap(Map<String, dynamic> map) => PollOption(
        id: map['id'] as String,
        text: map['text'] as String,
        votes: (map['votes'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toMap() => {'id': id, 'text': text, 'votes': votes};

  PollOption copyWith({int? votes}) =>
      PollOption(id: id, text: text, votes: votes ?? this.votes);
}

/// Модель опитування у Firestore (колекція `polls`)
class PollModel {
  final String id;
  final String authorUid;
  final String authorName;
  final String? authorPhotoUrl;
  final String question;
  final List<PollOption> options;
  final GeoScope geoScope;
  final String country;
  final String? city;
  final int durationDays;
  final DateTime createdAt;
  final DateTime endsAt;
  final bool isActive;
  final int totalVotes;

  const PollModel({
    required this.id,
    required this.authorUid,
    required this.authorName,
    this.authorPhotoUrl,
    required this.question,
    required this.options,
    required this.geoScope,
    required this.country,
    this.city,
    required this.durationDays,
    required this.createdAt,
    required this.endsAt,
    this.isActive = true,
    this.totalVotes = 0,
  });

  bool get isEnded => DateTime.now().isAfter(endsAt);

  factory PollModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PollModel(
      id: doc.id,
      authorUid: data['authorUid'] as String,
      authorName: data['authorName'] as String? ?? '',
      authorPhotoUrl: data['authorPhotoUrl'] as String?,
      question: data['question'] as String,
      options: (data['options'] as List<dynamic>? ?? [])
          .map((o) => PollOption.fromMap(o as Map<String, dynamic>))
          .toList(),
      geoScope: GeoScope.values.firstWhere(
        (g) => g.name == data['geoScope'],
        orElse: () => GeoScope.all,
      ),
      country: data['country'] as String? ?? '',
      city: data['city'] as String?,
      durationDays: (data['durationDays'] as num?)?.toInt() ?? 3,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      endsAt: (data['endsAt'] as Timestamp).toDate(),
      isActive: data['isActive'] as bool? ?? true,
      totalVotes: (data['totalVotes'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'authorUid': authorUid,
        'authorName': authorName,
        'authorPhotoUrl': authorPhotoUrl,
        'question': question,
        'options': options.map((o) => o.toMap()).toList(),
        'geoScope': geoScope.name,
        'country': country,
        'city': city,
        'durationDays': durationDays,
        'createdAt': Timestamp.fromDate(createdAt),
        'endsAt': Timestamp.fromDate(endsAt),
        'isActive': isActive,
        'totalVotes': totalVotes,
      };
}

/// Голос користувача (субколекція `votes`)
class PollVote {
  final String pollId;
  final String userId;
  final String optionId;
  final DateTime votedAt;

  const PollVote({
    required this.pollId,
    required this.userId,
    required this.optionId,
    required this.votedAt,
  });

  Map<String, dynamic> toFirestore() => {
        'pollId': pollId,
        'userId': userId,
        'optionId': optionId,
        'votedAt': Timestamp.fromDate(votedAt),
      };
}
