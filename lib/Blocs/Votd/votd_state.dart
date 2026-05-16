import 'package:equatable/equatable.dart';
import 'package:lw_app/Models/Bible/votd_model.dart';

abstract class VotdState extends Equatable {
  const VotdState();

  @override
  List<Object?> get props => [];
}

class VotdInitial extends VotdState {}

class VotdLoading extends VotdState {}

class VotdSuccess extends VotdState {
  final Votd votd;

  const VotdSuccess(this.votd);

  @override
  List<Object?> get props => [votd];
}

class VotdError extends VotdState {
  final String message;

  const VotdError(this.message);

  @override
  List<Object?> get props => [message];
}
