import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Extensions/context_l10n.dart';
import 'package:lw_app/Blocs/Bible/bible_bloc.dart';
import 'package:lw_app/Blocs/Bible/bible_event.dart';
import 'package:lw_app/Blocs/Bible/bible_state.dart';
import 'package:lw_app/Models/Bible/bible_models.dart';
import 'package:lw_app/Models/Bible/user_verse_interaction.dart';
import 'package:lw_app/Services/Bible/bible_interaction_service.dart';
import 'package:lw_app/Screens/Bible/bible.dart' show highlightColorFromString;
import 'package:lw_app/Themes/lwp_tokens.dart';
import 'package:lw_app/Utils/share_helper.dart';
import 'package:lw_app/Widgets/LwpLoader/lwp_loader.dart';
import 'package:lw_app/Widgets/LwpError/lwp_error.dart';
import 'package:lw_app/Widgets/LwpEmpty/lwp_empty.dart';
import 'package:lw_app/Widgets/LwpSnackbar/lwp_snackbar.dart';
import 'package:collection/collection.dart';

class SavedVersesPage extends StatefulWidget {
  const SavedVersesPage({super.key});

  @override
  State<SavedVersesPage> createState() => _SavedVersesPageState();
}

class _SavedVersesPageState extends State<SavedVersesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final BibleInteractionService _interactionService = BibleInteractionService();

  List<UserVerseInteraction> _savedVerses = [];
  List<UserVerseInteraction> _versesWithNotes = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final saved = await _interactionService.getSavedVerses();
      final notes = await _interactionService.getVersesWithNotes();

      setState(() {
        _savedVerses = saved;
        _versesWithNotes = notes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Kon nie data laai nie: $e';
        _isLoading = false;
      });
    }
  }

  Color? _getHighlightColor(BuildContext context, String? colorName) {
    return highlightColorFromString(colorName,
        dark: Theme.of(context).brightness == Brightness.dark);
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

      // Trigger LoadSpecificPassage in main Bloc
      context.read<BibleBloc>().add(LoadSpecificPassage(
            version: version,
            book: book,
            chapter: chapter,
          ));

      Navigator.pop(context);

      // Post-nav snackbar
      LwpSnackbar.showInfo(context,
          context.l10n.bibleNavigateTo(book.name, interaction.chapterNumber));
    } else {
      LwpSnackbar.showError(context, context.l10n.bibleBookUnavailable);
    }
  }

  Future<void> _deleteInteraction(UserVerseInteraction interaction,
      {bool clearBookmark = false, bool clearNote = false}) async {
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
            padding: const EdgeInsets.all(24.0),
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
                const SizedBox(height: 16),
                TextField(
                  controller: textController,
                  maxLines: 5,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: context.l10n.notesBodyPlaceholder,
                    border: OutlineInputBorder(
                      borderRadius: LwpRadii.lgAll,
                      borderSide: BorderSide(
                          color: theme.primaryColor.withValues(alpha: 0.5)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: LwpRadii.lgAll,
                      borderSide:
                          BorderSide(color: theme.primaryColor, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(modalContext),
                      child: Text(context.l10n.commonCancel,
                          style: TextStyle(color: theme.hintColor)),
                    ),
                    const SizedBox(width: 8),
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
                              context, context.l10n.savedVersesNoteUpdated);
                          _loadData();
                        } catch (e) {
                          if (!mounted) return;
                          LwpSnackbar.showError(
                              context, context.l10n.savedVersesNoteSaveError);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: LwpRadii.lgAll,
                        ),
                      ),
                      child: Text(context.l10n.commonSave,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
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
    final bibleState = context.read<BibleBloc>().state;
    String bookName = interaction.bookId;
    if (bibleState is BibleLoaded) {
      final bookObj =
          bibleState.books.firstWhereOrNull((b) => b.id == interaction.bookId);
      if (bookObj != null) bookName = bookObj.name;
    }

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

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.savedVersesTitle),
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.primaryColor,
          unselectedLabelColor: theme.hintColor,
          indicatorColor: theme.primaryColor,
          tabs: [
            Tab(text: context.l10n.savedVersesSavedTab),
            Tab(text: context.l10n.savedVersesMyNotesTab),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: LwpLoader(message: context.l10n.savedVersesLoading))
          : _errorMessage != null
              ? LwpError(message: _errorMessage!, onRetry: _loadData)
              : TabBarView(
                  controller: _tabController,
                  children: [
                    // Saved Verses Tab
                    _savedVerses.isEmpty
                        ? LwpEmpty(
                            message: context.l10n.savedVersesEmpty,
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16.0),
                            itemCount: _savedVerses.length,
                            itemBuilder: (context, index) {
                              final item = _savedVerses[index];
                              final color = _getHighlightColor(
                                  context, item.highlightColor);
                              final bibleState =
                                  context.read<BibleBloc>().state;
                              String bookName = item.bookId;
                              if (bibleState is BibleLoaded) {
                                final bookObj = bibleState.books
                                    .firstWhereOrNull(
                                        (b) => b.id == item.bookId);
                                if (bookObj != null) bookName = bookObj.name;
                              }

                              return Card(
                                margin: const EdgeInsets.only(
                                    bottom: LwpSpacing.sm),
                                child: InkWell(
                                  onTap: () => _navigateToVerse(item),
                                  borderRadius: LwpRadii.lgAll,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Header: Citation, Highlight color and Bookmark tag
                                        Row(
                                          children: [
                                            Text(
                                              '$bookName ${item.chapterNumber}:${item.verseNumber}',
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: theme.primaryColor,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              '(${item.versionId.toUpperCase()})',
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  color: theme.hintColor),
                                            ),
                                            const Spacer(),
                                            if (item.highlightColor != null)
                                              Container(
                                                width: 16,
                                                height: 16,
                                                decoration: BoxDecoration(
                                                  color: color,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                      color: Colors.white,
                                                      width: 1.5),
                                                ),
                                              ),
                                            if (item.isBookmarked) ...[
                                              const SizedBox(width: 8),
                                              Icon(Icons.bookmark,
                                                  size: 16,
                                                  color: theme.primaryColor),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          context.l10n.savedVersesTapToView,
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontStyle: FontStyle.italic,
                                              color: theme.hintColor),
                                        ),
                                        const Divider(),
                                        // Actions: delete bookmark
                                        if (item.isBookmarked)
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              TextButton.icon(
                                                onPressed: () =>
                                                    _deleteInteraction(item,
                                                        clearBookmark: true),
                                                icon: const Icon(
                                                    Icons.bookmark_remove,
                                                    size: 16,
                                                    color: Colors.redAccent),
                                                label: Text(
                                                    context.l10n
                                                        .savedVersesRemoveBookmark,
                                                    style: TextStyle(
                                                        color: Colors.redAccent,
                                                        fontSize: 12)),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                    // Notes Tab
                    _versesWithNotes.isEmpty
                        ? LwpEmpty(
                            message: context.l10n.savedVersesNotesEmpty,
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16.0),
                            itemCount: _versesWithNotes.length,
                            itemBuilder: (context, index) {
                              final item = _versesWithNotes[index];
                              final bibleState =
                                  context.read<BibleBloc>().state;
                              String bookName = item.bookId;
                              if (bibleState is BibleLoaded) {
                                final bookObj = bibleState.books
                                    .firstWhereOrNull(
                                        (b) => b.id == item.bookId);
                                if (bookObj != null) bookName = bookObj.name;
                              }

                              return Card(
                                margin: const EdgeInsets.only(
                                    bottom: LwpSpacing.sm),
                                child: Padding(
                                  padding: const EdgeInsets.all(LwpSpacing.md),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          InkWell(
                                            onTap: () => _navigateToVerse(item),
                                            child: Row(
                                              children: [
                                                Text(
                                                  '$bookName ${item.chapterNumber}:${item.verseNumber}',
                                                  style: theme
                                                      .textTheme.bodyMedium
                                                      ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: theme.primaryColor,
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Icon(Icons.open_in_new,
                                                    size: 12,
                                                    color: theme.hintColor),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            item.updatedAt != null
                                                ? item.updatedAt!
                                                    .substring(0, 10)
                                                : '',
                                            style: TextStyle(
                                                fontSize: 11,
                                                color: theme.hintColor),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      // Note Content Box
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(14.0),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme
                                              .surfaceContainerHighest,
                                          borderRadius: LwpRadii.smAll,
                                        ),
                                        child: Text(
                                          item.note ?? '',
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                            height: 1.5,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.share,
                                                size: 20,
                                                color: theme.hintColor),
                                            onPressed: () => _shareNote(item),
                                            tooltip: context
                                                .l10n.savedVersesShareNote,
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.edit,
                                                size: 20,
                                                color: theme.hintColor),
                                            onPressed: () => _editNote(item),
                                            tooltip: context
                                                .l10n.savedVersesEditNote,
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                                Icons.delete_outline,
                                                size: 20,
                                                color: Colors.redAccent),
                                            onPressed: () => _deleteInteraction(
                                                item,
                                                clearNote: true),
                                            tooltip: context
                                                .l10n.savedVersesDeleteNote,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ],
                ),
    );
  }
}
