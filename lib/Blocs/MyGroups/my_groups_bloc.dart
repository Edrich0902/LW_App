import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lw_app/Models/Group/group.dart';
import 'package:lw_app/Services/Groups/groups_service.dart';

part 'my_groups_event.dart';
part 'my_groups_state.dart';

class MyGroupsBloc extends Bloc<MyGroupsEvent, MyGroupsState> {
  final GroupService _groupService = GroupService();

  MyGroupsBloc() : super(const MyGroupsState()) {
    on<LoadMyGroups>(_onLoadMyGroups);
    on<RefreshMyGroups>(_onRefreshMyGroups);
  }

  Future<void> _onLoadMyGroups(
    LoadMyGroups event,
    Emitter<MyGroupsState> emit,
  ) async {
    emit(state.copyWith(status: MyGroupsStatus.loading, error: null));
    await _loadMyGroups(emit);
  }

  Future<void> _onRefreshMyGroups(
    RefreshMyGroups event,
    Emitter<MyGroupsState> emit,
  ) async {
    emit(state.copyWith(isRefreshing: true, error: null));
    await _loadMyGroups(emit);
  }

  Future<void> _loadMyGroups(Emitter<MyGroupsState> emit) async {
    try {
      final groups = await _groupService.getMyGroups();
      final activeGroups =
          groups.where((group) => group.membershipStatus == 'active').toList();
      final pendingGroups =
          groups.where((group) => group.membershipStatus == 'pending').toList();

      emit(
        state.copyWith(
          status: MyGroupsStatus.success,
          activeGroups: activeGroups,
          pendingGroups: pendingGroups,
          isRefreshing: false,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: MyGroupsStatus.error,
          error: error.toString(),
          isRefreshing: false,
        ),
      );
    }
  }
}
