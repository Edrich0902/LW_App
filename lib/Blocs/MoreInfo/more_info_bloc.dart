import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lw_app/Models/MetaData/meta_data.dart';
import 'package:lw_app/Models/Roleplayer/roleplayer.dart';
import 'package:lw_app/Services/MetaData/meta_data_service.dart';
import 'package:lw_app/Services/Roleplayer/roleplayer_service.dart';

part 'more_info_event.dart';
part 'more_info_state.dart';

class MoreInfoBloc extends Bloc<MoreInfoEvent, MoreInfoState> {
  final MetaDataService _metaDataService = MetaDataService();
  final RoleplayerService _roleplayerService = RoleplayerService();

  static final _searchKeys = ['vision_statement', 'mission_statement'];

  MoreInfoBloc() : super(MoreInfoInitial()) {
    on<LoadMoreInfo>((event, emit) async {
      emit(MoreInfoLoading());
      try {
        List<MetaData> data = await _metaDataService.getVisionMission(_searchKeys);
        List<Roleplayer> roleplayers = await _roleplayerService.getRolePlayers();

        emit(MoreInfoSuccess(data: data, roleplayers: roleplayers));
      } catch (error) {
        emit(MoreInfoError(error.toString()));
      }
    });
  }
}
