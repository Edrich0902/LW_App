import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lw_app/Models/Event/event.dart';
import 'package:lw_app/Services/Event/event_service.dart';

part 'events_event.dart';
part 'events_state.dart';

class EventsBloc extends Bloc<EventsEvent, EventsState> {
  final EventService _eventService = EventService();

  EventsBloc() : super(EventsInitial()) {
    on<LoadEvents>((event, emit) async {
      emit(EventsLoading());
      try {
        List<Event> events = await _eventService.getEvents(type: event.eventType);
        emit(EventsSuccess(events: events));
      } catch (error) {
        emit(EventsError(error.toString()));
      }
    });

    on<LoadUpcomingEvents>((event, emit) async {
      emit(EventsLoading());
      try {
        List<Event> events = await _eventService.getEvents(type: event.eventType, date: event.date);
        emit(EventsSuccess(events: events));
      } catch (error) {
        emit(EventsError(error.toString()));
      }
    });
  }
}
