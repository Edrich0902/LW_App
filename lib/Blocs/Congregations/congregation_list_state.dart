part of 'congregation_list_bloc.dart';

@immutable
abstract class CongregationListState extends Equatable{
  const CongregationListState();
}

class CongregationListInitial extends CongregationListState {
  @override
  List<Object> get props => [];
}

class CongregationListLoading extends CongregationListState {
  @override
  List<Object> get props => [];
}

class CongregationListSuccess extends CongregationListState {
  final List<Congregation> congregations;

  const CongregationListSuccess({required this.congregations});

  @override
  List<Object?> get props => [congregations];
}

class CongregationListError extends CongregationListState {
  final String error;

  const CongregationListError(this.error);

  @override
  List<Object> get props => [error];
}

class CongregationFavouriteError extends CongregationListState {
  final String error;

  const CongregationFavouriteError(this.error);

  @override
  List<Object> get props => [error];
}

class CongregationFavouriteSuccess extends CongregationListState {
  final String message;

  const CongregationFavouriteSuccess(this.message);

  @override
  List<Object> get props => [message];
}
