part of 'service_groups_bloc.dart';

abstract class ServiceGroupsEvent extends Equatable {
  const ServiceGroupsEvent();

  @override
  List<Object?> get props => [];
}

class LoadServiceGroups extends ServiceGroupsEvent {
  const LoadServiceGroups();

  @override
  List<Object?> get props => [];
}
