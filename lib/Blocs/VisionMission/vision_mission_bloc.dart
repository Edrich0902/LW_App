import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lw_app/Models/MetaData/meta_data.dart';
import 'package:lw_app/Services/MetaData/meta_data_service.dart';

part 'vision_mission_event.dart';
part 'vision_mission_state.dart';

class VisionMissionBloc extends Bloc<VisionMissionEvent, VisionMissionState> {
  final MetaDataService _metaDataService = MetaDataService();

  static final _search_keys = ['vision_statement', 'mission_statement'];

  VisionMissionBloc() : super(VisionMissionInitial()) {
    on<LoadVisionMission>((event, emit) async {
      emit(VisionMissionLoading());
      try {
        List<MetaData> data = await _metaDataService.getVisionMission(_search_keys);
        emit(VisionMissionSuccess(data: data));
      } catch (error) {
        emit(VisionMissionError(error.toString()));
      }
    });
  }
}
