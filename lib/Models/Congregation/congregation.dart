import 'package:equatable/equatable.dart';

class Congregation extends Equatable {
  final String? id;
  final String name;
  final String? shortName;
  final String location;
  final String? streetAddress;
  final String? serviceStart;
  final List<dynamic>? servicesOffered;
  final String? createdAt;
  final String? updatedAt;
  final bool? isFavourite;

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
    this.isFavourite,
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
    updatedAt,
    isFavourite,
  ];

  factory Congregation.fromJson(Map<String, dynamic> json) {
    return Congregation(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      shortName: json['short_name'] ?? '',
      location: json['location'] ?? '',
      streetAddress: json['street_address'] ?? '',
      serviceStart: json['service_start'] ?? '',
      servicesOffered: json['services_offered'] ?? [],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      isFavourite: json['is_favourite'] ?? false,
    );
  }
}