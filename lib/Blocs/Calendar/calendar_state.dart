part of 'calendar_bloc.dart';

abstract class CalendarState extends Equatable {
  const CalendarState();
}

class CalendarInitial extends CalendarState {
  @override
  List<Object> get props => [];
}

class CalendarLoading extends CalendarState {
  @override
  List<Object> get props => [];
}

class CalendarSuccess extends CalendarState {
  final Map<String, List<Event>> eventsMap;

  const CalendarSuccess({required this.eventsMap});

  @override
  List<Object> get props => [eventsMap];
}

class CalendarError extends CalendarState {
  final String error;

  const CalendarError(this.error);

  @override
  List<Object> get props => [props];
}