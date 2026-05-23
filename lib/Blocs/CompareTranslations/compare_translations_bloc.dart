import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Blocs/CompareTranslations/compare_translations_event.dart';
import 'package:lw_app/Blocs/CompareTranslations/compare_translations_state.dart';
import 'package:lw_app/Models/Bible/bible_models.dart';
import 'package:lw_app/Services/Bible/bible_service.dart';

class CompareTranslationsBloc
    extends Bloc<CompareTranslationsEvent, CompareTranslationsState> {
  final BibleService _bibleService;
  final Map<String, BibleContent> _cache = {};

  CompareTranslationsBloc({required BibleService bibleService})
      : _bibleService = bibleService,
        super(const CompareTranslationsInitial()) {
    on<LoadComparison>(_onLoadComparison);
    on<FilterComparison>(_onFilterComparison);
    on<RetryComparisonItem>(_onRetryComparisonItem);
  }

  Future<void> _onLoadComparison(
    LoadComparison event,
    Emitter<CompareTranslationsState> emit,
  ) async {
    final initialResults = <String, CompareItemStatus>{};
    for (final version in event.versions) {
      final cacheKey = '${version.id}|${event.reference}';
      if (_cache.containsKey(cacheKey)) {
        initialResults[version.id] = CompareItemData(_cache[cacheKey]!);
      } else {
        initialResults[version.id] = const CompareItemLoading();
      }
    }

    emit(CompareTranslationsLoaded(
      reference: event.reference,
      citation: event.citation,
      allVersions: event.versions,
      resultsByVersionId: Map.from(initialResults),
      filterQuery: '',
    ));

    final versionsToFetch = event.versions
        .where((v) => !_cache.containsKey('${v.id}|${event.reference}'))
        .toList();

    await Future.wait(
      versionsToFetch.map((v) => _fetchForVersion(v, event.reference, emit)),
    );
  }

  Future<void> _fetchForVersion(
    BibleVersion version,
    String reference,
    Emitter<CompareTranslationsState> emit,
  ) async {
    try {
      final content =
          await _bibleService.getPassageContent(version.id, reference);
      _cache['${version.id}|$reference'] = content;
      if (state is CompareTranslationsLoaded) {
        final current = state as CompareTranslationsLoaded;
        final updated =
            Map<String, CompareItemStatus>.from(current.resultsByVersionId)
              ..[version.id] = CompareItemData(content);
        emit(current.copyWith(resultsByVersionId: updated));
      }
    } catch (_) {
      if (state is CompareTranslationsLoaded) {
        final current = state as CompareTranslationsLoaded;
        final updated =
            Map<String, CompareItemStatus>.from(current.resultsByVersionId)
              ..[version.id] = const CompareItemFailure('Kon nie laai nie');
        emit(current.copyWith(resultsByVersionId: updated));
      }
    }
  }

  Future<void> _onFilterComparison(
    FilterComparison event,
    Emitter<CompareTranslationsState> emit,
  ) async {
    if (state is CompareTranslationsLoaded) {
      emit((state as CompareTranslationsLoaded)
          .copyWith(filterQuery: event.query));
    }
  }

  Future<void> _onRetryComparisonItem(
    RetryComparisonItem event,
    Emitter<CompareTranslationsState> emit,
  ) async {
    if (state is! CompareTranslationsLoaded) return;
    final current = state as CompareTranslationsLoaded;

    final version =
        current.allVersions.firstWhereOrNull((v) => v.id == event.versionId);
    if (version == null) return;

    final updated =
        Map<String, CompareItemStatus>.from(current.resultsByVersionId)
          ..[version.id] = const CompareItemLoading();
    emit(current.copyWith(resultsByVersionId: updated));

    await _fetchForVersion(version, current.reference, emit);
  }
}
