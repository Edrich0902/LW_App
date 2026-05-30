import 'package:equatable/equatable.dart';

enum FeedbackCategory {
  bugReport,
  featureRequest,
  improvement,
  other;

  String get value {
    switch (this) {
      case FeedbackCategory.bugReport:
        return 'bug_report';
      case FeedbackCategory.featureRequest:
        return 'feature_request';
      case FeedbackCategory.improvement:
        return 'improvement';
      case FeedbackCategory.other:
        return 'other';
    }
  }

  String get afrikaansLabel {
    switch (this) {
      case FeedbackCategory.bugReport:
        return 'Fout / Probleem';
      case FeedbackCategory.featureRequest:
        return 'Nuwe Funksie';
      case FeedbackCategory.improvement:
        return 'Verbetering';
      case FeedbackCategory.other:
        return 'Ander';
    }
  }

  static FeedbackCategory fromValue(String? value) {
    return FeedbackCategory.values.firstWhere(
      (category) => category.value == value,
      orElse: () => FeedbackCategory.other,
    );
  }
}

enum FeedbackStatus {
  open,
  underReview,
  planned,
  resolved,
  closed;

  String get value {
    switch (this) {
      case FeedbackStatus.open:
        return 'open';
      case FeedbackStatus.underReview:
        return 'under_review';
      case FeedbackStatus.planned:
        return 'planned';
      case FeedbackStatus.resolved:
        return 'resolved';
      case FeedbackStatus.closed:
        return 'closed';
    }
  }

  String get afrikaansLabel {
    switch (this) {
      case FeedbackStatus.open:
        return 'Oop';
      case FeedbackStatus.underReview:
        return 'Onder Oorsig';
      case FeedbackStatus.planned:
        return 'Beplan';
      case FeedbackStatus.resolved:
        return 'Opgelos';
      case FeedbackStatus.closed:
        return 'Gesluit';
    }
  }

  static FeedbackStatus fromValue(String? value) {
    return FeedbackStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => FeedbackStatus.open,
    );
  }
}

class AppFeedback extends Equatable {
  final String? id;
  final String? userId;
  final FeedbackCategory category;
  final String title;
  final String body;
  final FeedbackStatus status;
  final String? adminNote;
  final String? deviceOs;
  final String? deviceModel;
  final String? appVersion;
  final String? reviewedAt;
  final String? resolvedAt;
  final String? createdAt;
  final String? updatedAt;

  const AppFeedback({
    this.id,
    this.userId,
    required this.category,
    required this.title,
    required this.body,
    required this.status,
    this.adminNote,
    this.deviceOs,
    this.deviceModel,
    this.appVersion,
    this.reviewedAt,
    this.resolvedAt,
    this.createdAt,
    this.updatedAt,
  });

  AppFeedback copyWith({
    String? id,
    String? userId,
    FeedbackCategory? category,
    String? title,
    String? body,
    FeedbackStatus? status,
    String? adminNote,
    String? deviceOs,
    String? deviceModel,
    String? appVersion,
    String? reviewedAt,
    String? resolvedAt,
    String? createdAt,
    String? updatedAt,
  }) {
    return AppFeedback(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      category: category ?? this.category,
      title: title ?? this.title,
      body: body ?? this.body,
      status: status ?? this.status,
      adminNote: adminNote ?? this.adminNote,
      deviceOs: deviceOs ?? this.deviceOs,
      deviceModel: deviceModel ?? this.deviceModel,
      appVersion: appVersion ?? this.appVersion,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory AppFeedback.fromJson(Map<String, dynamic> json) {
    return AppFeedback(
      id: json['id']?.toString(),
      userId: json['user_id']?.toString(),
      category: FeedbackCategory.fromValue(json['category']?.toString()),
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      status: FeedbackStatus.fromValue(json['status']?.toString()),
      adminNote: json['admin_note']?.toString(),
      deviceOs: json['device_os']?.toString(),
      deviceModel: json['device_model']?.toString(),
      appVersion: json['app_version']?.toString(),
      reviewedAt: json['reviewed_at']?.toString(),
      resolvedAt: json['resolved_at']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        category,
        title,
        body,
        status,
        adminNote,
        deviceOs,
        deviceModel,
        appVersion,
        reviewedAt,
        resolvedAt,
        createdAt,
        updatedAt,
      ];
}
