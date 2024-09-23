part of 'service_groups_bloc.dart';

abstract class ServiceGroupsState extends Equatable {
  const ServiceGroupsState();
}

class ServiceGroupsInitial extends ServiceGroupsState {
  @override
  List<Object> get props => [];
}

class ServiceGroupsLoading extends ServiceGroupsState {
  @override
  List<Object> get props => [];
}

class ServiceGroupsSuccess extends ServiceGroupsState {
  final List<Group> serviceGroups;

  const ServiceGroupsSuccess({required this.serviceGroups});

  @override
  List<Object> get props => [serviceGroups];
}

class ServiceGroupsError extends ServiceGroupsState {
  final String error;

  const ServiceGroupsError(this.error);

  @override
  List<Object> get props => [error];
}