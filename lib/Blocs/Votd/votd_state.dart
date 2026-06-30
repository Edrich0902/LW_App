import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:lw_app/Extensions/context_l10n.dart';
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
  final String? arg;

  const VotdError(this.message, {this.arg});

  @override
  List<Object?> get props => [message, arg];

  String getLocalizedMessage(BuildContext context) {
    switch (message) {
      case 'votdErrorLoad':
        return context.l10n.votdErrorLoad(arg ?? '');
      case 'votdErrorNoTranslations':
        return context.l10n.votdErrorNoTranslations;
      default:
        return message;
    }
  }
}
