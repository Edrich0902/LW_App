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
  final String? praiseReport;

  const ResolveMyPrayerRequest(this.requestId, {this.praiseReport});

  @override
  List<Object?> get props => [requestId, praiseReport];
}
