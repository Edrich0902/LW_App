import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lw_app/Services/Auth/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService = AuthService();

  AuthBloc() : super(AuthInitial()) {
    //Sign Up Event
    on<EmailSignUpEvent>((event, emit) async {
      emit(AuthLoadingState());
      try {
        final AuthResponse response = await _authService.signUpWithEmail(
          email: event.email,
          password: event.password
        );

        // Creates the initial user profile linked with this auth profile
        await _authService.createInitialProfile(userId: response?.user?.id);

        emit(AuthSuccessState());
      } catch (error) {
        emit(AuthErrorState(error.toString()));
      }
    });

    //Sign In Event
    on<EmailSignInEvent>((event, emit) async {
      emit(AuthLoadingState());
      try {
        await _authService.signInWithEmail(
            email: event.email,
            password: event.password
        );

        emit(AuthSuccessState());
      } catch (error) {
        emit(AuthErrorState(error.toString()));
      }
    });

    //Sign Out Event
    on<SignOutEvent>((event, emit) async {
      try {
        await _authService.signOut();
        emit(UnAuthedState());
      } catch (error) {
        emit(AuthErrorState(error.toString()));
      }
    });
  }
}
