import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lw_app/Models/Group/group.dart';
import 'package:lw_app/Models/Group/group_membership.dart';
import 'package:lw_app/Models/Group/group_post.dart';
import 'package:lw_app/Services/Groups/groups_service.dart';
import 'package:lw_app/Utils/lwp_i18n.dart';

part 'group_detail_event.dart';
part 'group_detail_state.dart';

class GroupDetailBloc extends Bloc<GroupDetailEvent, GroupDetailState> {
  final GroupService _groupService = GroupService();

  GroupDetailBloc() : super(const GroupDetailState()) {
    on<LoadGroupDetail>(_onLoadGroupDetail);
    on<RefreshGroupDetail>(_onRefreshGroupDetail);
    on<RequestToJoinGroup>(_onRequestToJoinGroup);
    on<CancelGroupJoinRequest>(_onCancelGroupJoinRequest);
    on<LeaveGroup>(_onLeaveGroup);
    on<ApproveGroupMembership>(_onApproveGroupMembership);
    on<DeclineGroupMembership>(_onDeclineGroupMembership);
    on<RemoveGroupMember>(_onRemoveGroupMember);
    on<UpdateGroupFromLeader>(_onUpdateGroupFromLeader);
    on<CreateGroupPost>(_onCreateGroupPost);
    on<UpdateExistingGroupPost>(_onUpdateExistingGroupPost);
    on<DeleteGroupPost>(_onDeleteGroupPost);
    on<ToggleGroupPostReaction>(_onToggleGroupPostReaction);
    on<TogglePinPost>(_onTogglePinPost);
    on<ClearGroupDetailMessage>(_onClearGroupDetailMessage);
  }

  Future<void> _onLoadGroupDetail(
    LoadGroupDetail event,
    Emitter<GroupDetailState> emit,
  ) async {
    emit(state.copyWith(status: GroupDetailStatus.loading, clearMessage: true));
    await _loadGroupDetail(event.groupId, emit);
  }

  Future<void> _onRefreshGroupDetail(
    RefreshGroupDetail event,
    Emitter<GroupDetailState> emit,
  ) async {
    emit(state.copyWith(isRefreshing: true, clearMessage: true));
    await _loadGroupDetail(event.groupId, emit);
  }

  Future<void> _onRequestToJoinGroup(
    RequestToJoinGroup event,
    Emitter<GroupDetailState> emit,
  ) async {
    await _runAction(
      emit,
      event.groupId,
      successMessage:
          LwpI18n.current?.groupActionRequestSent ?? 'Request sent.',
      action: () => _groupService.requestGroupJoin(event.groupId),
    );
  }

  Future<void> _onCancelGroupJoinRequest(
    CancelGroupJoinRequest event,
    Emitter<GroupDetailState> emit,
  ) async {
    await _runAction(
      emit,
      event.groupId,
      successMessage:
          LwpI18n.current?.groupActionRequestCancelled ?? 'Request cancelled.',
      action: () => _groupService.cancelGroupJoinRequest(event.groupId),
    );
  }

  Future<void> _onLeaveGroup(
    LeaveGroup event,
    Emitter<GroupDetailState> emit,
  ) async {
    await _runAction(
      emit,
      event.groupId,
      successMessage: LwpI18n.current?.groupActionLeft ?? 'You left the group.',
      action: () => _groupService.leaveGroup(event.groupId),
    );
  }

  Future<void> _onApproveGroupMembership(
    ApproveGroupMembership event,
    Emitter<GroupDetailState> emit,
  ) async {
    await _runAction(
      emit,
      event.groupId,
      successMessage:
          LwpI18n.current?.groupActionApproved ?? 'Request approved.',
      action: () =>
          _groupService.approveGroupMembership(event.groupId, event.userId),
    );
  }

  Future<void> _onDeclineGroupMembership(
    DeclineGroupMembership event,
    Emitter<GroupDetailState> emit,
  ) async {
    await _runAction(
      emit,
      event.groupId,
      successMessage:
          LwpI18n.current?.groupActionDeclined ?? 'Request declined.',
      action: () =>
          _groupService.declineGroupMembership(event.groupId, event.userId),
    );
  }

  Future<void> _onRemoveGroupMember(
    RemoveGroupMember event,
    Emitter<GroupDetailState> emit,
  ) async {
    await _runAction(
      emit,
      event.groupId,
      successMessage:
          LwpI18n.current?.groupActionMemberRemoved ?? 'Member removed.',
      action: () =>
          _groupService.removeGroupMember(event.groupId, event.userId),
    );
  }

  Future<void> _onUpdateGroupFromLeader(
    UpdateGroupFromLeader event,
    Emitter<GroupDetailState> emit,
  ) async {
    await _runAction(
      emit,
      event.groupId,
      successMessage: LwpI18n.current?.groupActionUpdated ?? 'Group updated.',
      action: () => _groupService.updateGroupFromLeader(
        groupId: event.groupId,
        title: event.title,
        description: event.description,
        whatsappLink: event.whatsappLink,
        location: event.location,
        bannerUrl: event.bannerUrl,
        bannerPublicId: event.bannerPublicId,
      ),
    );
  }

  Future<void> _onCreateGroupPost(
    CreateGroupPost event,
    Emitter<GroupDetailState> emit,
  ) async {
    await _runFeedAction(
      emit,
      event.groupId,
      successMessage: LwpI18n.current?.groupActionPostShared ?? 'Post shared.',
      action: () => _groupService.createGroupPost(
        groupId: event.groupId,
        title: event.title,
        content: event.content,
      ),
    );
  }

  Future<void> _onUpdateExistingGroupPost(
    UpdateExistingGroupPost event,
    Emitter<GroupDetailState> emit,
  ) async {
    await _runFeedAction(
      emit,
      event.groupId,
      successMessage:
          LwpI18n.current?.groupActionPostUpdated ?? 'Post updated.',
      action: () => _groupService.updateGroupPost(
        postId: event.postId,
        title: event.title,
        content: event.content,
      ),
    );
  }

  Future<void> _onDeleteGroupPost(
    DeleteGroupPost event,
    Emitter<GroupDetailState> emit,
  ) async {
    await _runFeedAction(
      emit,
      event.groupId,
      successMessage:
          LwpI18n.current?.groupActionPostDeleted ?? 'Post deleted.',
      action: () => _groupService.deleteGroupPost(event.postId),
    );
  }

  Future<void> _onToggleGroupPostReaction(
    ToggleGroupPostReaction event,
    Emitter<GroupDetailState> emit,
  ) async {
    final originalPosts = state.posts;
    final currentPost = originalPosts.where((post) => post.id == event.post.id);
    if (currentPost.isEmpty) return;

    final post = currentPost.first;
    final nextReaction = post.currentUserReaction == event.reactionType
        ? null
        : event.reactionType;

    emit(
      state.copyWith(
        posts: originalPosts
            .map(
              (item) => item.id == post.id
                  ? _applyReactionPreview(item, nextReaction)
                  : item,
            )
            .toList(),
        isFeedActionInProgress: true,
        message: null,
      ),
    );

    try {
      if (nextReaction == null) {
        await _groupService.removeGroupPostReaction(post.id);
      } else {
        await _groupService.setGroupPostReaction(
          postId: post.id,
          reactionType: nextReaction,
        );
      }

      await _loadGroupDetail(
        event.groupId,
        emit,
      );
    } catch (error) {
      emit(
        state.copyWith(
          posts: originalPosts,
          isFeedActionInProgress: false,
          message: error.toString(),
          isErrorMessage: true,
        ),
      );
    }
  }

  Future<void> _onTogglePinPost(
    TogglePinPost event,
    Emitter<GroupDetailState> emit,
  ) async {
    await _runFeedAction(
      emit,
      event.groupId,
      successMessage: event.post.isPinned
          ? (LwpI18n.current?.groupActionPostUnpinned ?? 'Post unpinned.')
          : (LwpI18n.current?.groupActionPostPinned ?? 'Post pinned.'),
      action: () => _groupService.setGroupPostPinned(
        event.post.id,
        !event.post.isPinned,
      ),
    );
  }

  void _onClearGroupDetailMessage(
    ClearGroupDetailMessage event,
    Emitter<GroupDetailState> emit,
  ) {
    emit(state.copyWith(message: null, isErrorMessage: false));
  }

  Future<void> _runAction(
    Emitter<GroupDetailState> emit,
    String groupId, {
    required String successMessage,
    required Future<void> Function() action,
  }) async {
    emit(state.copyWith(isActionInProgress: true, message: null));

    try {
      await action();
      await _loadGroupDetail(
        groupId,
        emit,
        message: successMessage,
        isErrorMessage: false,
      );
    } catch (error) {
      emit(
        state.copyWith(
          isActionInProgress: false,
          message: error.toString(),
          isErrorMessage: true,
        ),
      );
    }
  }

  Future<void> _runFeedAction(
    Emitter<GroupDetailState> emit,
    String groupId, {
    required String successMessage,
    required Future<void> Function() action,
  }) async {
    emit(state.copyWith(isFeedActionInProgress: true, message: null));

    try {
      await action();
      await _loadGroupDetail(
        groupId,
        emit,
        message: successMessage,
        isErrorMessage: false,
      );
    } catch (error) {
      emit(
        state.copyWith(
          isFeedActionInProgress: false,
          message: error.toString(),
          isErrorMessage: true,
        ),
      );
    }
  }

  Future<void> _loadGroupDetail(
    String groupId,
    Emitter<GroupDetailState> emit, {
    String? message,
    bool isErrorMessage = false,
  }) async {
    try {
      final group = await _groupService.getGroupDetail(groupId);
      List<GroupMembership> memberships = const [];
      List<GroupPost> posts = const [];

      if (group.isLeader) {
        memberships = await _groupService.getGroupMemberships(groupId);
      }

      if (group.isActiveMember || group.isLeader) {
        posts = await _groupService.getGroupPosts(groupId);
      }

      emit(
        state.copyWith(
          status: GroupDetailStatus.success,
          group: group,
          memberships: memberships,
          posts: posts,
          isRefreshing: false,
          isActionInProgress: false,
          isFeedActionInProgress: false,
          message: message,
          isErrorMessage: isErrorMessage,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: GroupDetailStatus.error,
          error: error.toString(),
          isRefreshing: false,
          isActionInProgress: false,
          isFeedActionInProgress: false,
          memberships: const [],
          posts: const [],
          message: message,
          isErrorMessage: true,
        ),
      );
    }
  }

  GroupPost _applyReactionPreview(GroupPost post, String? nextReaction) {
    var amenCount = post.amenCount;
    var prayerCount = post.prayerCount;
    var heartCount = post.heartCount;

    void decrement(String? reaction) {
      switch (reaction) {
        case GroupPostReactionType.amen:
          amenCount = amenCount > 0 ? amenCount - 1 : 0;
          break;
        case GroupPostReactionType.prayer:
          prayerCount = prayerCount > 0 ? prayerCount - 1 : 0;
          break;
        case GroupPostReactionType.heart:
          heartCount = heartCount > 0 ? heartCount - 1 : 0;
          break;
      }
    }

    void increment(String? reaction) {
      switch (reaction) {
        case GroupPostReactionType.amen:
          amenCount += 1;
          break;
        case GroupPostReactionType.prayer:
          prayerCount += 1;
          break;
        case GroupPostReactionType.heart:
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
