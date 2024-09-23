part of 'connect_groups_bloc.dart';

abstract class ConnectGroupsEvent extends Equatable {
  const ConnectGroupsEvent();

  @override
  List<Object?> get props => [];
}

class LoadConnectGroups extends ConnectGroupsEvent {
  const LoadConnectGroups();

  @override
  List<Object?> get props => [];
}
