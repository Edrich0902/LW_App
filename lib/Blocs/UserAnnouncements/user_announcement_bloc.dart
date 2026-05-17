import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lw_app/Models/UserAnnouncement/user_announcement.dart';
import 'package:lw_app/Services/UserAnnouncement/user_announcement_service.dart';

part 'user_announcement_event.dart';
part 'user_announcement_state.dart';

class UserAnnouncementBloc extends Bloc<UserAnnouncementEvent, UserAnnouncementState> {
  final UserAnnouncementService _userAnnouncementService = UserAnnouncementService();

  UserAnnouncementBloc() : super(UserAnnouncementInitial()) {
    on<LoadUserAnnouncements>((event, emit) async {
      emit(UserAnnouncementLoading());
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
      } catch (error) {
        emit(UserAnnouncementError(error.toString()));
      }
    });

    on<DismissUserAnnouncement>((event, emit) async {
      if (state is UserAnnouncementSuccess) {
        final currentAnnouncements = (state as UserAnnouncementSuccess).userAnnouncements;
        // Optimistic update
        final updatedAnnouncements = currentAnnouncements.where((a) => a.id != event.id).toList();
        emit(UserAnnouncementSuccess(userAnnouncements: updatedAnnouncements));

        try {
          await _userAnnouncementService.markUserNotificationAsRead(event.id);
        } catch (error) {
          // If error occurs, we could optionally reload the list to ensure accuracy,
          // but for a "mark as read" action, silent failure or background retry is often okay.
          // For now, we'll just log or emit error if it's critical.
        }
      }
    });
  }
}
