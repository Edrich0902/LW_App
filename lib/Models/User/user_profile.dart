import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String? id;
  final String firstName;
  final String lastName;
  final String? updatedAt;
  final String? createdAt;
  final String? role;

  const UserProfile({
    this.id,
    required this.firstName,
    required this.lastName,
    this.updatedAt,
    this.createdAt,
    this.role,
  });

  @override
  List<Object?> get props => [id, firstName, lastName, updatedAt, createdAt, role];

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      createdAt: json['created_at'] ?? '',
      role: json['role'] ?? '',
    );
  }
}
