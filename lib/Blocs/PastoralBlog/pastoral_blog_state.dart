part of 'pastoral_blog_bloc.dart';

enum PastoralBlogStatus { initial, loading, success, error }

class PastoralBlogState extends Equatable {
  final PastoralBlogStatus status;
  final List<PastoralPost> posts;
  final bool isRefreshing;
  final bool isFeedActionInProgress;
  final String? message;
  final bool isErrorMessage;

  const PastoralBlogState({
    this.status = PastoralBlogStatus.initial,
    this.posts = const [],
    this.isRefreshing = false,
    this.isFeedActionInProgress = false,
    this.message,
    this.isErrorMessage = false,
  });

  PastoralBlogState copyWith({
    PastoralBlogStatus? status,
    List<PastoralPost>? posts,
    bool? isRefreshing,
    bool? isFeedActionInProgress,
    String? message,
    bool? isErrorMessage,
    bool clearMessage = false,
  }) {
    return PastoralBlogState(
      status: status ?? this.status,
      posts: posts ?? this.posts,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isFeedActionInProgress:
          isFeedActionInProgress ?? this.isFeedActionInProgress,
      message: clearMessage ? null : message ?? this.message,
      isErrorMessage: isErrorMessage ?? this.isErrorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        posts,
        isRefreshing,
        isFeedActionInProgress,
        message,
        isErrorMessage,
      ];
}
