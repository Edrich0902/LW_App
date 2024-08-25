part of 'events_bloc.dart';

abstract class EventsState extends Equatable {
  const EventsState();
}

class EventsInitial extends EventsState {
  @override
  List<Object> get props => [];
}

class EventsLoading extends EventsState {
  @override
  List<Object> get props => [];
}

class EventsSuccess extends EventsState {
  final List<Event> events;

  const EventsSuccess({required this.events});

  @override
  List<Object?> get props => [events];
}

class EventsError extends EventsState {
  final String error;

  const EventsError(this.error);

  @override
  List<Object> get props => [error];
}
