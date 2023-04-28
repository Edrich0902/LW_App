import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:lw_app/Models/Congregation/congregation.dart';
import 'package:lw_app/Services/Congregation/congregation_service.dart';


part 'congregation_list_event.dart';
part 'congregation_list_state.dart';

class CongregationListBloc extends Bloc<CongregationListEvent, CongregationListState> {
  final CongregationService _congregationService = CongregationService();
  CongregationListBloc() : super(CongregationListInitial()) {
    // Load congregations
    on<LoadCongregations>((event, emit) async {
      emit(CongregationListLoading());
      try {
        List<Congregation> congregations = await _congregationService.getCongregations();
        emit(CongregationListSuccess(congregations: congregations));
      } catch (error) {
        emit(CongregationListError(error.toString()));
      }
    });

    //Favourite congregation
    on<FavouriteCongregation>((event, emit) async {
      try {
        if (event.isFavourite == false) {
          await _congregationService.favouriteCongregation(
            congregationId: event.congregationId,
            userId: event.userId,
          );
        } else if (event.isFavourite == true) {
          await _congregationService.unFavouriteCongregation(
            congregationId: event.congregationId,
            userId: event.userId,
          );
        }

        emit(CongregationFavouriteSuccess(
          event.isFavourite == false
            ? 'Congregation added to Favourites'
            : 'Congregation removed from favourites',
        ));
        emit(CongregationListLoading());
        // Load latest congregations
        List<Congregation> congregations = await _congregationService.getCongregations();
        emit(CongregationListSuccess(congregations: congregations));
      } catch (error) {
        emit(CongregationFavouriteError(error.toString()));
      }
    });
  }
}
