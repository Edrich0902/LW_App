import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lw_app/Models/MetaData/meta_data.dart';
import 'package:lw_app/Services/MetaData/meta_data_service.dart';

part 'more_info_event.dart';
part 'more_info_state.dart';

class MoreInfoBloc extends Bloc<MoreInfoEvent, MoreInfoState> {
  final MetaDataService _metaDataService = MetaDataService();

  static final _search_keys = ['vision_statement', 'mission_statement'];

  MoreInfoBloc() : super(MoreInfoInitial()) {
    on<LoadMoreInfo>((event, emit) async {
      emit(MoreInfoLoading());
      try {
        List<MetaData> data = await _metaDataService.getVisionMission(_search_keys);
        emit(MoreInfoSuccess(data: data));
      } catch (error) {
        emit(MoreInfoError(error.toString()));
      }
    });
  }
}
