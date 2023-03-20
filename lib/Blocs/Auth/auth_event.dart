part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class EmailSignInEvent extends AuthEvent {
  final String email, password;
  const EmailSignInEvent(this.email, this.password);

  @override
  List<Object> get props => [email, password];
}

class EmailSignUpEvent extends AuthEvent {
  final String email, password;
  const EmailSignUpEvent(this.email, this.password);

  @override
  List<Object> get props => [email, password];
}

class SignOutEvent extends AuthEvent {
  const SignOutEvent();
}