part of 'pastoral_blog_bloc.dart';

abstract class PastoralBlogEvent extends Equatable {
  const PastoralBlogEvent();

  @override
  List<Object?> get props => [];
}

class LoadPastoralBlog extends PastoralBlogEvent {
  const LoadPastoralBlog();
}

class RefreshPastoralBlog extends PastoralBlogEvent {
  const RefreshPastoralBlog();
}

class TogglePastoralPostReaction extends PastoralBlogEvent {
  final PastoralPost post;
  final String reactionType;

  const TogglePastoralPostReaction({
    required this.post,
    required this.reactionType,
  });

  @override
  List<Object?> get props => [post, reactionType];
}

class ClearPastoralBlogMessage extends PastoralBlogEvent {
  const ClearPastoralBlogMessage();
}
