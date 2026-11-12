import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Models/UserAnnouncement/user_announcement.dart';
import 'package:lw_app/Services/UserAnnouncement/user_announcement_service.dart';

part 'user_announcement_event.dart';
part 'user_announcement_state.dart';

class UserAnnouncementBloc
    extends Bloc<UserAnnouncementEvent, UserAnnouncementState> {
  final UserAnnouncementService _userAnnouncementService =
      UserAnnouncementService();

  UserAnnouncementBloc() : super(UserAnnouncementInitial()) {
    on<LoadUserAnnouncements>((event, emit) async {
      emit(UserAnnouncementLoading());
      try {
        final announcements =
            await _userAnnouncementService.getUserAnnouncements();
        emit(UserAnnouncementSuccess(userAnnouncements: announcements));
      } catch (error) {
        emit(UserAnnouncementError(error.toString()));
      }
    });

    on<ReadUserAnnouncements>((event, emit) async {
      try {
        await _userAnnouncementService.markUserNotificationsAsRead();
      } catch (error) {
        emit(UserAnnouncementError(error.toString()));
      }
    });

    on<DismissUserAnnouncement>((event, emit) async {
      if (state is UserAnnouncementSuccess) {
        final currentAnnouncements =
            (state as UserAnnouncementSuccess).userAnnouncements;
        final updatedAnnouncements =
            currentAnnouncements.where((a) => a.id != event.id).toList();
        emit(UserAnnouncementSuccess(userAnnouncements: updatedAnnouncements));

        try {
          await _userAnnouncementService.markUserNotificationAsRead(event.id);
        } catch (_) {}
      }
    });
  }
}
