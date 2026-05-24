import 'package:equatable/equatable.dart';

enum PrayerRequestStatus {
  pending,
  approved,
  rejected,
  resolved;

  String get value => name;

  String get afrikaansLabel {
    switch (this) {
      case PrayerRequestStatus.pending:
        return 'Wag vir goedkeuring';
      case PrayerRequestStatus.approved:
        return 'Goedgekeur';
      case PrayerRequestStatus.rejected:
        return 'Afgekeur';
      case PrayerRequestStatus.resolved:
        return 'Afgehandel';
    }
  }

  static PrayerRequestStatus fromValue(String? value) {
    return PrayerRequestStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => PrayerRequestStatus.pending,
    );
  }
}

enum PrayerCategory {
  healing,
  family,
  provision,
  guidance,
  spiritualGrowth,
  thanksgiving,
  other;

  String get value {
    switch (this) {
      case PrayerCategory.healing:
        return 'healing';
      case PrayerCategory.family:
        return 'family';
      case PrayerCategory.provision:
        return 'provision';
      case PrayerCategory.guidance:
        return 'guidance';
      case PrayerCategory.spiritualGrowth:
        return 'spiritual_growth';
      case PrayerCategory.thanksgiving:
        return 'thanksgiving';
      case PrayerCategory.other:
        return 'other';
    }
  }

  String get afrikaansLabel {
    switch (this) {
      case PrayerCategory.healing:
        return 'Genesing';
      case PrayerCategory.family:
        return 'Familie';
      case PrayerCategory.provision:
        return 'Voorsiening';
      case PrayerCategory.guidance:
        return 'Leiding';
      case PrayerCategory.spiritualGrowth:
        return 'Geestelike Groei';
      case PrayerCategory.thanksgiving:
        return 'Danksegging';
      case PrayerCategory.other:
        return 'Ander';
    }
  }

  static PrayerCategory fromValue(String? value) {
    return PrayerCategory.values.firstWhere(
      (category) => category.value == value,
      orElse: () => PrayerCategory.other,
    );
  }
}

class PrayerRequest extends Equatable {
  final String? id;
  final String? userId;
  final PrayerCategory category;
  final String body;
  final bool isAnonymous;
  final PrayerRequestStatus status;
  final String? displayName;
  final String? moderationNote;
  final String? approvedAt;
  final String? rejectedAt;
  final String? resolvedAt;
  final String? createdAt;
  final String? updatedAt;
  final int reactionCount;
  final bool hasReacted;

  const PrayerRequest({
    this.id,
    this.userId,
    required this.category,
    required this.body,
    required this.isAnonymous,
    required this.status,
    this.displayName,
    this.moderationNote,
    this.approvedAt,
    this.rejectedAt,
    this.resolvedAt,
    this.createdAt,
    this.updatedAt,
    this.reactionCount = 0,
    this.hasReacted = false,
  });

  PrayerRequest copyWith({
    String? id,
    String? userId,
    PrayerCategory? category,
    String? body,
    bool? isAnonymous,
    PrayerRequestStatus? status,
    String? displayName,
    String? moderationNote,
    String? approvedAt,
    String? rejectedAt,
    String? resolvedAt,
    String? createdAt,
    String? updatedAt,
    int? reactionCount,
    bool? hasReacted,
  }) {
    return PrayerRequest(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      category: category ?? this.category,
      body: body ?? this.body,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      status: status ?? this.status,
      displayName: displayName ?? this.displayName,
      moderationNote: moderationNote ?? this.moderationNote,
      approvedAt: approvedAt ?? this.approvedAt,
      rejectedAt: rejectedAt ?? this.rejectedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      reactionCount: reactionCount ?? this.reactionCount,
      hasReacted: hasReacted ?? this.hasReacted,
    );
  }

  factory PrayerRequest.fromJson(Map<String, dynamic> json) {
    return PrayerRequest(
      id: json['id']?.toString(),
      userId: json['user_id']?.toString(),
      category: PrayerCategory.fromValue(json['category']?.toString()),
      body: json['body']?.toString() ?? '',
      isAnonymous: json['is_anonymous'] == true,
      status: PrayerRequestStatus.fromValue(json['status']?.toString()),
      displayName: json['display_name']?.toString(),
      moderationNote: json['moderation_note']?.toString(),
      approvedAt: json['approved_at']?.toString(),
      rejectedAt: json['rejected_at']?.toString(),
      resolvedAt: json['resolved_at']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      reactionCount: (json['reaction_count'] as num?)?.toInt() ?? 0,
      hasReacted: json['has_reacted'] == true,
    );
  }

  Map<String, dynamic> toCreateJson({required String userId}) {
    return {
      'user_id': userId,
      'category': category.value,
      'body': body,
      'is_anonymous': isAnonymous,
      'status': PrayerRequestStatus.pending.value,
    };
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        category,
        body,
        isAnonymous,
        status,
        displayName,
        moderationNote,
        approvedAt,
        rejectedAt,
        resolvedAt,
        createdAt,
        updatedAt,
        reactionCount,
        hasReacted,
      ];
}
