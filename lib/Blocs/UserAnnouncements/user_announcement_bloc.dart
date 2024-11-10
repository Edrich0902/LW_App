import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lw_app/Models/UserAnnouncement/user_announcement.dart';
import 'package:lw_app/Services/UserAnnouncement/user_announcement_service.dart';

part 'user_announcement_event.dart';
part 'user_announcement_state.dart';

class UserAnnouncementBloc extends Bloc<UserAnnouncementEvent, UserAnnouncementState> {
  final UserAnnouncementService _userAnnouncementService = UserAnnouncementService();

  UserAnnouncementBloc() : super(UserAnnouncementInitial()) {
    on<LoadUserAnnouncements>((event, emit) async {
      try {
        List<UserAnnouncement> announcements = await _userAnnouncementService.getUserAnnouncements();
        emit(UserAnnouncementSuccess(userAnnouncements: announcements));
      } catch (error) {
        emit(UserAnnouncementError(error.toString()));
      }
    });

    on<ReadUserAnnouncements>((event, emit) async {
      try {
        await _userAnnouncementService.markUserNotificationsAsRead();
        emit(UserAnnouncementRead());
      } catch (error) {
        emit(UserAnnouncementError(error.toString()));
      }
    });
  }
}
