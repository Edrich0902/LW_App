part of 'sermons_bloc.dart';

abstract class SermonsEvent extends Equatable {
  const SermonsEvent();

  @override
  List<Object> get props => [];
}

class LoadSermons extends SermonsEvent {
  const LoadSermons();

  @override
  List<Object> get props => [];
}
