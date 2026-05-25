part of 'event_rsvp_bloc.dart';

abstract class EventRsvpState extends Equatable {
  const EventRsvpState();

  @override
  List<Object?> get props => [];
}

class EventRsvpInitial extends EventRsvpState {}

class EventRsvpReady extends EventRsvpState {
  final int attendingCount;
  final int interestedCount;
  final int notAttendingCount;
  final RsvpStatus? userStatus;
  final int? capacity;

  const EventRsvpReady({
    required this.attendingCount,
    required this.interestedCount,
    required this.notAttendingCount,
    this.userStatus,
    this.capacity,
  });

  bool get isFull =>
      capacity != null && attendingCount >= capacity!;

  EventRsvpReady copyWith({
    int? attendingCount,
    int? interestedCount,
    int? notAttendingCount,
    RsvpStatus? Function()? userStatus,
    int? capacity,
  }) {
    return EventRsvpReady(
      attendingCount: attendingCount ?? this.attendingCount,
      interestedCount: interestedCount ?? this.interestedCount,
      notAttendingCount: notAttendingCount ?? this.notAttendingCount,
      userStatus: userStatus != null ? userStatus() : this.userStatus,
      capacity: capacity ?? this.capacity,
    );
  }

  @override
  List<Object?> get props => [
        attendingCount,
        interestedCount,
        notAttendingCount,
        userStatus,
        capacity,
      ];
}

class EventRsvpUpdating extends EventRsvpState {
  final EventRsvpReady previous;
  const EventRsvpUpdating(this.previous);

  @override
  List<Object?> get props => [previous];
}

class EventRsvpError extends EventRsvpState {
  final String message;
  final EventRsvpReady previous;

  const EventRsvpError({required this.message, required this.previous});

  @override
  List<Object?> get props => [message, previous];
}
