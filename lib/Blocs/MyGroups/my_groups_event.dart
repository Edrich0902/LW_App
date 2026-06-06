part of 'my_groups_bloc.dart';

abstract class MyGroupsEvent extends Equatable {
  const MyGroupsEvent();

  @override
  List<Object?> get props => [];
}

class LoadMyGroups extends MyGroupsEvent {
  const LoadMyGroups();
}

class RefreshMyGroups extends MyGroupsEvent {
  const RefreshMyGroups();
}
