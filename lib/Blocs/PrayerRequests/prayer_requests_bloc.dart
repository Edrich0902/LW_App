import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lw_app/Models/PrayerRequest/prayer_request.dart';
import 'package:lw_app/Services/PrayerRequest/prayer_request_service.dart';

part 'prayer_requests_event.dart';
part 'prayer_requests_state.dart';

class PrayerRequestsBloc
    extends Bloc<PrayerRequestsEvent, PrayerRequestsState> {
  final PrayerRequestService _prayerRequestService = PrayerRequestService();

  PrayerRequestsBloc() : super(PrayerRequestsInitial()) {
    on<LoadPrayerRequests>((event, emit) async {
      emit(PrayerRequestsLoading());
      try {
        final requests = await _prayerRequestService.getPublicPrayerRequests();
        emit(PrayerRequestsSuccess(requests: requests));
      } catch (error) {
        emit(PrayerRequestsError(error.toString()));
      }
    });

    on<CreatePrayerRequestEvent>((event, emit) async {
      final previousState = state;
      emit(PrayerRequestSubmitting(
          previousRequests: _extractRequests(previousState)));

      try {
        await _prayerRequestService.createPrayerRequest(
          category: event.category,
          body: event.body,
          isAnonymous: event.isAnonymous,
        );

        final requests = await _prayerRequestService.getPublicPrayerRequests();
        emit(const PrayerRequestSubmitSuccess());
        emit(PrayerRequestsSuccess(requests: requests));
      } catch (error) {
        emit(PrayerRequestsError(error.toString()));
        if (previousState is PrayerRequestsSuccess) {
          emit(previousState);
        }
      }
    });

    on<TogglePrayerReaction>((event, emit) async {
      if (state is! PrayerRequestsSuccess) return;

      final currentState = state as PrayerRequestsSuccess;
      final updated = currentState.requests.map((request) {
        if (request.id != event.request.id) return request;
        final nextReacted = !request.hasReacted;
        final nextCount = nextReacted
            ? request.reactionCount + 1
            : (request.reactionCount > 0 ? request.reactionCount - 1 : 0);
        return request.copyWith(
          hasReacted: nextReacted,
          reactionCount: nextCount,
        );
      }).toList();

      emit(PrayerRequestsSuccess(requests: updated));

      try {
        await _prayerRequestService.toggleReaction(
          requestId: event.request.id!,
          hasReacted: event.request.hasReacted,
        );
      } catch (error) {
        emit(PrayerRequestsError(error.toString()));
        emit(currentState);
      }
    });
  }

  List<PrayerRequest> _extractRequests(PrayerRequestsState state) {
    if (state is PrayerRequestsSuccess) return state.requests;
    if (state is PrayerRequestSubmitting) return state.previousRequests;
    return [];
  }
}
