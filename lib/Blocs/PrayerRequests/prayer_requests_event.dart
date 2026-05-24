part of 'prayer_requests_bloc.dart';

abstract class PrayerRequestsEvent extends Equatable {
  const PrayerRequestsEvent();

  @override
  List<Object?> get props => [];
}

class LoadPrayerRequests extends PrayerRequestsEvent {
  const LoadPrayerRequests();
}

class CreatePrayerRequestEvent extends PrayerRequestsEvent {
  final PrayerCategory category;
  final String body;
  final bool isAnonymous;

  const CreatePrayerRequestEvent({
    required this.category,
    required this.body,
    required this.isAnonymous,
  });

  @override
  List<Object?> get props => [category, body, isAnonymous];
}

class TogglePrayerReaction extends PrayerRequestsEvent {
  final PrayerRequest request;

  const TogglePrayerReaction({required this.request});

  @override
  List<Object?> get props => [request];
}
