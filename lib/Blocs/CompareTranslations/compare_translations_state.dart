import 'package:equatable/equatable.dart';
import 'package:lw_app/Models/Bible/bible_models.dart';

abstract class CompareItemStatus extends Equatable {
  const CompareItemStatus();

  @override
  List<Object?> get props => [];
}

class CompareItemLoading extends CompareItemStatus {
  const CompareItemLoading();
}

class CompareItemData extends CompareItemStatus {
  final BibleContent content;
  const CompareItemData(this.content);

  @override
  List<Object?> get props => [content];
}

class CompareItemFailure extends CompareItemStatus {
  final String message;
  const CompareItemFailure(this.message);

  @override
  List<Object?> get props => [message];
}

abstract class CompareTranslationsState extends Equatable {
  const CompareTranslationsState();

  @override
  List<Object?> get props => [];
}

class CompareTranslationsInitial extends CompareTranslationsState {
  const CompareTranslationsInitial();
}

class CompareTranslationsLoaded extends CompareTranslationsState {
  final String reference;
  final String citation;
  final List<BibleVersion> allVersions;
  final Map<String, CompareItemStatus> resultsByVersionId;
  final String filterQuery;

  const CompareTranslationsLoaded({
    required this.reference,
    required this.citation,
    required this.allVersions,
    required this.resultsByVersionId,
    required this.filterQuery,
  });

  List<BibleVersion> get filteredVersions {
    if (filterQuery.isEmpty) return allVersions;
    final q = filterQuery.toLowerCase();
    return allVersions
        .where((v) =>
            v.name.toLowerCase().contains(q) ||
            v.language.toLowerCase().contains(q))
        .toList();
  }

  CompareTranslationsLoaded copyWith({
    String? reference,
    String? citation,
    List<BibleVersion>? allVersions,
    Map<String, CompareItemStatus>? resultsByVersionId,
    String? filterQuery,
  }) {
    return CompareTranslationsLoaded(
      reference: reference ?? this.reference,
      citation: citation ?? this.citation,
      allVersions: allVersions ?? this.allVersions,
      resultsByVersionId: resultsByVersionId ?? this.resultsByVersionId,
      filterQuery: filterQuery ?? this.filterQuery,
    );
  }

  @override
  List<Object?> get props =>
      [reference, citation, allVersions, resultsByVersionId, filterQuery];
}
