import 'package:equatable/equatable.dart';

class Event extends Equatable {
  final String? id;
  final String title;
  final String description;
  final String time;
  final String type;
  final String day;
  final String category;
  final String? startDate;
  final String? endDate;
  final String? createdAt;
  final String? updatedAt;

  const Event({
    this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.type,
    required this.day,
    required this.category,
    this.startDate,
    this.endDate,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    time,
    type,
    day,
    category,
    startDate,
    endDate,
    createdAt,
    updatedAt,
  ];

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      time: json['time'] ?? '',
      type: json['type'] ?? '',
      day: json['day'] ?? '',
      category: json['category'] ?? '',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}