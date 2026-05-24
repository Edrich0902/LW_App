import 'package:equatable/equatable.dart';

class Note extends Equatable {
  final String? id;
  final String? userId;
  final String? title;
  final String? content;
  final String? createdAt;
  final String? updatedAt;

  const Note({
    this.id,
    this.userId, // foreign key
    this.title,
    this.content,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [id, userId, title, content, createdAt, updatedAt];

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}