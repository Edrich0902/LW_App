import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Blocs/Bible/bible_bloc.dart';
import 'package:lw_app/Blocs/Bible/bible_event.dart';
import 'package:lw_app/Blocs/Bible/bible_state.dart';
import 'package:lw_app/Models/Bible/bible_models.dart';
import 'package:lw_app/Models/Bible/user_verse_interaction.dart';
import 'package:lw_app/Services/Bible/bible_interaction_service.dart';
import 'package:lw_app/Screens/Bible/bible.dart' show highlightColorFromString;
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
      LwpSnackbar.showInfo(
          context, 'Navigeer na ${book.name} ${interaction.chapterNumber}');
    } else {
      LwpSnackbar.showError(
          context, 'Boek nie beskikbaar in huidige vertaling nie.');
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
      LwpSnackbar.showSuccess(context, 'Item suksesvol opgedateer');
      _loadData();
    } catch (e) {
      if (!mounted) return;
      LwpSnackbar.showError(context, 'Fout met opdatering: $e');
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
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
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
                      'Wysig Bybelnota',
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
                    hintText: 'Skryf jou gedagtes hier...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                          color: theme.primaryColor.withValues(alpha: 0.5)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
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
                      child: const Text('Kanselleer',
                          style: TextStyle(color: Colors.grey)),
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
                          Navigator.pop(modalContext);
                          if (!mounted) return;
                          LwpSnackbar.showSuccess(context, 'Nota opgedateer');
                          _loadData();
                        } catch (e) {
                          if (!mounted) return;
                          LwpSnackbar.showError(
                              context, 'Kon nie nota stoor nie');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Stoor',
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
        'My Bybelnota vir $bookName ${interaction.chapterNumber}:${interaction.verseNumber}:\n\n"${interaction.note}"\n\nGedeel via LW App';
    await ShareHelper.shareText(
      context,
      text: shareText,
      subject:
          'Bybelnota vir $bookName ${interaction.chapterNumber}:${interaction.verseNumber}',
      clipboardMessage: 'Nota gekopieër na klembord',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bybel Argief'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: theme.primaryColor,
          tabs: const [
            Tab(text: 'Bewaarde Verse'),
            Tab(text: 'My Notas'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: LwpLoader(message: 'Laai argief...'))
          : _errorMessage != null
              ? LwpError(message: _errorMessage!, onRetry: _loadData)
              : TabBarView(
                  controller: _tabController,
                  children: [
                    // Saved Verses Tab
                    _savedVerses.isEmpty
                        ? const LwpEmpty(
                            message:
                                'Jy het nog geen verse gestoor of verlig nie.')
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
                                elevation: 0,
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                  side: BorderSide(
                                    color: Colors.grey.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: InkWell(
                                  onTap: () => _navigateToVerse(item),
                                  borderRadius: BorderRadius.circular(16.0),
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
                                              style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey),
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
                                        const Text(
                                          'Tik om in Bybel te sien...',
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontStyle: FontStyle.italic,
                                              color: Colors.grey),
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
                                                label: const Text(
                                                    'Verwyder Boekmerk',
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
                        ? const LwpEmpty(
                            message:
                                'Jy het nog geen persoonlike Bybelnotas bygevoeg nie.')
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
                                elevation: 0,
                                margin: const EdgeInsets.only(bottom: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      24.0), // Rounded corners of 24.0 for card designs
                                  side: BorderSide(
                                    color: Colors.grey.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
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
                                                const Icon(Icons.open_in_new,
                                                    size: 12,
                                                    color: Colors.grey),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            item.updatedAt != null
                                                ? item.updatedAt!
                                                    .substring(0, 10)
                                                : '',
                                            style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      // Note Content Box
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(14.0),
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? Colors.grey[900]
                                              : Colors.grey[100],
                                          borderRadius:
                                              BorderRadius.circular(16.0),
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
                                            icon: const Icon(Icons.share,
                                                size: 20, color: Colors.grey),
                                            onPressed: () => _shareNote(item),
                                            tooltip: 'Deel Nota',
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.edit,
                                                size: 20, color: Colors.grey),
                                            onPressed: () => _editNote(item),
                                            tooltip: 'Wysig Nota',
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                                Icons.delete_outline,
                                                size: 20,
                                                color: Colors.redAccent),
                                            onPressed: () => _deleteInteraction(
                                                item,
                                                clearNote: true),
                                            tooltip: 'Verwyder Nota',
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
