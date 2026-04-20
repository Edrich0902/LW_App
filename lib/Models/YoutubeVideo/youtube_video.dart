import 'package:equatable/equatable.dart';

class YoutubeVideo extends Equatable {
  final String title;
  final String author_name;
  final String author_url;
  final String type;
  final int height;
  final int width;
  final String version;
  final String provider_name;
  final String provider_url;
  final int thumbnail_height;
  final int thumbnail_width;
  final String thumbnail_url;
  final String html;
  String? description;
  String? custom_author;
  String? custom_title;
  String? youtubeLink;

  YoutubeVideo({
    required this.title,
    required this.author_name,
    required this.author_url,
    required this.type,
    required this.height,
    required this.width,
    required this.version,
    required this.provider_name,
    required this.provider_url,
    required this.thumbnail_height,
    required this.thumbnail_width,
    required this.thumbnail_url,
    required this.html,
    this.description,
    this.custom_author,
    this.custom_title,
    this.youtubeLink,
  });

  @override
  List<Object?> get props => [
    title,
    author_name,
    author_url,
    type,
    height,
    width,
    version,
    provider_name,
    provider_url,
    thumbnail_height,
    thumbnail_width,
    thumbnail_url,
    html,
    youtubeLink,
    description,
    custom_author,
    custom_title
  ];

  factory YoutubeVideo.fromJson(Map<String, dynamic> json) {
    return YoutubeVideo(
      title: json['title'] ?? '',
      author_name: json['author_name'] ?? '',
      author_url: json['author_url'] ?? '',
      type: json['type'] ?? '',
      height: json['height'] ?? 0,
      width: json['width'] ?? 0,
      version: json['version'] ?? '',
      provider_name: json['provider_name'] ?? '',
      provider_url: json['provider_url'] ?? '',
      thumbnail_height: json['thumbnail_height'] ?? 0,
      thumbnail_width: json['thumbnail_width'] ?? 0,
      thumbnail_url: json['thumbnail_url'] ?? '',
      html: json['html'] ?? '',
    );
  }
}