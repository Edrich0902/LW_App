import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lw_app/Services/Profile/profile_service.dart';
import 'package:lw_app/Models/User/user_profile.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final ProfileService _profileService = ProfileService();
  UserBloc() : super(UserInitial()) {
    // Load user
    on<LoadUser>((event, emit) async {
      emit(UserLoading());
      try {
        UserProfile user = await _profileService.getUserProfile();
        emit(UserSuccess(user: user));
      } catch (error) {
        emit(UserError(error.toString()));
      }
    });

    // Update user
    on<UpdateUser>((event, emit) async {
      emit(UserLoading());
      try {
        await _profileService.updateUser(
          firstName: event.firstName,
          lastName: event.lastName,
        );

        UserProfile user = await _profileService.getUserProfile();
        emit(UserUpdateSuccess());
        emit(UserSuccess(user: user));
      } catch (error) {
        emit(UserError(error.toString()));
      }
    });
  }
}
