part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class EmailSignInEvent extends AuthEvent {
  final String email, password;
  const EmailSignInEvent(this.email, this.password);

  @override
  List<Object> get props => [email, password];
}

class EmailSignUpEvent extends AuthEvent {
  final String email, password;
  final String firstName;
  final String lastName;
  final File? imageFile;

  const EmailSignUpEvent({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    this.imageFile,
  });

  @override
  List<Object?> get props => [email, password, firstName, lastName, imageFile];
}

class SignOutEvent extends AuthEvent {
  const SignOutEvent();
}

class SendPasswordResetEmailEvent extends AuthEvent {
  final String email;
  const SendPasswordResetEmailEvent(this.email);

  @override
  List<Object> get props => [email];
}

class UpdatePasswordEvent extends AuthEvent {
  final String password;
  const UpdatePasswordEvent(this.password);

  @override
  List<Object> get props => [password];
}