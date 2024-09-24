part of 'calendar_bloc.dart';

abstract class CalendarEvent extends Equatable {
  const CalendarEvent();

  @override
  List<Object?> get props => [];
}

class LoadCalendar extends CalendarEvent {
 final String? eventType;
 final String? eventCategory;

 const LoadCalendar({required this.eventType, required this.eventCategory});

 @override
  List<Object?> get props => [eventType];
}