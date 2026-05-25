import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lw_app/Models/Event/event.dart';
import 'package:lw_app/Models/Event/rsvp_status.dart';
import 'package:lw_app/Services/Event/event_service.dart';

part 'events_event.dart';
part 'events_state.dart';

class EventsBloc extends Bloc<EventsEvent, EventsState> {
  final EventService _eventService = EventService();

  EventsBloc() : super(EventsInitial()) {
    on<LoadEvents>((event, emit) async {
      emit(EventsLoading());
      try {
        final events = await _eventService.getEvents(type: event.eventType);
        emit(EventsSuccess(events: events));
      } catch (error) {
        emit(EventsError(error.toString()));
      }
    });

    on<LoadUpcomingEvents>((event, emit) async {
      emit(EventsLoading());
      try {
        final events = await _eventService.getUpcomingEventsWithRsvp(
          date: event.date,
        );
        emit(EventsSuccess(events: events));
      } catch (error) {
        emit(EventsError(error.toString()));
      }
    });

    on<UpdateEventRsvpCounts>((event, emit) {
      if (state is! EventsSuccess) return;
      final current = state as EventsSuccess;
      final updated = current.events.map((e) {
        if (e.id != event.eventId) return e;
        return e.copyWith(
          attendingCount: event.attendingCount,
          interestedCount: event.interestedCount,
          notAttendingCount: event.notAttendingCount,
          userRsvpStatus: () => event.userStatus,
        );
      }).toList();
      emit(EventsSuccess(events: updated));
    });
  }
}
