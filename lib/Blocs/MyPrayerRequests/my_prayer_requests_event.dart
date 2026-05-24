part of 'my_prayer_requests_bloc.dart';

abstract class MyPrayerRequestsEvent extends Equatable {
  const MyPrayerRequestsEvent();

  @override
  List<Object?> get props => [];
}

class LoadMyPrayerRequests extends MyPrayerRequestsEvent {
  const LoadMyPrayerRequests();
}

class ResolveMyPrayerRequest extends MyPrayerRequestsEvent {
  final String requestId;

  const ResolveMyPrayerRequest(this.requestId);

  @override
  List<Object?> get props => [requestId];
}
