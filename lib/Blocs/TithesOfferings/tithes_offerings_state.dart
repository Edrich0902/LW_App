part of 'tithes_offerings_bloc.dart';

abstract class TithesOfferingsState extends Equatable {
  const TithesOfferingsState();
}

class TithesOfferingsInitial extends TithesOfferingsState {
  @override
  List<Object> get props => [];
}

class TithesOfferingsLoading extends TithesOfferingsState {
  @override
  List<Object> get props => [];
}

class TithesOfferingsSuccess extends TithesOfferingsState {
  final TithesOfferingsSettings settings;

  const TithesOfferingsSuccess({required this.settings});

  @override
  List<Object> get props => [settings];
}

class TithesOfferingsEmpty extends TithesOfferingsState {
  @override
  List<Object> get props => [];
}

class TithesOfferingsError extends TithesOfferingsState {
  final String error;

  const TithesOfferingsError(this.error);

  @override
  List<Object> get props => [error];
}
