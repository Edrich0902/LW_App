part of 'social_media_bloc.dart';

abstract class SocialMediaState extends Equatable {
  const SocialMediaState();
}

class SocialMediaInitial extends SocialMediaState {
  @override
  List<Object> get props => [];
}

class SocialMediaLoading extends SocialMediaState {
  @override
  List<Object> get props => [];
}

class SocialMediaSuccess extends SocialMediaState {
  final List<SocialMedia> socialMedia;

  const SocialMediaSuccess({required this.socialMedia});

  @override
  List<Object?> get props => [socialMedia];
}

class SocialMediaError extends SocialMediaState {
  final String error;

  const SocialMediaError(this.error);

  @override
  List<Object> get props => [error];
}
