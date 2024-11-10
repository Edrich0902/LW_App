part of 'user_announcement_bloc.dart';

abstract class UserAnnouncementState extends Equatable {
  const UserAnnouncementState();
}

class UserAnnouncementInitial extends UserAnnouncementState {
  @override
  List<Object> get props => [];
}

class UserAnnouncementLoading extends UserAnnouncementState {
  @override
  List<Object> get props => [];
}

class UserAnnouncementSuccess extends UserAnnouncementState {
  final List<UserAnnouncement> userAnnouncements;

  const UserAnnouncementSuccess({required this.userAnnouncements});

  @override
  List<Object> get props => [userAnnouncements];
}

class UserAnnouncementError extends UserAnnouncementState {
  final String error;

  const UserAnnouncementError(this.error);

  @override
  List<Object> get props => [error];
}

class UserAnnouncementRead extends UserAnnouncementState {
  @override
  List<Object> get props => [];
}