import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lw_app/Models/PrayerRequest/prayer_request.dart';
import 'package:lw_app/Services/PrayerRequest/prayer_request_service.dart';

part 'my_prayer_requests_event.dart';
part 'my_prayer_requests_state.dart';

class MyPrayerRequestsBloc
    extends Bloc<MyPrayerRequestsEvent, MyPrayerRequestsState> {
  final PrayerRequestService _prayerRequestService = PrayerRequestService();

  MyPrayerRequestsBloc() : super(MyPrayerRequestsInitial()) {
    on<LoadMyPrayerRequests>((event, emit) async {
      emit(MyPrayerRequestsLoading());
      try {
        final requests = await _prayerRequestService.getMyPrayerRequests();
        emit(MyPrayerRequestsSuccess(requests: requests));
      } catch (error) {
        emit(MyPrayerRequestsError(error.toString()));
      }
    });

    on<ResolveMyPrayerRequest>((event, emit) async {
      if (state is! MyPrayerRequestsSuccess) return;

      final currentState = state as MyPrayerRequestsSuccess;
      try {
        await _prayerRequestService.resolvePrayerRequest(event.requestId);
        final requests = await _prayerRequestService.getMyPrayerRequests();
        emit(MyPrayerRequestActionSuccess(
            message: 'Gebedsversoek is afgehandel.'));
        emit(MyPrayerRequestsSuccess(requests: requests));
      } catch (error) {
        emit(MyPrayerRequestsError(error.toString()));
        emit(currentState);
      }
    });
  }
}
