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
  final List<Roleplayer> roleplayers;

  const MoreInfoSuccess({required this.data, required this.roleplayers});

  @override
  List<Object?> get props => [data, roleplayers];
}

class MoreInfoError extends MoreInfoState {
  final String error;

  const MoreInfoError(this.error);

  @override
  List<Object> get props => [error];
}