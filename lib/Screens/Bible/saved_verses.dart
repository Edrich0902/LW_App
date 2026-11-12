import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Blocs/Bible/bible_bloc.dart';
import 'package:lw_app/Blocs/Bible/bible_event.dart';
import 'package:lw_app/Blocs/Bible/bible_state.dart';
import 'package:lw_app/Extensions/context_l10n.dart';
import 'package:lw_app/Models/Bible/bible_models.dart';
import 'package:lw_app/Models/Bible/user_verse_interaction.dart';
import 'package:lw_app/Services/Bible/bible_interaction_service.dart';
import 'package:lw_app/Services/Bible/bible_service.dart';
import 'package:lw_app/Screens/Bible/bible.dart' show highlightColorFromString;
import 'package:lw_app/Themes/lwp_tokens.dart';
import 'package:lw_app/Utils/share_helper.dart';
import 'package:lw_app/Widgets/Glass/lwp_chrome_scaffold.dart';
import 'package:lw_app/Widgets/LwpEmpty/lwp_empty.dart';
import 'package:lw_app/Widgets/LwpError/lwp_error.dart';
import 'package:lw_app/Widgets/LwpListEntrance/lwp_list_entrance.dart';
import 'package:lw_app/Widgets/LwpSkeleton/lwp_skeleton.dart';
import 'package:lw_app/Widgets/LwpSnackbar/lwp_snackbar.dart';

class SavedVersesPage extends StatefulWidget {
  const SavedVersesPage({super.key});

  @override
  State<SavedVersesPage> createState() => _SavedVersesPageState();
}

class _SavedVersesPageState extends State<SavedVersesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final BibleInteractionService _interactionService = BibleInteractionService();
  final BibleService _bibleService = BibleService();

  List<UserVerseInteraction> _savedVerses = [];
  List<UserVerseInteraction> _versesWithNotes = [];
  final Map<String, String> _verseTextByKey = {};
  bool _isLoading = true;
  String? _errorMessage;
  final _listEntrance = LwpListEntranceController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _listEntrance.dispose();
    super.dispose();
  }

  String _verseKey(UserVerseInteraction item) =>
      '${item.versionId}|${item.bookId}|${item.chapterNumber}|${item.verseNumber}';

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final saved = await _interactionService.getSavedVerses();
      final notes = await _interactionService.getVersesWithNotes();

      if (!mounted) return;
      setState(() {
        _savedVerses = saved;
        _versesWithNotes = notes;
        _isLoading = false;
      });
      _loadVersePreviews([...saved, ...notes]);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Kon nie data laai nie: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadVersePreviews(List<UserVerseInteraction> items) async {
    final uniqueChapters = <String, UserVerseInteraction>{};
    for (final item in items) {
      final chapterKey =
          '${item.versionId}|${item.bookId}|${item.chapterNumber}';
      uniqueChapters.putIfAbsent(chapterKey, () => item);
    }

    for (final item in uniqueChapters.values) {
      try {
        final chapterId = '${item.bookId}.${item.chapterNumber}';
        final content = await _bibleService.getChapterContent(
          item.versionId,
          item.bookId,
          chapterId,
        );
        final verses = BibleParser.parseChapterHtml(
          rawHtml: content.rawHtml,
          bookId: item.bookId,
          chapterId: chapterId,
        );
        if (!mounted) return;
        setState(() {
          for (final verse in verses) {
            final key =
                '${item.versionId}|${item.bookId}|${item.chapterNumber}|${verse.verseNumber}';
            _verseTextByKey[key] = verse.text;
          }
        });
      } catch (_) {
        // Keep citation-only fallback if preview fetch fails.
      }
    }
  }

  Color? _getHighlightColor(BuildContext context, String? colorName) {
    return highlightColorFromString(
      colorName,
      dark: Theme.of(context).brightness == Brightness.dark,
    );
  }

  String _bookName(UserVerseInteraction item) {
    final bibleState = context.read<BibleBloc>().state;
    if (bibleState is BibleLoaded) {
      final bookObj =
          bibleState.books.firstWhereOrNull((b) => b.id == item.bookId);
      if (bookObj != null) return bookObj.name;
    }
    return item.bookId;
  }

  void _navigateToVerse(UserVerseInteraction interaction) {
    final bibleState = context.read<BibleBloc>().state;
    if (bibleState is! BibleLoaded) return;

    final version = bibleState.versions
            .firstWhereOrNull((v) => v.id == interaction.versionId) ??
        bibleState.currentVersion;
    final book =
        bibleState.books.firstWhereOrNull((b) => b.id == interaction.bookId);

    if (book != null) {
      final chapter = BibleChapter(
        id: '${interaction.bookId}.${interaction.chapterNumber}',
        number: interaction.chapterNumber,
      );

      context.read<BibleBloc>().add(LoadSpecificPassage(
            version: version,
            book: book,
            chapter: chapter,
            focusVerseNumber: interaction.verseNumber,
          ));

      Navigator.pop(context);

      LwpSnackbar.showInfo(
        context,
        context.l10n.bibleNavigateTo(book.name, interaction.chapterNumber),
      );
    } else {
      LwpSnackbar.showError(context, context.l10n.bibleBookUnavailable);
    }
  }

  Future<void> _deleteInteraction(
    UserVerseInteraction interaction, {
    bool clearBookmark = false,
    bool clearNote = false,
  }) async {
    try {
      await _interactionService.upsertInteraction(
        versionId: interaction.versionId,
        bookId: interaction.bookId,
        chapterNumber: interaction.chapterNumber,
        verseNumber: interaction.verseNumber,
        isBookmarked: clearBookmark ? false : null,
        clearNote: clearNote,
      );

      if (!mounted) return;
      LwpSnackbar.showSuccess(context, context.l10n.savedVersesItemUpdated);
      _loadData();
    } catch (e) {
      if (!mounted) return;
      LwpSnackbar.showError(context, context.l10n.savedVersesUpdateError('$e'));
    }
  }

  void _editNote(UserVerseInteraction interaction) {
    final textController = TextEditingController(text: interaction.note);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        final theme = Theme.of(context);
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(modalContext).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: LwpRadii.lgTop,
            ),
            padding: const EdgeInsets.all(LwpSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.l10n.savedVersesEditBibleNote,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(modalContext),
                      child: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: LwpSpacing.md),
                TextField(
                  controller: textController,
                  maxLines: 5,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: context.l10n.notesBodyPlaceholder,
                    border: OutlineInputBorder(
                      borderRadius: LwpRadii.lgAll,
                      borderSide: BorderSide(
                        color: theme.primaryColor.withValues(alpha: 0.5),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: LwpRadii.lgAll,
                      borderSide: BorderSide(
                        color: theme.primaryColor,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: LwpSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(modalContext),
                      child: Text(
                        context.l10n.commonCancel,
                        style: TextStyle(color: theme.hintColor),
                      ),
                    ),
                    const SizedBox(width: LwpSpacing.xs),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          await _interactionService.upsertInteraction(
                            versionId: interaction.versionId,
                            bookId: interaction.bookId,
                            chapterNumber: interaction.chapterNumber,
                            verseNumber: interaction.verseNumber,
                            note: textController.text,
                          );
                          if (!mounted || !modalContext.mounted) return;
                          Navigator.pop(modalContext);
                          LwpSnackbar.showSuccess(
                            context,
                            context.l10n.savedVersesNoteUpdated,
                          );
                          _loadData();
                        } catch (_) {
                          if (!mounted) return;
                          LwpSnackbar.showError(
                            context,
                            context.l10n.savedVersesNoteSaveError,
                          );
                        }
                      },
                      child: Text(context.l10n.commonSave),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _shareNote(UserVerseInteraction interaction) async {
    final bookName = _bookName(interaction);
    final shareText =
        '${context.l10n.savedVersesMyBibleNote} $bookName ${interaction.chapterNumber}:${interaction.verseNumber}:\n\n"${interaction.note}"\n\n${context.l10n.bibleSharedViaApp}';
    await ShareHelper.shareText(
      context,
      text: shareText,
      subject:
          '${context.l10n.bibleNoteTitle} $bookName ${interaction.chapterNumber}:${interaction.verseNumber}',
      clipboardMessage: context.l10n.savedVersesNoteCopied,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LwpChromeScaffold(
      title: context.l10n.savedVersesTitle,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              LwpSpacing.md,
              LwpSpacing.sm,
              LwpSpacing.md,
              LwpSpacing.xs,
            ),
            child: _SegmentedTabs(
              controller: _tabController,
              labels: [
                context.l10n.savedVersesSavedTab,
                context.l10n.savedVersesMyNotesTab,
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? LwpSkeletonList.text(itemCount: 5)
                : _errorMessage != null
                    ? LwpError(message: _errorMessage!, onRetry: _loadData)
                    : LwpListEntranceScope(
                        controller: _listEntrance,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildSavedList(theme),
                            _buildNotesList(theme),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedList(ThemeData theme) {
    if (_savedVerses.isEmpty) {
      return LwpEmpty(message: context.l10n.savedVersesEmpty);
    }

    return RefreshIndicator(
      onRefresh: () async {
        _listEntrance.bump();
        await _loadData();
      },
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          LwpSpacing.md,
          LwpSpacing.xs,
          LwpSpacing.md,
          LwpSpacing.xl,
        ),
        itemCount: _savedVerses.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          thickness: 1,
          color: theme.dividerColor.withValues(alpha: 0.45),
        ),
        itemBuilder: (context, index) {
          final item = _savedVerses[index];
          final id = item.id ??
              '${item.bookId}-${item.chapterNumber}-${item.verseNumber}';
          return LwpListEntrance(
            id: id,
            child: _ManuscriptVerseRow(
              citation:
                  '${_bookName(item)} ${item.chapterNumber}:${item.verseNumber}',
              versionLabel: item.versionId.toUpperCase(),
              verseText: _verseTextByKey[_verseKey(item)],
              note: item.note,
              highlightColor: _getHighlightColor(context, item.highlightColor),
              isBookmarked: item.isBookmarked,
              onRead: () => _navigateToVerse(item),
              onDelete: item.isBookmarked
                  ? () => _deleteInteraction(item, clearBookmark: true)
                  : null,
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotesList(ThemeData theme) {
    if (_versesWithNotes.isEmpty) {
      return LwpEmpty(message: context.l10n.savedVersesNotesEmpty);
    }

    return RefreshIndicator(
      onRefresh: () async {
        _listEntrance.bump();
        await _loadData();
      },
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          LwpSpacing.md,
          LwpSpacing.xs,
          LwpSpacing.md,
          LwpSpacing.xl,
        ),
        itemCount: _versesWithNotes.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          thickness: 1,
          color: theme.dividerColor.withValues(alpha: 0.45),
        ),
        itemBuilder: (context, index) {
          final item = _versesWithNotes[index];
          final id = item.id ??
              'note-${item.bookId}-${item.chapterNumber}-${item.verseNumber}';
          return LwpListEntrance(
            id: id,
            child: _ManuscriptVerseRow(
              citation:
                  '${_bookName(item)} ${item.chapterNumber}:${item.verseNumber}',
              versionLabel: item.versionId.toUpperCase(),
              verseText: _verseTextByKey[_verseKey(item)],
              note: item.note,
              highlightColor: _getHighlightColor(context, item.highlightColor),
              isBookmarked: item.isBookmarked,
              onRead: () => _navigateToVerse(item),
              onShare: () => _shareNote(item),
              onEdit: () => _editNote(item),
              onDelete: () => _deleteInteraction(item, clearNote: true),
            ),
          );
        },
      ),
    );
  }
}

class _SegmentedTabs extends StatelessWidget {
  const _SegmentedTabs({
    required this.controller,
    required this.labels,
  });

  final TabController controller;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.35),
            borderRadius: LwpRadii.mdAll,
            border: Border.all(
              color: theme.dividerColor.withValues(alpha: 0.55),
            ),
          ),
          child: Row(
            children: [
              for (var i = 0; i < labels.length; i++) ...[
                if (i > 0) const SizedBox(width: 4),
                Expanded(
                  child: Material(
                    color: controller.index == i
                        ? theme.colorScheme.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(LwpRadii.xs),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(LwpRadii.xs),
                      onTap: () => controller.animateTo(i),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: LwpSpacing.sm,
                        ),
                        child: Text(
                          labels[i],
                          textAlign: TextAlign.center,
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: controller.index == i
                                ? theme.colorScheme.onPrimary
                                : theme.hintColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _ManuscriptVerseRow extends StatelessWidget {
  const _ManuscriptVerseRow({
    required this.citation,
    required this.versionLabel,
    required this.onRead,
    this.verseText,
    this.note,
    this.highlightColor,
    this.isBookmarked = false,
    this.onShare,
    this.onEdit,
    this.onDelete,
  });

  final String citation;
  final String versionLabel;
  final String? verseText;
  final String? note;
  final Color? highlightColor;
  final bool isBookmarked;
  final VoidCallback onRead;
  final VoidCallback? onShare;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final railColor = highlightColor ??
        theme.dividerColor.withValues(alpha: 0.55);

    return InkWell(
      onTap: onRead,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: LwpSpacing.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 4,
              constraints: const BoxConstraints(minHeight: 48),
              decoration: BoxDecoration(
                color: railColor,
                borderRadius: BorderRadius.circular(LwpRadii.pill),
              ),
            ),
            const SizedBox(width: LwpSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          citation,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: LwpSpacing.xs),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: LwpSpacing.xs,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(LwpRadii.pill),
                        ),
                        child: Text(
                          versionLabel,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (isBookmarked) ...[
                        const SizedBox(width: LwpSpacing.xs),
                        Icon(
                          Icons.bookmark,
                          size: 14,
                          color: theme.colorScheme.primary,
                        ),
                      ],
                    ],
                  ),
                  if ((verseText ?? '').trim().isNotEmpty) ...[
                    const SizedBox(height: LwpSpacing.xs),
                    Text(
                      verseText!,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: 15,
                        height: 1.55,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.1,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if ((note ?? '').trim().isNotEmpty) ...[
                    const SizedBox(height: LwpSpacing.xs),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(left: LwpSpacing.sm),
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: theme.colorScheme.primary,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Text(
                        note!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.hintColor,
                          height: 1.4,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: LwpSpacing.sm),
                  Wrap(
                    spacing: LwpSpacing.xs,
                    runSpacing: LwpSpacing.xs,
                    children: [
                      _GhostAction(
                        label: context.l10n.savedVersesReadAction,
                        onTap: onRead,
                      ),
                      if (onShare != null)
                        _GhostAction(
                          label: context.l10n.commonShare,
                          onTap: onShare!,
                        ),
                      if (onEdit != null)
                        _GhostAction(
                          label: context.l10n.savedVersesEditNote,
                          onTap: onEdit!,
                        ),
                      if (onDelete != null)
                        _GhostAction(
                          label: context.l10n.commonDelete,
                          onTap: onDelete!,
                          danger: true,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GhostAction extends StatelessWidget {
  const _GhostAction({
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = danger ? Colors.redAccent : theme.hintColor;

    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(
          color: danger
              ? Colors.redAccent.withValues(alpha: 0.35)
              : theme.dividerColor.withValues(alpha: 0.6),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: LwpSpacing.sm,
          vertical: LwpSpacing.xxs,
        ),
        visualDensity: VisualDensity.compact,
        shape: const StadiumBorder(),
      ),
      child: Text(label),
    );
  }
}
