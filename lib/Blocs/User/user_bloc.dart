import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:lw_app/Services/Profile/profile_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final ProfileService _profileService = ProfileService();
  UserBloc() : super(UserInitial()) {
    // Load user
    on<LoadUser>((event, emit) async {
      emit(UserLoading());
      try {
        User? user = _profileService.getUser();
        emit(UserSuccess(user: user));
      } catch (error) {
        emit(UserError(error.toString()));
      }
    });

    // Update user
    on<UpdateUser>((event, emit) async {
      emit(UserLoading());
      try {
        User user = await _profileService.updateUser(
          firstName: event.firstName,
          lastName: event.lastName,
        );
        emit(UserSuccess(user: user));
      } catch (error) {
        emit(UserError(error.toString()));
      }
    });
  }
}
