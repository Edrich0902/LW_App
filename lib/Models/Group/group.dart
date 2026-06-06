import 'package:equatable/equatable.dart';
import 'package:lw_app/Models/Group/group_type.dart';

class Group extends Equatable {
  final String? id;
  final String title;
  final String description;
  final String type;
  final String? whatsappLink;
  final String? location;
  final String? bannerPublicId;
  final String? bannerUrl;
  final String? createdAt;
  final String? updatedAt;
  final int leaderCount;
  final int memberCount;
  final int pendingCount;
  final String? membershipStatus;
  final bool isLeader;

  const Group({
    this.id,
    required this.title,
    required this.description,
    required this.type,
    this.whatsappLink,
    this.location,
    this.bannerPublicId,
    this.bannerUrl,
    this.createdAt,
    this.updatedAt,
    this.leaderCount = 0,
    this.memberCount = 0,
    this.pendingCount = 0,
    this.membershipStatus,
    this.isLeader = false,
  });

  bool get isConnectGroup => type == GroupType.CONNECT;
  bool get isServeGroup => type == GroupType.SERVE;
  bool get hasWhatsappLink => (whatsappLink ?? '').trim().isNotEmpty;
  bool get hasLocation => (location ?? '').trim().isNotEmpty;
  bool get isPending => membershipStatus == 'pending';
  bool get isActiveMember => membershipStatus == 'active';

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        type,
        whatsappLink,
        location,
        bannerPublicId,
        bannerUrl,
        createdAt,
        updatedAt,
        leaderCount,
        memberCount,
        pendingCount,
        membershipStatus,
        isLeader,
      ];

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? GroupType.CONNECT,
      whatsappLink: json['whatsappLink'],
      location: json['location'],
      bannerPublicId: json['banner_public_id'],
      bannerUrl: json['banner_url'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      leaderCount: (json['leader_count'] as num?)?.toInt() ?? 0,
      memberCount: (json['member_count'] as num?)?.toInt() ?? 0,
      pendingCount: (json['pending_count'] as num?)?.toInt() ?? 0,
      membershipStatus: json['membership_status'],
      isLeader: json['isLeader'] ?? false,
    );
  }
}
