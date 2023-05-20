import 'package:equatable/equatable.dart';

class Note extends Equatable {
  final String? id;
  final String? title;
  final String? note;
  final String userId;
  final String? createdAt;
  final String? updatedAt;

  const Note({
    this.id,
    this.title,
    this.note,
    required this.userId,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => {
    id,
    title,
    note,
    userId,
    createdAt,
    updatedAt,
  };

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      note: json['note'] ?? '',
      userId: json['user_id'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}