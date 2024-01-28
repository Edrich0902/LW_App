import 'package:equatable/equatable.dart';

class MetaData extends Equatable {
  final String? id;
  final String? key;
  final String? title;
  final String? content;
  final String? createdAt;

  const MetaData({
    this.id,
    this.key,
    this.title,
    this.content,
    this.createdAt
  });

  @override
  List<Object?> get props => [id, key, title, content, createdAt];

  factory MetaData.fromJson(Map<String, dynamic> json) {
    return MetaData(
      id: json['id'] ?? '',
      key: json['key'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }
}