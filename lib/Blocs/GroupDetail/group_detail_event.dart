part of 'group_detail_bloc.dart';

abstract class GroupDetailEvent extends Equatable {
  const GroupDetailEvent();

  @override
  List<Object?> get props => [];
}

class LoadGroupDetail extends GroupDetailEvent {
  final String groupId;

  const LoadGroupDetail(this.groupId);

  @override
  List<Object?> get props => [groupId];
}

class RefreshGroupDetail extends GroupDetailEvent {
  final String groupId;

  const RefreshGroupDetail(this.groupId);

  @override
  List<Object?> get props => [groupId];
}

class RequestToJoinGroup extends GroupDetailEvent {
  final String groupId;

  const RequestToJoinGroup(this.groupId);

  @override
  List<Object?> get props => [groupId];
}

class CancelGroupJoinRequest extends GroupDetailEvent {
  final String groupId;

  const CancelGroupJoinRequest(this.groupId);

  @override
  List<Object?> get props => [groupId];
}

class LeaveGroup extends GroupDetailEvent {
  final String groupId;

  const LeaveGroup(this.groupId);

  @override
  List<Object?> get props => [groupId];
}

class ApproveGroupMembership extends GroupDetailEvent {
  final String groupId;
  final String userId;

  const ApproveGroupMembership(this.groupId, this.userId);

  @override
  List<Object?> get props => [groupId, userId];
}

class DeclineGroupMembership extends GroupDetailEvent {
  final String groupId;
  final String userId;

  const DeclineGroupMembership(this.groupId, this.userId);

  @override
  List<Object?> get props => [groupId, userId];
}

class RemoveGroupMember extends GroupDetailEvent {
  final String groupId;
  final String userId;

  const RemoveGroupMember(this.groupId, this.userId);

  @override
  List<Object?> get props => [groupId, userId];
}

class UpdateGroupFromLeader extends GroupDetailEvent {
  final String groupId;
  final String title;
  final String description;
  final String? whatsappLink;
  final String? location;
  final String? bannerUrl;
  final String? bannerPublicId;

  const UpdateGroupFromLeader({
    required this.groupId,
    required this.title,
    required this.description,
    this.whatsappLink,
    this.location,
    this.bannerUrl,
    this.bannerPublicId,
  });

  @override
  List<Object?> get props => [
        groupId,
        title,
        description,
        whatsappLink,
        location,
        bannerUrl,
        bannerPublicId,
      ];
}

class CreateGroupPost extends GroupDetailEvent {
  final String groupId;
  final String title;
  final String content;

  const CreateGroupPost({
    required this.groupId,
    required this.title,
    required this.content,
  });

  @override
  List<Object?> get props => [groupId, title, content];
}

class UpdateExistingGroupPost extends GroupDetailEvent {
  final String groupId;
  final String postId;
  final String title;
  final String content;

  const UpdateExistingGroupPost({
    required this.groupId,
    required this.postId,
    required this.title,
    required this.content,
  });

  @override
  List<Object?> get props => [groupId, postId, title, content];
}

class DeleteGroupPost extends GroupDetailEvent {
  final String groupId;
  final String postId;

  const DeleteGroupPost({
    required this.groupId,
    required this.postId,
  });

  @override
  List<Object?> get props => [groupId, postId];
}

class ToggleGroupPostReaction extends GroupDetailEvent {
  final String groupId;
  final GroupPost post;
  final String reactionType;

  const ToggleGroupPostReaction({
    required this.groupId,
    required this.post,
    required this.reactionType,
  });

  @override
  List<Object?> get props => [groupId, post, reactionType];
}

class TogglePinPost extends GroupDetailEvent {
  final String groupId;
  final GroupPost post;

  const TogglePinPost({
    required this.groupId,
    required this.post,
  });

  @override
  List<Object?> get props => [groupId, post];
}

class ClearGroupDetailMessage extends GroupDetailEvent {
  const ClearGroupDetailMessage();
}
