import 'package:equatable/equatable.dart';

class Note extends Equatable {
  final String? id;
  final String? user_id;
  final String? title;
  final String? content;
  final String? createdAt;

  const Note({
    this.id,
    this.user_id, // foreign key
    this.title,
    this.content,
    this.createdAt
  });

  @override
  List<Object?> get props => [id, user_id, title, content, createdAt];

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] ?? '',
      user_id: json['user_id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }
}