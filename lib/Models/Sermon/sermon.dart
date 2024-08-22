import 'package:equatable/equatable.dart';

class Sermon extends Equatable {
  final String? id;
  final String? title;
  final String? description;
  final String? link;
  final String? pastor;
  final String? createdAt;
  final String? updatedAt;

  const Sermon({
    this.id,
    this.title,
    this.description,
    this.link,
    this.pastor,
    this.createdAt,
    this.updatedAt
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    link,
    pastor,
    createdAt,
    updatedAt
  ];

  factory Sermon.fromJson(Map<String, dynamic> json) {
    return Sermon(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      link: json['link'] ?? '',
      pastor: json['pastor'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}