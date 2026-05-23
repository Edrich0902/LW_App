import 'package:equatable/equatable.dart';
import 'package:lw_app/Models/Bible/bible_models.dart';

abstract class CompareTranslationsEvent extends Equatable {
  const CompareTranslationsEvent();

  @override
  List<Object?> get props => [];
}

class LoadComparison extends CompareTranslationsEvent {
  final String reference;
  final String citation;
  final List<BibleVersion> versions;

  const LoadComparison({
    required this.reference,
    required this.citation,
    required this.versions,
  });

  @override
  List<Object?> get props => [reference, citation, versions];
}

class FilterComparison extends CompareTranslationsEvent {
  final String query;
  const FilterComparison(this.query);

  @override
  List<Object?> get props => [query];
}

class RetryComparisonItem extends CompareTranslationsEvent {
  final String versionId;
  const RetryComparisonItem(this.versionId);

  @override
  List<Object?> get props => [versionId];
}
