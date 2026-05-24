part of 'prayer_requests_bloc.dart';

abstract class PrayerRequestsState extends Equatable {
  const PrayerRequestsState();

  @override
  List<Object?> get props => [];
}

class PrayerRequestsInitial extends PrayerRequestsState {}

class PrayerRequestsLoading extends PrayerRequestsState {}

class PrayerRequestsSuccess extends PrayerRequestsState {
  final List<PrayerRequest> requests;

  const PrayerRequestsSuccess({required this.requests});

  @override
  List<Object?> get props => [requests];
}

class PrayerRequestSubmitting extends PrayerRequestsState {
  final List<PrayerRequest> previousRequests;

  const PrayerRequestSubmitting({required this.previousRequests});

  @override
  List<Object?> get props => [previousRequests];
}

class PrayerRequestSubmitSuccess extends PrayerRequestsState {
  const PrayerRequestSubmitSuccess();
}

class PrayerRequestsError extends PrayerRequestsState {
  final String error;

  const PrayerRequestsError(this.error);

  @override
  List<Object?> get props => [error];
}
