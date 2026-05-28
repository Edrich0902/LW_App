import 'package:equatable/equatable.dart';
import 'package:lw_app/Models/Bible/bible_models.dart';

abstract class VotdEvent extends Equatable {
  const VotdEvent();

  @override
  List<Object?> get props => [];
}

class LoadVotd extends VotdEvent {
  final BibleVersion? version;

  const LoadVotd({this.version});

  @override
  List<Object?> get props => [version];
}
