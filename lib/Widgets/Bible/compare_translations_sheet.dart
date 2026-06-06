import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Extensions/context_l10n.dart';
import 'package:lw_app/Blocs/CompareTranslations/compare_translations_bloc.dart';
import 'package:lw_app/Blocs/CompareTranslations/compare_translations_event.dart';
import 'package:lw_app/Blocs/CompareTranslations/compare_translations_state.dart';
import 'package:lw_app/Models/Bible/bible_models.dart';
import 'package:lw_app/Themes/lwp_tokens.dart';
import 'package:lw_app/Widgets/LwpBottomSheet/lwp_bottom_sheet.dart';

class CompareTranslationsSheet extends StatefulWidget {
  final BibleBook book;
  final BibleChapter chapter;

  const CompareTranslationsSheet({
    super.key,
    required this.book,
    required this.chapter,
  });

  @override
  State<CompareTranslationsSheet> createState() =>
      _CompareTranslationsSheetState();
}

class _CompareTranslationsSheetState extends State<CompareTranslationsSheet> {
  final TextEditingController _filterController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _filterController.dispose();
    super.dispose();
  }

  void _onFilterChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 150), () {
      context.read<CompareTranslationsBloc>().add(FilterComparison(query));
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: LwpRadii.lgTop,
          ),
          child: Column(
            children: [
              const SizedBox(height: LwpSpacing.xs),
              const LwpSheetHandle(),
              const SizedBox(height: LwpSpacing.md),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.l10n.bibleCompareTranslationsTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(LwpRadii.pill),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(Icons.close, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              BlocBuilder<CompareTranslationsBloc, CompareTranslationsState>(
                builder: (context, state) {
                  if (state is! CompareTranslationsLoaded) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      state.citation,
                      style: TextStyle(color: theme.hintColor, fontSize: 13),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: TextField(
                  controller: _filterController,
                  onChanged: _onFilterChanged,
                  decoration: InputDecoration(
                    hintText: context.l10n.bibleSearchTranslationHint,
                    prefixIcon: const Icon(Icons.search, size: 20),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: LwpRadii.lgAll,
                      borderSide: BorderSide(
                          color: theme.primaryColor.withValues(alpha: 0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: LwpRadii.lgAll,
                      borderSide: BorderSide(color: theme.dividerColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: LwpRadii.lgAll,
                      borderSide:
                          BorderSide(color: theme.primaryColor, width: 2),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: BlocBuilder<CompareTranslationsBloc,
                    CompareTranslationsState>(
                  builder: (context, state) {
                    if (state is! CompareTranslationsLoaded) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final versions = state.filteredVersions;
                    if (versions.isEmpty) {
                      return Center(
                        child: Text(
                          context.l10n.bibleNoTranslationsFound,
                          style: TextStyle(color: theme.hintColor),
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                      itemCount: versions.length,
                      itemBuilder: (context, index) {
                        final version = versions[index];
                        final status = state.resultsByVersionId[version.id] ??
                            const CompareItemLoading();
                        return _TranslationCard(
                          version: version,
                          status: status,
                          book: widget.book,
                          chapter: widget.chapter,
                          onRetry: () => context
                              .read<CompareTranslationsBloc>()
                              .add(RetryComparisonItem(version.id)),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TranslationCard extends StatelessWidget {
  final BibleVersion version;
  final CompareItemStatus status;
  final BibleBook book;
  final BibleChapter chapter;
  final VoidCallback onRetry;

  const _TranslationCard({
    required this.version,
    required this.status,
    required this.book,
    required this.chapter,
    required this.onRetry,
  });

  Widget _buildBody(BuildContext context) {
    final theme = Theme.of(context);
    if (status is CompareItemLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    if (status is CompareItemFailure) {
      return Column(
        children: [
          Text(
            context.l10n.bibleCompareLoadFailed,
            style: TextStyle(color: theme.hintColor, fontSize: 13),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 16),
            label: Text(context.l10n.commonRetry),
            style: TextButton.styleFrom(
              foregroundColor: theme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            ),
          ),
        ],
      );
    }
    final content = (status as CompareItemData).content;
    final verses = BibleParser.parseChapterHtml(
      rawHtml: content.rawHtml,
      bookId: book.id,
      chapterId: chapter.id,
    );
    final text = verses.isEmpty
        ? content.rawHtml.replaceAll(RegExp(r'<[^>]*>'), '').trim()
        : verses.map((v) => '${v.verseNumber} ${v.text}').join('  ');
    return Text(
      text,
      style: theme.textTheme.bodyMedium?.copyWith(height: 1.7),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: LwpSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    version.displayName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(LwpRadii.pill),
                  ),
                  child: Text(
                    version.language.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildBody(context),
          ],
        ),
      ),
    );
  }
}
