import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Blocs/CompareTranslations/compare_translations_bloc.dart';
import 'package:lw_app/Blocs/CompareTranslations/compare_translations_event.dart';
import 'package:lw_app/Blocs/CompareTranslations/compare_translations_state.dart';
import 'package:lw_app/Models/Bible/bible_models.dart';

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
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Vergelyk vertalings',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(20),
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
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
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
                    hintText: 'Soek vertaling...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(
                          color: theme.primaryColor.withValues(alpha: 0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(color: theme.dividerColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
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
                          'Geen vertalings gevind nie',
                          style: TextStyle(color: Colors.grey[600]),
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
            'Kon nie laai nie',
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Probeer weer'),
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
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: theme.dividerColor.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    version.name,
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
                    borderRadius: BorderRadius.circular(12),
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
