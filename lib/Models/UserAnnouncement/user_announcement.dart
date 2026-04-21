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
    final announcement = json['announcements'] ?? {};

    return UserAnnouncement(
      id: json['id'] ?? '',
      title: announcement['title'] ?? '',
      body: announcement['body'] ?? '',
      imageUrl: announcement['image_url'],
      imagePublicId: announcement['image_public_id'],
      createdAt: announcement['created_at'] ?? '',
      updatedAt: announcement['updated_at'] ?? '',
      isRead: json['is_read'] ?? false,
    );
  }
}