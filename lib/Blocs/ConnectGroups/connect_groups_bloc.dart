import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lw_app/Models/Group/group.dart';
import 'package:lw_app/Services/Groups/groups_service.dart';

part 'connect_groups_event.dart';
part 'connect_groups_state.dart';

class ConnectGroupsBloc extends Bloc<ConnectGroupsEvent, ConnectGroupsState> {
  final GroupService _groupService = GroupService();

  ConnectGroupsBloc() : super(ConnectGroupsInitial()) {
    on<LoadConnectGroups>((event, emit) async {
      emit(ConnectGroupsLoading());
      try {
        List<Group> connectGroups = await _groupService.getConnectGroups();
        emit(ConnectGroupsSuccess(connectGroups: connectGroups));
      } catch (error) {
        emit(ConnectGroupsError(error.toString()));
      }
    });
  }
}
