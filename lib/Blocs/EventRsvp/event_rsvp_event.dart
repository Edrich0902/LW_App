part of 'event_rsvp_bloc.dart';

abstract class EventRsvpEvent extends Equatable {
  const EventRsvpEvent();

  @override
  List<Object?> get props => [];
}

class InitEventRsvp extends EventRsvpEvent {
  final Event event;
  const InitEventRsvp(this.event);

  @override
  List<Object?> get props => [event];
}

class SubmitRsvpEvent extends EventRsvpEvent {
  final String eventId;
  final RsvpStatus newStatus;

  const SubmitRsvpEvent({required this.eventId, required this.newStatus});

  @override
  List<Object?> get props => [eventId, newStatus];
}
