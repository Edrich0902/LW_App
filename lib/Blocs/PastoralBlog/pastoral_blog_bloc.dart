import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lw_app/Models/PastoralBlog/pastoral_post.dart';
import 'package:lw_app/Services/PastoralBlog/pastoral_blog_service.dart';

part 'pastoral_blog_event.dart';
part 'pastoral_blog_state.dart';

class PastoralBlogBloc extends Bloc<PastoralBlogEvent, PastoralBlogState> {
  final PastoralBlogService _service = PastoralBlogService();

  PastoralBlogBloc() : super(const PastoralBlogState()) {
    on<LoadPastoralBlog>(_onLoad);
    on<RefreshPastoralBlog>(_onRefresh);
    on<TogglePastoralPostReaction>(_onToggleReaction);
    on<ClearPastoralBlogMessage>(_onClearMessage);
  }

  Future<void> _onLoad(
    LoadPastoralBlog event,
    Emitter<PastoralBlogState> emit,
  ) async {
    emit(state.copyWith(status: PastoralBlogStatus.loading));
    await _loadPosts(emit);
  }

  Future<void> _onRefresh(
    RefreshPastoralBlog event,
    Emitter<PastoralBlogState> emit,
  ) async {
    emit(state.copyWith(isRefreshing: true));
    await _loadPosts(emit);
  }

  Future<void> _loadPosts(Emitter<PastoralBlogState> emit) async {
    try {
      final posts = await _service.getPastoralPosts();
      emit(state.copyWith(
        status: PastoralBlogStatus.success,
        posts: posts,
        isRefreshing: false,
        isFeedActionInProgress: false,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: PastoralBlogStatus.error,
        isRefreshing: false,
        isFeedActionInProgress: false,
        message: error.toString(),
        isErrorMessage: true,
      ));
    }
  }

  Future<void> _onToggleReaction(
    TogglePastoralPostReaction event,
    Emitter<PastoralBlogState> emit,
  ) async {
    final originalPosts = state.posts;
    final currentPost = originalPosts.where((p) => p.id == event.post.id);
    if (currentPost.isEmpty) return;

    final post = currentPost.first;
    final nextReaction = post.currentUserReaction == event.reactionType
        ? null
        : event.reactionType;

    emit(state.copyWith(
      posts: originalPosts
          .map((item) => item.id == post.id
              ? _applyReactionPreview(item, nextReaction)
              : item)
          .toList(),
      isFeedActionInProgress: true,
      message: null,
    ));

    try {
      if (nextReaction == null) {
        await _service.removePastoralPostReaction(post.id);
      } else {
        await _service.setPastoralPostReaction(
          postId: post.id,
          reactionType: nextReaction,
        );
      }

      await _loadPosts(emit);
    } catch (error) {
      emit(state.copyWith(
        posts: originalPosts,
        isFeedActionInProgress: false,
        message: error.toString(),
        isErrorMessage: true,
      ));
    }
  }

  void _onClearMessage(
    ClearPastoralBlogMessage event,
    Emitter<PastoralBlogState> emit,
  ) {
    emit(state.copyWith(clearMessage: true, isErrorMessage: false));
  }

  PastoralPost _applyReactionPreview(PastoralPost post, String? nextReaction) {
    var amenCount = post.amenCount;
    var prayerCount = post.prayerCount;
    var heartCount = post.heartCount;

    void decrement(String? reaction) {
      switch (reaction) {
        case PastoralPostReactionType.amen:
          amenCount = amenCount > 0 ? amenCount - 1 : 0;
          break;
        case PastoralPostReactionType.prayer:
          prayerCount = prayerCount > 0 ? prayerCount - 1 : 0;
          break;
        case PastoralPostReactionType.heart:
          heartCount = heartCount > 0 ? heartCount - 1 : 0;
          break;
      }
    }

    void increment(String? reaction) {
      switch (reaction) {
        case PastoralPostReactionType.amen:
          amenCount += 1;
          break;
        case PastoralPostReactionType.prayer:
          prayerCount += 1;
          break;
        case PastoralPostReactionType.heart:
          heartCount += 1;
          break;
      }
    }

    decrement(post.currentUserReaction);
    increment(nextReaction);

    return post.copyWith(
      amenCount: amenCount,
      prayerCount: prayerCount,
      heartCount: heartCount,
      reactionCount: amenCount + prayerCount + heartCount,
      currentUserReaction: nextReaction,
      clearCurrentUserReaction: nextReaction == null,
    );
  }
}
