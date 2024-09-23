import 'package:equatable/equatable.dart';

class Group extends Equatable {
  final String? id;
  final String title;
  final String description;
  final String type;
  final String whatsappLink;
  final String location;
  final String? createdAt;
  final String? updatedAt;

  const Group({
    this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.whatsappLink,
    required this.location,
    this.createdAt,
    this.updatedAt
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    type,
    whatsappLink,
    location,
    createdAt,
    updatedAt,
  ];

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? '',
      whatsappLink: json['whatsappLink'] ?? '',
      location: json['location'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}