import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lw_app/Models/SocialMedia/social_media.dart';
import 'package:lw_app/Services/SocialMedia/social_media_service.dart';

part 'social_media_event.dart';
part 'social_media_state.dart';

class SocialMediaBloc extends Bloc<SocialMediaEvent, SocialMediaState> {
  final SocialMediaService _socialMediaService = SocialMediaService();

  SocialMediaBloc() : super(SocialMediaInitial()) {
    on<LoadSocialMedia>((event, emit) async {
      emit(SocialMediaLoading());
      try {
        List<SocialMedia> socialMedia = await _socialMediaService.getSocialMedia();
        emit(SocialMediaSuccess(socialMedia: socialMedia));
      } catch (error) {
        emit(SocialMediaError(error.toString()));
      }
    });
  }
}
