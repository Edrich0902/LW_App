part of 'social_media_bloc.dart';

abstract class SocialMediaEvent extends Equatable {
  const SocialMediaEvent();

  @override
  List<Object> get props => [];
}

class LoadSocialMedia extends SocialMediaEvent {
  const LoadSocialMedia();

  @override
  List<Object> get props => [];
}
