import 'package:equatable/equatable.dart';

class PastoralPostReactionType {
  static const String amen = 'amen';
  static const String prayer = 'prayer';
  static const String heart = 'heart';

  static const List<String> values = [amen, prayer, heart];

  static String afrikaansLabel(String reactionType) {
    switch (reactionType) {
      case amen:
        return 'Amen';
      case prayer:
        return 'Gebed';
      case heart:
        return 'Hart';
      default:
        return reactionType;
    }
  }
}

class PastoralPost extends Equatable {
  final String id;
  final String authorUserId;
  final String title;
  final String content;
  final String? coverImageUrl;
  final String? coverImagePublicId;
  final bool isPublished;
  final String? createdAt;
  final String? updatedAt;
  final String? authorFirstName;
  final String? authorLastName;
  final String? authorFullName;
  final String? authorProfilePublicId;
  final String? authorProfileUrl;
  final int reactionCount;
  final int amenCount;
  final int prayerCount;
  final int heartCount;
  final String? currentUserReaction;
  final bool isAuthor;

  const PastoralPost({
    required this.id,
    required this.authorUserId,
    required this.title,
    required this.content,
    this.coverImageUrl,
    this.coverImagePublicId,
    this.isPublished = true,
    this.createdAt,
    this.updatedAt,
    this.authorFirstName,
    this.authorLastName,
    this.authorFullName,
    this.authorProfilePublicId,
    this.authorProfileUrl,
    this.reactionCount = 0,
    this.amenCount = 0,
    this.prayerCount = 0,
    this.heartCount = 0,
    this.currentUserReaction,
    this.isAuthor = false,
  });

  String get displayAuthorName {
    final fullName = (authorFullName ?? '').trim();
    if (fullName.isNotEmpty) return fullName;
    final first = (authorFirstName ?? '').trim();
    if (first.isNotEmpty) return first;
    return 'Pastoraat';
  }

  int reactionCountFor(String reactionType) {
    switch (reactionType) {
      case PastoralPostReactionType.amen:
        return amenCount;
      case PastoralPostReactionType.prayer:
        return prayerCount;
      case PastoralPostReactionType.heart:
        return heartCount;
      default:
        return 0;
    }
  }

  PastoralPost copyWith({
    String? id,
    String? authorUserId,
    String? title,
    String? content,
    String? coverImageUrl,
    bool clearCoverImageUrl = false,
    String? coverImagePublicId,
    bool clearCoverImagePublicId = false,
    bool? isPublished,
    String? createdAt,
    String? updatedAt,
    String? authorFirstName,
    String? authorLastName,
    String? authorFullName,
    String? authorProfilePublicId,
    String? authorProfileUrl,
    int? reactionCount,
    int? amenCount,
    int? prayerCount,
    int? heartCount,
    String? currentUserReaction,
    bool clearCurrentUserReaction = false,
    bool? isAuthor,
  }) {
    return PastoralPost(
      id: id ?? this.id,
      authorUserId: authorUserId ?? this.authorUserId,
      title: title ?? this.title,
      content: content ?? this.content,
      coverImageUrl:
          clearCoverImageUrl ? null : coverImageUrl ?? this.coverImageUrl,
      coverImagePublicId: clearCoverImagePublicId
          ? null
          : coverImagePublicId ?? this.coverImagePublicId,
      isPublished: isPublished ?? this.isPublished,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      authorFirstName: authorFirstName ?? this.authorFirstName,
      authorLastName: authorLastName ?? this.authorLastName,
      authorFullName: authorFullName ?? this.authorFullName,
      authorProfilePublicId:
          authorProfilePublicId ?? this.authorProfilePublicId,
      authorProfileUrl: authorProfileUrl ?? this.authorProfileUrl,
      reactionCount: reactionCount ?? this.reactionCount,
      amenCount: amenCount ?? this.amenCount,
      prayerCount: prayerCount ?? this.prayerCount,
      heartCount: heartCount ?? this.heartCount,
      currentUserReaction: clearCurrentUserReaction
          ? null
          : currentUserReaction ?? this.currentUserReaction,
      isAuthor: isAuthor ?? this.isAuthor,
    );
  }

  factory PastoralPost.fromJson(Map<String, dynamic> json) {
    return PastoralPost(
      id: json['id'] ?? '',
      authorUserId: json['author_user_id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      coverImageUrl: json['cover_image_url'],
      coverImagePublicId: json['cover_image_public_id'],
      isPublished: json['is_published'] as bool? ?? false,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      authorFirstName: json['author_first_name'],
      authorLastName: json['author_last_name'],
      authorFullName: json['author_full_name'],
      authorProfilePublicId: json['author_profile_public_id'],
      authorProfileUrl: json['author_profile_url'],
      reactionCount: (json['reaction_count'] as num?)?.toInt() ?? 0,
      amenCount: (json['amen_count'] as num?)?.toInt() ?? 0,
      prayerCount: (json['prayer_count'] as num?)?.toInt() ?? 0,
      heartCount: (json['heart_count'] as num?)?.toInt() ?? 0,
      currentUserReaction: json['current_user_reaction'],
      isAuthor: json['is_author'] ?? false,
    );
  }

  @override
  List<Object?> get props => [
        id,
        authorUserId,
        title,
        content,
        coverImageUrl,
        coverImagePublicId,
        isPublished,
        createdAt,
        updatedAt,
        authorFirstName,
        authorLastName,
        authorFullName,
        authorProfilePublicId,
        authorProfileUrl,
        reactionCount,
        amenCount,
        prayerCount,
        heartCount,
        currentUserReaction,
        isAuthor,
      ];
}
