import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lw_app/Services/Auth/auth_service.dart';
import 'package:lw_app/Utils/cloudinary_helper.dart';
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
        String? profileUrl;
        String? profilePublicId;

        // Upload image to Cloudinary if provided
        if (event.imageFile != null) {
          final uploadResult = await CloudinaryHelper.uploadImage(
            event.imageFile!,
            'user_profiles',
          );
          profileUrl = uploadResult['url'];
          profilePublicId = uploadResult['public_id'];
        }

        final AuthResponse response = await _authService.signUpWithEmail(
          email: event.email,
          password: event.password,
        );

        // Creates the initial user profile with all details
        await _authService.createInitialProfile(
          userId: response.user?.id,
          firstName: event.firstName,
          lastName: event.lastName,
          profileUrl: profileUrl,
          profilePublicId: profilePublicId,
        );

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
        emit(const UnAuthedState());
      } catch (error) {
        emit(AuthErrorState(error.toString()));
      }
    });
  }
}
