import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lw_app/Blocs/Locale/locale_bloc.dart';
import 'package:lw_app/Blocs/Locale/locale_event.dart';
import 'package:lw_app/Services/Profile/profile_service.dart';
import 'package:lw_app/Models/User/user_profile.dart';
import 'dart:io';
import 'package:lw_app/Utils/cloudinary_helper.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final ProfileService _profileService = ProfileService();

  final LocaleBloc? _localeBloc;

  UserBloc({LocaleBloc? localeBloc})
      : _localeBloc = localeBloc,
        super(UserInitial()) {
    // Load user
    on<LoadUser>((event, emit) async {
      emit(UserLoading());
      try {
        UserProfile user = await _profileService.getUserProfile();
        _localeBloc?.add(HydrateLocaleFromProfileEvent(user.preferredLanguage));
        emit(UserSuccess(user: user));
      } catch (error) {
        emit(UserError(error.toString()));
      }
    });

    // Reset user
    on<ResetUser>((event, emit) {
      emit(UserInitial());
    });

    // Update user
    on<UpdateUser>((event, emit) async {
      emit(UserLoading());
      try {
        await _profileService.updateUser(
            firstName: event.firstName,
            lastName: event.lastName,
            address: event.address,
            isBaptized: event.isBaptized,
            isMember: event.isMember);

        UserProfile user = await _profileService.getUserProfile();
        _localeBloc?.add(HydrateLocaleFromProfileEvent(user.preferredLanguage));
        emit(UserUpdateSuccess());
        emit(UserSuccess(user: user));
      } catch (error) {
        emit(UserError(error.toString()));
      }
    });

    on<UploadProfilePicture>((event, emit) async {
      emit(UserLoading());
      try {
        Map<String, String> uploadResponse = await CloudinaryHelper.uploadImage(
            event.profileImageFile, 'lw-uploads');
        await _profileService.updateUserProfileImage(
            profileUrl: uploadResponse['url']!,
            profilePublicId: uploadResponse['public_id']!);
        UserProfile user = await _profileService.getUserProfile();
        _localeBloc?.add(HydrateLocaleFromProfileEvent(user.preferredLanguage));
        emit(UserProfilePictureSuccess());
        emit(UserSuccess(user: user));
      } catch (error) {
        emit(UserError(error.toString()));
      }
    });
  }
}
