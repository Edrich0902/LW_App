part of 'calendar_bloc.dart';

abstract class CalendarEvent extends Equatable {
  const CalendarEvent();

  @override
  List<Object?> get props => [];
}

class LoadCalendar extends CalendarEvent {
 final String? eventType;

 const LoadCalendar({required this.eventType});

 @override
  List<Object?> get props => [eventType];
}