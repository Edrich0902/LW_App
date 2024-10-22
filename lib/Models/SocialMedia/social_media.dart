import 'package:equatable/equatable.dart';

class SocialMedia extends Equatable {
  final String? id;
  final String? title;
  final String? link;
  final String? type;
  final String? bannerPublicId;
  final String? bannerUrl;
  final String? createdAt;
  final String? updatedAt;

  const SocialMedia({
    this.id,
    this.title,
    this.link,
    this.type,
    this.bannerPublicId,
    this.bannerUrl,
    this.createdAt,
    this.updatedAt
  });

  @override
  List<Object?> get props => [
    id,
    title,
    link,
    type,
    bannerPublicId,
    bannerUrl,
    createdAt,
    updatedAt
  ];

  factory SocialMedia.fromJson(Map<String, dynamic> json) {
    return SocialMedia(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      link: json['link'] ?? '',
      type: json['type'] ?? '',
      bannerPublicId: json['banner_public_id'] ?? '',
      bannerUrl: json['banner_url'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}