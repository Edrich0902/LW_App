import 'package:equatable/equatable.dart';

class YoutubeVideo extends Equatable {
  final String title;
  final String authorName;
  final String authorUrl;
  final String type;
  final int height;
  final int width;
  final String version;
  final String providerName;
  final String providerUrl;
  final int thumbnailHeight;
  final int thumbnailWidth;
  final String thumbnailUrl;
  final String html;
  String? description;
  String? customAuthor;
  String? customTitle;
  String? youtubeLink;

  YoutubeVideo({
    required this.title,
    required this.authorName,
    required this.authorUrl,
    required this.type,
    required this.height,
    required this.width,
    required this.version,
    required this.providerName,
    required this.providerUrl,
    required this.thumbnailHeight,
    required this.thumbnailWidth,
    required this.thumbnailUrl,
    required this.html,
    this.description,
    this.customAuthor,
    this.customTitle,
    this.youtubeLink,
  });

  @override
  List<Object?> get props => [
    title,
    authorName,
    authorUrl,
    type,
    height,
    width,
    version,
    providerName,
    providerUrl,
    thumbnailHeight,
    thumbnailWidth,
    thumbnailUrl,
    html,
    youtubeLink,
    description,
    customAuthor,
    customTitle
  ];

  factory YoutubeVideo.fromJson(Map<String, dynamic> json) {
    return YoutubeVideo(
      title: json['title'] ?? '',
      authorName: json['author_name'] ?? '',
      authorUrl: json['author_url'] ?? '',
      type: json['type'] ?? '',
      height: json['height'] ?? 0,
      width: json['width'] ?? 0,
      version: json['version'] ?? '',
      providerName: json['provider_name'] ?? '',
      providerUrl: json['provider_url'] ?? '',
      thumbnailHeight: json['thumbnail_height'] ?? 0,
      thumbnailWidth: json['thumbnail_width'] ?? 0,
      thumbnailUrl: json['thumbnail_url'] ?? '',
      html: json['html'] ?? '',
    );
  }
}