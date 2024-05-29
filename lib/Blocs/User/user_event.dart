part of 'user_bloc.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class LoadUser extends UserEvent {
  const LoadUser();

  @override
  List<Object> get props => [];
}

class UpdateUser extends UserEvent {
  final String firstName;
  final String lastName;
  final String? address;
  final bool? isBaptized;
  final bool? isMember;

  const UpdateUser({
    required this.firstName,
    required this.lastName,
    this.address,
    this.isBaptized,
    this.isMember,
  });

  @override
  List<Object?> get props => [firstName, lastName, address, isBaptized, isMember];
}
