import 'package:equatable/equatable.dart';

class Note extends Equatable {
  final String? id;
  final String? userId;
  final String? title;
  final String? content;
  final String? createdAt;

  const Note({
    this.id,
    this.userId, // foreign key
    this.title,
    this.content,
    this.createdAt
  });

  @override
  List<Object?> get props => [id, userId, title, content, createdAt];

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }
}