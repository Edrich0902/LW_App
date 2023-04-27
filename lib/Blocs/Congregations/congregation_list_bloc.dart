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
    on<LoadCongregations>((event, emit) async {
      emit(CongregationListLoading());
      try {
        List<Congregation> congregations = await _congregationService.getCongregations();
        emit(CongregationListSuccess(congregations: congregations));
      } catch (error) {
        emit(CongregationListError(error.toString()));
      }
    });
  }
}
