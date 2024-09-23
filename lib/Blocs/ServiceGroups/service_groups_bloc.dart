import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lw_app/Models/Group/group.dart';
import 'package:lw_app/Models/Group/group_type.dart';
import 'package:lw_app/Services/Groups/groups_service.dart';

part 'service_groups_event.dart';
part 'service_groups_state.dart';

class ServiceGroupsBloc extends Bloc<ServiceGroupsEvent, ServiceGroupsState> {
  final GroupService _groupService = GroupService();

  ServiceGroupsBloc() : super(ServiceGroupsInitial()) {
    on<LoadServiceGroups>((event, emit) async {
      emit(ServiceGroupsLoading());
      try {
        List<Group> serviceGroups = await _groupService.getServeGroups();
        emit(ServiceGroupsSuccess(serviceGroups: serviceGroups));
      } catch (error) {
        emit(ServiceGroupsError(error.toString()));
      }
    });
  }
}
