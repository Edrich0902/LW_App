import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lw_app/Models/TithesOfferings/tithes_offerings_settings.dart';
import 'package:lw_app/Services/TithesOfferings/tithes_offerings_service.dart';

part 'tithes_offerings_event.dart';
part 'tithes_offerings_state.dart';

class TithesOfferingsBloc extends Bloc<TithesOfferingsEvent, TithesOfferingsState> {
  final TithesOfferingsService _service = TithesOfferingsService();

  TithesOfferingsBloc() : super(TithesOfferingsInitial()) {
    on<LoadTithesOfferingsSettings>((event, emit) async {
      emit(TithesOfferingsLoading());
      try {
        final settings = await _service.getSettings();
        if (settings == null) {
          emit(TithesOfferingsEmpty());
        } else {
          emit(TithesOfferingsSuccess(settings: settings));
        }
      } catch (error) {
        emit(TithesOfferingsError(error.toString()));
      }
    });
  }
}
