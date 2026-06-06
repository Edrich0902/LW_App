import 'package:equatable/equatable.dart';

class GroupMembershipRole {
  static const String leader = 'leader';
  static const String member = 'member';
}

class GroupMembershipStatus {
  static const String pending = 'pending';
  static const String active = 'active';
  static const String declined = 'declined';
  static const String left = 'left';
  static const String removed = 'removed';
}

class GroupMembership extends Equatable {
  final String id;
  final String groupId;
  final String userId;
  final String role;
  final String status;
  final String? requestedAt;
  final String? respondedAt;
  final String? respondedBy;
  final String? joinedAt;
  final String? firstName;
  final String? lastName;
  final String? fullName;
  final String? email;
  final String? profilePublicId;
  final String? profileUrl;
  final String? respondedByFirstName;
  final String? respondedByLastName;
  final String? respondedByFullName;

  const GroupMembership({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.role,
    required this.status,
    this.requestedAt,
    this.respondedAt,
    this.respondedBy,
    this.joinedAt,
    this.firstName,
    this.lastName,
    this.fullName,
    this.email,
    this.profilePublicId,
    this.profileUrl,
    this.respondedByFirstName,
    this.respondedByLastName,
    this.respondedByFullName,
  });

  bool get isLeader => role == GroupMembershipRole.leader;
  bool get isPending => status == GroupMembershipStatus.pending;
  bool get isActive => status == GroupMembershipStatus.active;

  @override
  List<Object?> get props => [
        id,
        groupId,
        userId,
        role,
        status,
        requestedAt,
        respondedAt,
        respondedBy,
        joinedAt,
        firstName,
        lastName,
        fullName,
        email,
        profilePublicId,
        profileUrl,
        respondedByFirstName,
        respondedByLastName,
        respondedByFullName,
      ];

  factory GroupMembership.fromJson(Map<String, dynamic> json) {
    return GroupMembership(
      id: json['id'] ?? '',
      groupId: json['group_id'] ?? '',
      userId: json['user_id'] ?? '',
      role: json['role'] ?? '',
      status: json['status'] ?? '',
      requestedAt: json['requested_at'],
      respondedAt: json['responded_at'],
      respondedBy: json['responded_by'],
      joinedAt: json['joined_at'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      fullName: json['full_name'],
      email: json['email'],
      profilePublicId: json['profile_public_id'],
      profileUrl: json['profile_url'],
      respondedByFirstName: json['responded_by_first_name'],
      respondedByLastName: json['responded_by_last_name'],
      respondedByFullName: json['responded_by_full_name'],
    );
  }
}
