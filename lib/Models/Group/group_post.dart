import 'package:equatable/equatable.dart';
import 'package:lw_app/l10n/app_localizations.dart';

class GroupPostReactionType {
  static const String amen = 'amen';
  static const String prayer = 'prayer';
  static const String heart = 'heart';

  static const List<String> values = [amen, prayer, heart];

  static String label(AppLocalizations l10n, String reactionType) {
    switch (reactionType) {
      case amen:
        return l10n.groupReactionAmen;
      case prayer:
        return l10n.groupReactionPrayer;
      case heart:
        return l10n.groupReactionHeart;
      default:
        return reactionType;
    }
  }
}

class GroupPost extends Equatable {
  final String id;
  final String groupId;
  final String authorUserId;
  final String? title;
  final String content;
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
  final bool isPinned;

  const GroupPost({
    required this.id,
    required this.groupId,
    required this.authorUserId,
    this.title,
    required this.content,
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
    this.isPinned = false,
  });

  String get displayAuthorName {
    final fullName = (authorFullName ?? '').trim();
    if (fullName.isNotEmpty) return fullName;

    final first = (authorFirstName ?? '').trim();
    if (first.isNotEmpty) return first;

    return 'Leier';
  }

  int reactionCountFor(String reactionType) {
    switch (reactionType) {
      case GroupPostReactionType.amen:
        return amenCount;
      case GroupPostReactionType.prayer:
        return prayerCount;
      case GroupPostReactionType.heart:
        return heartCount;
      default:
        return 0;
    }
  }

  GroupPost copyWith({
    String? id,
    String? groupId,
    String? authorUserId,
    String? title,
    bool clearTitle = false,
    String? content,
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
    bool? isPinned,
  }) {
    return GroupPost(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      authorUserId: authorUserId ?? this.authorUserId,
      title: clearTitle ? null : title ?? this.title,
      content: content ?? this.content,
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
      isPinned: isPinned ?? this.isPinned,
    );
  }

  factory GroupPost.fromJson(Map<String, dynamic> json) {
    return GroupPost(
      id: json['id'] ?? '',
      groupId: json['group_id'] ?? '',
      authorUserId: json['author_user_id'] ?? '',
      title: json['title'],
      content: json['content'] ?? '',
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
      isPinned: json['is_pinned'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
        id,
        groupId,
        authorUserId,
        title,
        content,
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
        isPinned,
      ];
}
