part of 'sermons_bloc.dart';

abstract class SermonsState extends Equatable {
  const SermonsState();
}

class SermonsInitial extends SermonsState {
  @override
  List<Object> get props => [];
}

class SermonsLoading extends SermonsState {
  @override
  List<Object> get props => [];
}

class SermonsSuccess extends SermonsState {
  final List<Sermon> sermons;
  final List<YoutubeVideo> youtubeVideos;

  const SermonsSuccess({required this.sermons, required this.youtubeVideos});

  @override
  List<Object?> get props => [sermons, youtubeVideos];
}

class SermonsError extends SermonsState {
  final String error;

  const SermonsError(this.error);

  @override
  List<Object> get props => [error];
}