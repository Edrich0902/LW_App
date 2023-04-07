part of 'user_bloc.dart';

abstract class UserState extends Equatable {
  const UserState();
}

class UserInitial extends UserState {
  @override
  List<Object> get props => [];
}

class UserLoading extends UserState {
  @override
  List<Object> get props => [];
}

class UserSuccess extends UserState {
  final UserProfile user;

  const UserSuccess({required this.user});

  @override
  List<Object?> get props => [user];
}

class UserUpdateSuccess extends UserState {
  @override
  List<Object> get props => [];
}

class UserError extends UserState {
  final String error;

  const UserError(this.error);

  @override
  List<Object> get props => [error];
}
