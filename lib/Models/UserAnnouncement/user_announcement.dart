import 'package:equatable/equatable.dart';

class UserAnnouncement extends Equatable {
  final String? id;
  final bool? isRead;
  final String title;
  final String body;
  final String? imageUrl;
  final String? imagePublicId;
  final String? createdAt;
  final String? updatedAt;

  const UserAnnouncement({
    this.id,
    required this.title,
    required this.body,
    this.imageUrl,
    this.imagePublicId,
    this.createdAt,
    this.updatedAt,
    this.isRead,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    body,
    imageUrl,
    imagePublicId,
    createdAt,
    updatedAt,
    isRead,
  ];

  factory UserAnnouncement.fromJson(Map<String, dynamic> json) {
    return UserAnnouncement(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      imageUrl: json['image_url'] ?? null,
      imagePublicId: json['image_public_id'] ?? null,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      isRead: json['is_read'] ?? false,
    );
  }
}