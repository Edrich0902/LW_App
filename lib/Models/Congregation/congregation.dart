import 'package:equatable/equatable.dart';

class Congregation extends Equatable {
  final String? id;
  final String name;
  final String? shortName;
  final String location;
  final String? streetAddress;
  final String? serviceStart;
  final dynamic? servicesOffered;
  final String? createdAt;
  final String? updatedAt;

  const Congregation({
    this.id,
    required this.name,
    this.shortName,
    required this.location,
    this.streetAddress,
    this.serviceStart,
    this.servicesOffered,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    shortName,
    location,
    streetAddress,
    serviceStart,
    servicesOffered,
    createdAt,
    updatedAt
  ];

  factory Congregation.fromJson(Map<String, dynamic> json) {
    return Congregation(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      shortName: json['shortName'] ?? '',
      location: json['location'] ?? '',
      streetAddress: json['streetAddress'] ?? '',
      serviceStart: json['serviceStart'] ?? '',
      servicesOffered: json['servicesOffered'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}