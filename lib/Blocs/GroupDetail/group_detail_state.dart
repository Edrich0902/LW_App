part of 'group_detail_bloc.dart';

enum GroupDetailStatus { initial, loading, success, error }

class GroupDetailState extends Equatable {
  final GroupDetailStatus status;
  final Group? group;
  final List<GroupMembership> memberships;
  final List<GroupPost> posts;
  final bool isRefreshing;
  final bool isActionInProgress;
  final bool isFeedActionInProgress;
  final String? message;
  final bool isErrorMessage;
  final String? error;

  const GroupDetailState({
    this.status = GroupDetailStatus.initial,
    this.group,
    this.memberships = const [],
    this.posts = const [],
    this.isRefreshing = false,
    this.isActionInProgress = false,
    this.isFeedActionInProgress = false,
    this.message,
    this.isErrorMessage = false,
    this.error,
  });

  List<GroupMembership> get activeLeaders => memberships
      .where((membership) => membership.role == GroupMembershipRole.leader)
      .toList();

  List<GroupMembership> get activeMembers => memberships
      .where((membership) =>
          membership.role == GroupMembershipRole.member &&
          membership.status == GroupMembershipStatus.active)
      .toList();

  List<GroupMembership> get pendingMembers => memberships
      .where((membership) => membership.status == GroupMembershipStatus.pending)
      .toList();

  GroupDetailState copyWith({
    GroupDetailStatus? status,
    Group? group,
    List<GroupMembership>? memberships,
    List<GroupPost>? posts,
    bool? isRefreshing,
    bool? isActionInProgress,
    bool? isFeedActionInProgress,
    String? message,
    bool? isErrorMessage,
    String? error,
    bool clearMessage = false,
  }) {
    return GroupDetailState(
      status: status ?? this.status,
      group: group ?? this.group,
      memberships: memberships ?? this.memberships,
      posts: posts ?? this.posts,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isActionInProgress: isActionInProgress ?? this.isActionInProgress,
      isFeedActionInProgress:
          isFeedActionInProgress ?? this.isFeedActionInProgress,
      message: clearMessage ? null : message ?? this.message,
      isErrorMessage: isErrorMessage ?? this.isErrorMessage,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        status,
        group,
        memberships,
        posts,
        isRefreshing,
        isActionInProgress,
        isFeedActionInProgress,
        message,
        isErrorMessage,
        error,
      ];
}
