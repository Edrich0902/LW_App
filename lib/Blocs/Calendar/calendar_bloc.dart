import 'package:flutter_bloc/flutter_bloc.dart';
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
        List<Event> events = await _eventService.getEvents(type: event.eventType, category: event.eventCategory);
        Map<String, List<Event>> eventsMap = groupBy(events, (obj) => obj.day);
        
        final Map<String, String> dayTranslation = {
          "Monday": "Maandag",
          "Tuesday": "Dinsdag",
          "Wednesday": "Woensdag",
          "Thursday": "Donderdag",
          "Friday": "Vrydag",
          "Saturday": "Saterdag",
          "Sunday": "Sondag",
        };

        List<String> englishDays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];

        Map<String, List<Event>> sortedEvents = {};
        for (String day in englishDays) {
          if (eventsMap[day] != null) {
            String afrikaansDay = dayTranslation[day] ?? day;
            sortedEvents[afrikaansDay] = eventsMap[day]!;
          }
        }

        emit(CalendarSuccess(eventsMap: sortedEvents));
      } catch (error) {
        emit(CalendarError(error.toString()));
      }
    });
  }
}
