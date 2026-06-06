import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String? id;
  final String firstName;
  final String lastName;
  final String? updatedAt;
  final String? createdAt;
  final String? role;
  final String? address;
  final bool? isBaptized;
  final bool? isMember;
  final String? profilePublicId;
  final String? profileUrl;
  final String? preferredLanguage;

  const UserProfile({
    this.id,
    required this.firstName,
    required this.lastName,
    this.updatedAt,
    this.createdAt,
    this.role,
    this.address,
    this.isBaptized,
    this.isMember,
    this.profilePublicId,
    this.profileUrl,
    this.preferredLanguage,
  });

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        updatedAt,
        createdAt,
        role,
        address,
        isBaptized,
        isMember,
        profilePublicId,
        profileUrl,
        preferredLanguage
      ];

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      createdAt: json['created_at'] ?? '',
      role: json['role'] ?? '',
      address: json['address'] ?? '',
      isBaptized: json['is_baptized'] ?? false,
      isMember: json['is_member'] ?? false,
      profilePublicId: json['profile_public_id'] ?? '',
      profileUrl: json['profile_url'] ?? '',
      preferredLanguage: json['preferred_language'] as String?,
    );
  }
}
