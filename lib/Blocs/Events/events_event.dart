part of 'events_bloc.dart';

abstract class EventsEvent extends Equatable {
  const EventsEvent();

  @override
  List<Object?> get props => [];
}

class LoadEvents extends EventsEvent {
  final String? eventType;

  const LoadEvents({this.eventType});

  @override
  List<Object?> get props => [eventType];
}

class LoadUpcomingEvents extends EventsEvent {
  final String? eventType;
  final DateTime? date;

  const LoadUpcomingEvents({ this.eventType, this.date });

  @override
  List<Object?> get props => [eventType, date];
}