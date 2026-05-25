import 'package:equatable/equatable.dart';
import 'package:lw_app/Models/Event/rsvp_status.dart';

class Event extends Equatable {
  final String? id;
  final String title;
  final String description;
  final String time;
  final String type;
  final String day;
  final String category;
  final String? startDate;
  final String? endDate;
  final String? bannerPublicId;
  final String? bannerUrl;
  final String? createdAt;
  final String? updatedAt;
  final int attendingCount;
  final int interestedCount;
  final int notAttendingCount;
  final RsvpStatus? userRsvpStatus;
  final int? capacity;

  const Event({
    this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.type,
    required this.day,
    required this.category,
    this.startDate,
    this.endDate,
    this.bannerPublicId,
    this.bannerUrl,
    this.createdAt,
    this.updatedAt,
    this.attendingCount = 0,
    this.interestedCount = 0,
    this.notAttendingCount = 0,
    this.userRsvpStatus,
    this.capacity,
  });

  Event copyWith({
    String? id,
    String? title,
    String? description,
    String? time,
    String? type,
    String? day,
    String? category,
    String? startDate,
    String? endDate,
    String? bannerPublicId,
    String? bannerUrl,
    String? createdAt,
    String? updatedAt,
    int? attendingCount,
    int? interestedCount,
    int? notAttendingCount,
    RsvpStatus? Function()? userRsvpStatus,
    int? capacity,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      time: time ?? this.time,
      type: type ?? this.type,
      day: day ?? this.day,
      category: category ?? this.category,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      bannerPublicId: bannerPublicId ?? this.bannerPublicId,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      attendingCount: attendingCount ?? this.attendingCount,
      interestedCount: interestedCount ?? this.interestedCount,
      notAttendingCount: notAttendingCount ?? this.notAttendingCount,
      userRsvpStatus:
          userRsvpStatus != null ? userRsvpStatus() : this.userRsvpStatus,
      capacity: capacity ?? this.capacity,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        time,
        type,
        day,
        category,
        startDate,
        endDate,
        bannerPublicId,
        bannerUrl,
        createdAt,
        updatedAt,
        attendingCount,
        interestedCount,
        notAttendingCount,
        userRsvpStatus,
        capacity,
      ];

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      time: json['time'] ?? '',
      type: json['type'] ?? '',
      day: json['day'] ?? '',
      category: json['category'] ?? '',
      startDate: json['start_date'],
      endDate: json['end_date'],
      bannerPublicId: json['banner_public_id'],
      bannerUrl: json['banner_url'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      attendingCount: (json['attending_count'] as num?)?.toInt() ?? 0,
      interestedCount: (json['interested_count'] as num?)?.toInt() ?? 0,
      notAttendingCount: (json['not_attending_count'] as num?)?.toInt() ?? 0,
      userRsvpStatus:
          RsvpStatus.fromValue(json['user_rsvp_status']?.toString()),
      capacity: (json['capacity'] as num?)?.toInt(),
    );
  }
}
