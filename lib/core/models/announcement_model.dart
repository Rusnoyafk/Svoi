import 'package:cloud_firestore/cloud_firestore.dart';
import '../app_category.dart';

/// Модель оголошення у Firestore (колекція `announcements`)
class AnnouncementModel {
  final String id;
  final String authorUid;
  final String authorName;
  final String? authorPhotoUrl;
  final String title;
  final String description;
  final AnnouncementCategory category;
  final String country;
  final String? city;
  final String? contactInfo;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isActive;

  const AnnouncementModel({
    required this.id,
    required this.authorUid,
    required this.authorName,
    this.authorPhotoUrl,
    required this.title,
    required this.description,
    required this.category,
    required this.country,
    this.city,
    this.contactInfo,
    required this.createdAt,
    required this.expiresAt,
    this.isActive = true,
  });

  factory AnnouncementModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AnnouncementModel(
      id: doc.id,
      authorUid: data['authorUid'] as String,
      authorName: data['authorName'] as String? ?? '',
      authorPhotoUrl: data['authorPhotoUrl'] as String?,
      title: data['title'] as String,
      description: data['description'] as String,
      category: AnnouncementCategory.values.firstWhere(
        (c) => c.name == data['category'],
        orElse: () => AnnouncementCategory.services,
      ),
      country: data['country'] as String? ?? '',
      city: data['city'] as String?,
      contactInfo: data['contactInfo'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      expiresAt: (data['expiresAt'] as Timestamp).toDate(),
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
        'contactInfo': contactInfo,
        'createdAt': Timestamp.fromDate(createdAt),
        'expiresAt': Timestamp.fromDate(expiresAt),
        'isActive': isActive,
      };

  AnnouncementModel copyWith({
    String? title,
    String? description,
    AnnouncementCategory? category,
    String? city,
    String? contactInfo,
    bool? isActive,
  }) =>
      AnnouncementModel(
        id: id,
        authorUid: authorUid,
        authorName: authorName,
        authorPhotoUrl: authorPhotoUrl,
        title: title ?? this.title,
        description: description ?? this.description,
        category: category ?? this.category,
        country: country,
        city: city ?? this.city,
        contactInfo: contactInfo ?? this.contactInfo,
        createdAt: createdAt,
        expiresAt: expiresAt,
        isActive: isActive ?? this.isActive,
      );
}
