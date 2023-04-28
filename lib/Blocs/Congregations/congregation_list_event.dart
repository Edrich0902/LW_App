part of 'congregation_list_bloc.dart';

@immutable
abstract class CongregationListEvent extends Equatable {
  const CongregationListEvent();

  @override
  List<Object?> get props => [];
}

class LoadCongregations extends CongregationListEvent {
  const LoadCongregations();

  @override
  List<Object?> get props => [];
}

class FavouriteCongregation extends CongregationListEvent {
  final String congregationId;
  final String userId;
  final bool? isFavourite;

  const FavouriteCongregation({
    required this.congregationId,
    required this.userId,
    this.isFavourite,
  });

  @override
  List<Object?> get props => [congregationId, userId, isFavourite];
}
