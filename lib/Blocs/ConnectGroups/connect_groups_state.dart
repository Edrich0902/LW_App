part of 'connect_groups_bloc.dart';

abstract class ConnectGroupsState extends Equatable {
  const ConnectGroupsState();
}

class ConnectGroupsInitial extends ConnectGroupsState {
  @override
  List<Object> get props => [];
}

class ConnectGroupsLoading extends ConnectGroupsState {
  @override
  List<Object> get props => [];
}

class ConnectGroupsSuccess extends ConnectGroupsState {
  final List<Group> connectGroups;

  const ConnectGroupsSuccess({required this.connectGroups});

  @override
  List<Object> get props => [connectGroups];
}

class ConnectGroupsError extends ConnectGroupsState {
  final String error;

  const ConnectGroupsError(this.error);

  @override
  List<Object> get props => [error];
}