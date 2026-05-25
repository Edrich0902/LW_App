import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lw_app/Models/Event/event.dart';
import 'package:lw_app/Models/Event/rsvp_status.dart';
import 'package:lw_app/Services/EventRsvp/event_rsvp_service.dart';

part 'event_rsvp_event.dart';
part 'event_rsvp_state.dart';

class EventRsvpBloc extends Bloc<EventRsvpEvent, EventRsvpState> {
  final EventRsvpService _rsvpService = EventRsvpService();

  EventRsvpBloc() : super(EventRsvpInitial()) {
    on<InitEventRsvp>((event, emit) {
      emit(EventRsvpReady(
        attendingCount: event.event.attendingCount,
        interestedCount: event.event.interestedCount,
        notAttendingCount: event.event.notAttendingCount,
        userStatus: event.event.userRsvpStatus,
        capacity: event.event.capacity,
      ));
    });

    on<SubmitRsvpEvent>((event, emit) async {
      if (state is! EventRsvpReady) return;
      final current = state as EventRsvpReady;

      // Determine next status: same tap = toggle off
      final isToggleOff = current.userStatus == event.newStatus;
      final nextStatus = isToggleOff ? null : event.newStatus;

      // Compute optimistic counts
      final optimistic = _applyOptimisticUpdate(
        current: current,
        previousStatus: current.userStatus,
        nextStatus: nextStatus,
      );

      emit(EventRsvpUpdating(current));
      emit(optimistic);

      try {
        if (isToggleOff) {
          await _rsvpService.deleteRsvp(eventId: event.eventId);
        } else {
          await _rsvpService.upsertRsvp(
            eventId: event.eventId,
            status: event.newStatus,
          );
        }
      } catch (error) {
        emit(EventRsvpError(message: error.toString(), previous: current));
        emit(current);
      }
    });
  }

  EventRsvpReady _applyOptimisticUpdate({
    required EventRsvpReady current,
    required RsvpStatus? previousStatus,
    required RsvpStatus? nextStatus,
  }) {
    int attending = current.attendingCount;
    int interested = current.interestedCount;
    int notAttending = current.notAttendingCount;

    // Decrement old bucket
    if (previousStatus == RsvpStatus.attending) attending = attending > 0 ? attending - 1 : 0;
    if (previousStatus == RsvpStatus.interested) interested = interested > 0 ? interested - 1 : 0;
    if (previousStatus == RsvpStatus.notAttending) notAttending = notAttending > 0 ? notAttending - 1 : 0;

    // Increment new bucket
    if (nextStatus == RsvpStatus.attending) attending++;
    if (nextStatus == RsvpStatus.interested) interested++;
    if (nextStatus == RsvpStatus.notAttending) notAttending++;

    return current.copyWith(
      attendingCount: attending,
      interestedCount: interested,
      notAttendingCount: notAttending,
      userStatus: () => nextStatus,
    );
  }
}
