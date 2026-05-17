part of 'user_announcement_bloc.dart';

abstract class UserAnnouncementEvent extends Equatable {
  const UserAnnouncementEvent();

  @override
  List<Object> get props => [];
}

class LoadUserAnnouncements extends UserAnnouncementEvent {
  const LoadUserAnnouncements();

  @override
  List<Object> get props => [];
}

class ReadUserAnnouncements extends UserAnnouncementEvent {
  const ReadUserAnnouncements();

  @override
  List<Object> get props => [];
}

class DismissUserAnnouncement extends UserAnnouncementEvent {
  final String id;
  const DismissUserAnnouncement(this.id);

  @override
  List<Object> get props => [id];
}
