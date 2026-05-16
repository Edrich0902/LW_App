import 'package:equatable/equatable.dart';

abstract class VotdEvent extends Equatable {
  const VotdEvent();

  @override
  List<Object?> get props => [];
}

class LoadVotd extends VotdEvent {}
