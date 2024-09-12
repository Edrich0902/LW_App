import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lw_app/Models/Event/event.dart';
import 'package:lw_app/Services/Event/event_service.dart';
import "package:collection/collection.dart";

part 'calendar_event.dart';
part 'calendar_state.dart';

class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  final EventService _eventService = EventService();

  CalendarBloc() : super(CalendarInitial()) {
    on<LoadCalendar>((event, emit) async {
      emit(CalendarLoading());
      try {
        List<Event> events = await _eventService.getEvents(type: event.eventType);
        Map<String, List<Event>> eventsMap = groupBy(events, (obj) => obj.day);
        List<String> days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]; // TODO: this can possibly be improved

        Map<String, List<Event>> sortedEvents = {};
        for (String day in days) {
          if (eventsMap[day] != null) sortedEvents[day] = eventsMap[day]!;
        }

        emit(CalendarSuccess(eventsMap: sortedEvents));
      } catch (error) {
        emit(CalendarError(error.toString()));
      }
    });
  }
}
