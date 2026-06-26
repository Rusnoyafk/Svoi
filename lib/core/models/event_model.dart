import 'package:cloud_firestore/cloud_firestore.dart';
import '../app_category.dart';

/// Модель івенту у Firestore (колекція `events`)
class EventModel {
  final String id;
  final String authorUid;
  final String authorName;
  final String? authorPhotoUrl;
  final String title;
  final String description;
  final EventCategory category;
  final String country;
  final String? city;
  final String? address;
  final DateTime eventDate;
  final DateTime? eventEndDate;
  final bool isOnline;
  final String? onlineLink;
  final int? maxParticipants;
  final List<String> participantUids;
  final String? contactInfo;
  final DateTime createdAt;
  final bool isActive;

  const EventModel({
    required this.id,
    required this.authorUid,
    required this.authorName,
    this.authorPhotoUrl,
    required this.title,
    required this.description,
    required this.category,
    required this.country,
    this.city,
    this.address,
    required this.eventDate,
    this.eventEndDate,
    this.isOnline = false,
    this.onlineLink,
    this.maxParticipants,
    this.participantUids = const [],
    this.contactInfo,
    required this.createdAt,
    this.isActive = true,
  });

  bool get isFull =>
      maxParticipants != null && participantUids.length >= maxParticipants!;

  int get participantCount => participantUids.length;

  factory EventModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EventModel(
      id: doc.id,
      authorUid: data['authorUid'] as String,
      authorName: data['authorName'] as String? ?? '',
      authorPhotoUrl: data['authorPhotoUrl'] as String?,
      title: data['title'] as String,
      description: data['description'] as String,
      category: EventCategory.values.firstWhere(
        (c) => c.name == data['category'],
        orElse: () => EventCategory.meetups,
      ),
      country: data['country'] as String? ?? '',
      city: data['city'] as String?,
      address: data['address'] as String?,
      eventDate: (data['eventDate'] as Timestamp).toDate(),
      eventEndDate: data['eventEndDate'] != null
          ? (data['eventEndDate'] as Timestamp).toDate()
          : null,
      isOnline: data['isOnline'] as bool? ?? false,
      onlineLink: data['onlineLink'] as String?,
      maxParticipants: data['maxParticipants'] as int?,
      participantUids: List<String>.from(data['participantUids'] as List? ?? []),
      contactInfo: data['contactInfo'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isActive: data['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'authorUid': authorUid,
        'authorName': authorName,
        'authorPhotoUrl': authorPhotoUrl,
        'title': title,
        'description': description,
        'category': category.name,
        'country': country,
        'city': city,
        'address': address,
        'eventDate': Timestamp.fromDate(eventDate),
        'eventEndDate':
            eventEndDate != null ? Timestamp.fromDate(eventEndDate!) : null,
        'isOnline': isOnline,
        'onlineLink': onlineLink,
        'maxParticipants': maxParticipants,
        'participantUids': participantUids,
        'contactInfo': contactInfo,
        'createdAt': Timestamp.fromDate(createdAt),
        'isActive': isActive,
      };

  EventModel copyWith({
    String? title,
    String? description,
    EventCategory? category,
    String? city,
    String? address,
    DateTime? eventDate,
    DateTime? eventEndDate,
    bool? isOnline,
    String? onlineLink,
    int? maxParticipants,
    List<String>? participantUids,
    String? contactInfo,
    bool? isActive,
  }) =>
      EventModel(
        id: id,
        authorUid: authorUid,
        authorName: authorName,
        authorPhotoUrl: authorPhotoUrl,
        title: title ?? this.title,
        description: description ?? this.description,
        category: category ?? this.category,
        country: country,
        city: city ?? this.city,
        address: address ?? this.address,
        eventDate: eventDate ?? this.eventDate,
        eventEndDate: eventEndDate ?? this.eventEndDate,
        isOnline: isOnline ?? this.isOnline,
        onlineLink: onlineLink ?? this.onlineLink,
        maxParticipants: maxParticipants ?? this.maxParticipants,
        participantUids: participantUids ?? this.participantUids,
        contactInfo: contactInfo ?? this.contactInfo,
        createdAt: createdAt,
        isActive: isActive ?? this.isActive,
      );
}
