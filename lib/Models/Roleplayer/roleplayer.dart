import 'package:equatable/equatable.dart';

class Roleplayer extends Equatable {
  final String? id;
  final String? fullname;
  final String? title;
  final String? bio;
  final String? updatedAt;
  final String? createdAt;

  const Roleplayer({
    this.id,
    this.fullname,
    this.title,
    this.bio,
    this.updatedAt,
    this.createdAt
  });

  @override
  List<Object?> get props => [id, fullname, title, bio, updatedAt, createdAt];

  factory Roleplayer.fromJson(Map<String, dynamic> json) {
    return Roleplayer(
      id: json['id'] ?? '',
      fullname: json['fullname'] ?? '',
      title: json['title'] ?? '',
      bio: json['bio'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}