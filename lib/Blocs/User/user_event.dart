part of 'user_bloc.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object> get props => [];
}

class LoadUser extends UserEvent {
  const LoadUser();

  @override
  List<Object> get props => [];
}

class UpdateUser extends UserEvent {
  final String firstName;
  final String lastName;

  const UpdateUser(this.firstName, this.lastName);

  @override
  List<Object> get props => [firstName, lastName];
}
