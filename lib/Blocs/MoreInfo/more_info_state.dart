part of 'more_info_bloc.dart';

abstract class MoreInfoState extends Equatable {
  const MoreInfoState();
}

class MoreInfoInitial extends MoreInfoState {
  @override
  List<Object> get props => [];
}

class MoreInfoLoading extends MoreInfoState {
  @override
  List<Object> get props => [];
}

class MoreInfoSuccess extends MoreInfoState {
  final List<MetaData> data;

  const MoreInfoSuccess({required this.data});

  @override
  List<Object?> get props => [data];
}

class MoreInfoError extends MoreInfoState {
  final String error;

  const MoreInfoError(this.error);

  @override
  List<Object> get props => [error];
}