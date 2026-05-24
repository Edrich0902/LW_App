part of 'my_prayer_requests_bloc.dart';

abstract class MyPrayerRequestsState extends Equatable {
  const MyPrayerRequestsState();

  @override
  List<Object?> get props => [];
}

class MyPrayerRequestsInitial extends MyPrayerRequestsState {}

class MyPrayerRequestsLoading extends MyPrayerRequestsState {}

class MyPrayerRequestsSuccess extends MyPrayerRequestsState {
  final List<PrayerRequest> requests;

  const MyPrayerRequestsSuccess({required this.requests});

  @override
  List<Object?> get props => [requests];
}

class MyPrayerRequestActionSuccess extends MyPrayerRequestsState {
  final String message;

  const MyPrayerRequestActionSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class MyPrayerRequestsError extends MyPrayerRequestsState {
  final String error;

  const MyPrayerRequestsError(this.error);

  @override
  List<Object?> get props => [error];
}
