part of 'congregation_list_bloc.dart';

@immutable
abstract class CongregationListEvent extends Equatable {
  const CongregationListEvent();

  @override
  List<Object> get props => [];
}

class LoadCongregations extends CongregationListEvent {
  const LoadCongregations();

  @override
  List<Object> get props => [];
}
