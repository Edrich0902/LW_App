import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Blocs/Bible/bible_event.dart';
import 'package:lw_app/Blocs/Bible/bible_state.dart';
import 'package:lw_app/Models/Bible/bible_models.dart';
import 'package:lw_app/Services/Bible/bible_service.dart';
import 'package:lw_app/Services/Bible/bible_interaction_service.dart';
import 'package:collection/collection.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BibleBloc extends Bloc<BibleEvent, BibleState> {
  static const String _lastVersionIdKey = 'last_bible_version_id';

  final BibleService bibleService;
  final BibleInteractionService interactionService;

  BibleBloc({
    required this.bibleService,
    BibleInteractionService? interactionService,
  })  : interactionService = interactionService ?? BibleInteractionService(),
        super(BibleLoading()) {
    on<LoadBibleInitial>(_onLoadBibleInitial);
    on<LoadSpecificPassage>(_onLoadSpecificPassage);
    on<ChangeVersion>(_onChangeVersion);
    on<ChangeBook>(_onChangeBook);
    on<ChangeChapter>(_onChangeChapter);
    on<NavigateNextChapter>(_onNavigateNextChapter);
    on<NavigatePreviousChapter>(_onNavigatePreviousChapter);
    on<LoadChapterInteractions>(_onLoadChapterInteractions);
    on<ToggleVerseSelection>(_onToggleVerseSelection);
    on<ClearSelection>(_onClearSelection);
    on<HighlightSelectedVerses>(_onHighlightSelectedVerses);
    on<ToggleBookmarkSelected>(_onToggleBookmarkSelected);
    on<SaveNoteForSelected>(_onSaveNoteForSelected);
    on<ClearVerseFocus>(_onClearVerseFocus);
  }

  Future<void> _saveLastVersionId(String versionId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastVersionIdKey, versionId);
  }

  Future<BibleVersion> _getInitialVersion(List<BibleVersion> versions) async {
    final prefs = await SharedPreferences.getInstance();
    final lastVersionId = prefs.getString(_lastVersionIdKey);

    if (lastVersionId != null) {
      final savedVersion =
          versions.firstWhereOrNull((version) => version.id == lastVersionId);
      if (savedVersion != null) return savedVersion;
    }

    return versions.firstWhereOrNull((v) => v.name.contains('NIV')) ??
        versions.first;
  }

  Future<List<BibleVerse>> _getParsedAndMergedVerses({
    required String versionId,
    required String bookId,
    required String chapterId,
    required String rawHtml,
  }) async {
    final parsed = BibleParser.parseChapterHtml(
      rawHtml: rawHtml,
      bookId: bookId,
      chapterId: chapterId,
    );

    final chapterNum =
        chapterId.contains('.') ? chapterId.split('.').last : chapterId;

    try {
      final interactions = await interactionService.getInteractionsForChapter(
        versionId: versionId,
        bookId: bookId,
        chapterNumber: chapterNum,
      );

      final interactionMap = {
        for (var inter in interactions) inter.verseNumber: inter
      };

      return parsed.map((verse) {
        final inter = interactionMap[verse.verseNumber];
        if (inter != null) {
          return verse.copyWith(
            highlightColor: inter.highlightColor,
            isBookmarked: inter.isBookmarked,
            note: inter.note,
          );
        }
        return verse;
      }).toList();
    } catch (e) {
      return parsed;
    }
  }

  Future<void> _onLoadSpecificPassage(
      LoadSpecificPassage event, Emitter<BibleState> emit) async {
    emit(BibleLoading());
    try {
      final allVersions =
          await bibleService.getVersions(languages: ['en', 'af']);
      final books = await bibleService.getBooks(event.version.id);
      final chapters =
          await bibleService.getChapters(event.version.id, event.book.id);
      final content = await bibleService.getChapterContent(
          event.version.id, event.book.id, event.chapter.id);

      final verses = await _getParsedAndMergedVerses(
        versionId: event.version.id,
        bookId: event.book.id,
        chapterId: event.chapter.id,
        rawHtml: content.rawHtml,
      );

      await _saveLastVersionId(event.version.id);

      emit(BibleLoaded(
        currentVersion: event.version,
        currentBook: event.book,
        currentChapter: event.chapter,
        content: content,
        versions: allVersions,
        books: books,
        chapters: chapters,
        verses: verses,
        focusVerseNumber: event.focusVerseNumber,
      ));
    } catch (e) {
      emit(BibleError('bibleErrorLoadSpecificVerse', arg: e.toString()));
    }
  }

  void _onClearVerseFocus(ClearVerseFocus event, Emitter<BibleState> emit) {
    if (state is! BibleLoaded) return;
    emit((state as BibleLoaded).copyWith(clearFocusVerse: true));
  }

  Future<void> _onNavigateNextChapter(
      NavigateNextChapter event, Emitter<BibleState> emit) async {
    if (state is! BibleLoaded) return;
    final currentState = state as BibleLoaded;

    final currentIndex = currentState.chapters
        .indexWhere((c) => c.id == currentState.currentChapter.id);

    if (currentIndex < currentState.chapters.length - 1) {
      add(ChangeChapter(currentState.chapters[currentIndex + 1]));
    } else {
      final currentBookIndex = currentState.books
          .indexWhere((b) => b.id == currentState.currentBook.id);
      if (currentBookIndex < currentState.books.length - 1) {
        add(ChangeBook(currentState.books[currentBookIndex + 1]));
      }
    }
  }

  Future<void> _onNavigatePreviousChapter(
      NavigatePreviousChapter event, Emitter<BibleState> emit) async {
    if (state is! BibleLoaded) return;
    final currentState = state as BibleLoaded;

    final currentIndex = currentState.chapters
        .indexWhere((c) => c.id == currentState.currentChapter.id);

    if (currentIndex > 0) {
      add(ChangeChapter(currentState.chapters[currentIndex - 1]));
    } else {
      final currentBookIndex = currentState.books
          .indexWhere((b) => b.id == currentState.currentBook.id);
      if (currentBookIndex > 0) {
        final previousBook = currentState.books[currentBookIndex - 1];

        emit(currentState.copyWith(isLoading: true));
        try {
          final chapters = await bibleService.getChapters(
              currentState.currentVersion.id, previousBook.id);
          final lastChapter = chapters.last;

          final content = await bibleService.getChapterContent(
            currentState.currentVersion.id,
            previousBook.id,
            lastChapter.id,
          );

          final verses = await _getParsedAndMergedVerses(
            versionId: currentState.currentVersion.id,
            bookId: previousBook.id,
            chapterId: lastChapter.id,
            rawHtml: content.rawHtml,
          );

          emit(currentState.copyWith(
            currentBook: previousBook,
            currentChapter: lastChapter,
            content: content,
            chapters: chapters,
            verses: verses,
            isLoading: false,
          ));
        } catch (e) {
          emit(BibleError('bibleErrorNavigatePreviousBook', arg: e.toString()));
        }
      }
    }
  }

  Future<void> _onLoadBibleInitial(
      LoadBibleInitial event, Emitter<BibleState> emit) async {
    emit(BibleLoading());
    try {
      final allVersions =
          await bibleService.getVersions(languages: ['en', 'af']);

      if (allVersions.isEmpty) {
        emit(const BibleError('bibleErrorNoTranslations'));
        return;
      }

      final defaultVersion = await _getInitialVersion(allVersions);

      final books = await bibleService.getBooks(defaultVersion.id);
      if (books.isEmpty) {
        emit(const BibleError('bibleErrorNoBooks'));
        return;
      }

      final defaultBook = books.firstWhereOrNull(
              (b) => b.id == 'JHN' || b.name.contains('Johannes')) ??
          books.first;

      final chapters =
          await bibleService.getChapters(defaultVersion.id, defaultBook.id);
      if (chapters.isEmpty) {
        emit(const BibleError('bibleErrorNoChapters'));
        return;
      }

      final defaultChapter =
          chapters.firstWhereOrNull((c) => c.number == '1') ?? chapters.first;

      final content = await bibleService.getChapterContent(
          defaultVersion.id, defaultBook.id, defaultChapter.id);

      final verses = await _getParsedAndMergedVerses(
        versionId: defaultVersion.id,
        bookId: defaultBook.id,
        chapterId: defaultChapter.id,
        rawHtml: content.rawHtml,
      );

      emit(BibleLoaded(
        currentVersion: defaultVersion,
        currentBook: defaultBook,
        currentChapter: defaultChapter,
        content: content,
        versions: allVersions,
        books: books,
        chapters: chapters,
        verses: verses,
      ));
    } catch (e) {
      emit(BibleError('bibleErrorLoadBible', arg: e.toString()));
    }
  }

  Future<void> _onChangeVersion(
      ChangeVersion event, Emitter<BibleState> emit) async {
    if (state is! BibleLoaded) return;
    final currentState = state as BibleLoaded;

    emit(currentState.copyWith(isLoading: true));
    try {
      final books = await bibleService.getBooks(event.version.id);
      final book =
          books.firstWhereOrNull((b) => b.id == currentState.currentBook.id) ??
              books.first;

      final chapters =
          await bibleService.getChapters(event.version.id, book.id);
      final chapter = chapters.firstWhereOrNull(
              (c) => c.number == currentState.currentChapter.number) ??
          chapters.first;

      final content = await bibleService.getChapterContent(
          event.version.id, book.id, chapter.id);

      final verses = await _getParsedAndMergedVerses(
        versionId: event.version.id,
        bookId: book.id,
        chapterId: chapter.id,
        rawHtml: content.rawHtml,
      );

      await _saveLastVersionId(event.version.id);

      emit(currentState.copyWith(
        currentVersion: event.version,
        currentBook: book,
        currentChapter: chapter,
        content: content,
        books: books,
        chapters: chapters,
        verses: verses,
        isLoading: false,
      ));
    } catch (e) {
      emit(BibleError('bibleErrorChangeTranslation', arg: e.toString()));
    }
  }

  Future<void> _onChangeBook(ChangeBook event, Emitter<BibleState> emit) async {
    if (state is! BibleLoaded) return;
    final currentState = state as BibleLoaded;

    emit(currentState.copyWith(isLoading: true, currentBook: event.book));
    try {
      final chapters = await bibleService.getChapters(
          currentState.currentVersion.id, event.book.id);
      final chapter = chapters.first;

      final content = await bibleService.getChapterContent(
          currentState.currentVersion.id, event.book.id, chapter.id);

      final verses = await _getParsedAndMergedVerses(
        versionId: currentState.currentVersion.id,
        bookId: event.book.id,
        chapterId: chapter.id,
        rawHtml: content.rawHtml,
      );

      emit(currentState.copyWith(
        currentBook: event.book,
        currentChapter: chapter,
        content: content,
        chapters: chapters,
        verses: verses,
        isLoading: false,
      ));
    } catch (e) {
      emit(BibleError('bibleErrorChangeBook', arg: e.toString()));
    }
  }

  Future<void> _onChangeChapter(
      ChangeChapter event, Emitter<BibleState> emit) async {
    if (state is! BibleLoaded) return;
    final currentState = state as BibleLoaded;

    emit(currentState.copyWith(isLoading: true, currentChapter: event.chapter));
    try {
      final content = await bibleService.getChapterContent(
        currentState.currentVersion.id,
        currentState.currentBook.id,
        event.chapter.id,
      );

      final verses = await _getParsedAndMergedVerses(
        versionId: currentState.currentVersion.id,
        bookId: currentState.currentBook.id,
        chapterId: event.chapter.id,
        rawHtml: content.rawHtml,
      );

      emit(currentState.copyWith(
        currentChapter: event.chapter,
        content: content,
        verses: verses,
        isLoading: false,
      ));
    } catch (e) {
      emit(BibleError('bibleErrorChangeChapter', arg: e.toString()));
    }
  }

  Future<void> _onLoadChapterInteractions(
      LoadChapterInteractions event, Emitter<BibleState> emit) async {
    if (state is! BibleLoaded) return;
    final currentState = state as BibleLoaded;

    emit(currentState.copyWith(isLoading: true));
    try {
      final updatedVerses = await _getParsedAndMergedVerses(
        versionId: currentState.currentVersion.id,
        bookId: currentState.currentBook.id,
        chapterId: currentState.currentChapter.id,
        rawHtml: currentState.content.rawHtml,
      );
      emit(currentState.copyWith(
        verses: updatedVerses,
        isLoading: false,
      ));
    } catch (e) {
      emit(currentState.copyWith(isLoading: false));
    }
  }

  void _onToggleVerseSelection(
      ToggleVerseSelection event, Emitter<BibleState> emit) {
    if (state is! BibleLoaded) return;
    final currentState = state as BibleLoaded;

    final updatedSelection =
        Set<String>.from(currentState.selectedVerseNumbers);
    if (updatedSelection.contains(event.verseNumber)) {
      updatedSelection.remove(event.verseNumber);
    } else {
      updatedSelection.add(event.verseNumber);
    }

    emit(currentState.copyWith(selectedVerseNumbers: updatedSelection));
  }

  void _onClearSelection(ClearSelection event, Emitter<BibleState> emit) {
    if (state is! BibleLoaded) return;
    final currentState = state as BibleLoaded;
    emit(currentState.copyWith(selectedVerseNumbers: {}));
  }

  Future<void> _onHighlightSelectedVerses(
      HighlightSelectedVerses event, Emitter<BibleState> emit) async {
    if (state is! BibleLoaded) return;
    final currentState = state as BibleLoaded;
    if (currentState.selectedVerseNumbers.isEmpty) return;

    emit(currentState.copyWith(isSavingInteraction: true));
    try {
      final versionId = currentState.currentVersion.id;
      final bookId = currentState.currentBook.id;
      final chapterId = currentState.currentChapter.id;
      final chapterNum =
          chapterId.contains('.') ? chapterId.split('.').last : chapterId;

      for (final verseNum in currentState.selectedVerseNumbers) {
        await interactionService.upsertInteraction(
          versionId: versionId,
          bookId: bookId,
          chapterNumber: chapterNum,
          verseNumber: verseNum,
          highlightColor: event.color,
          clearHighlight: event.color == null,
        );
      }

      final updatedVerses = await _getParsedAndMergedVerses(
        versionId: versionId,
        bookId: bookId,
        chapterId: chapterId,
        rawHtml: currentState.content.rawHtml,
      );

      emit(currentState.copyWith(
        verses: updatedVerses,
        selectedVerseNumbers: {},
        isSavingInteraction: false,
      ));
    } catch (e) {
      emit(currentState.copyWith(isSavingInteraction: false));
    }
  }

  Future<void> _onToggleBookmarkSelected(
      ToggleBookmarkSelected event, Emitter<BibleState> emit) async {
    if (state is! BibleLoaded) return;
    final currentState = state as BibleLoaded;
    if (currentState.selectedVerseNumbers.isEmpty) return;

    emit(currentState.copyWith(isSavingInteraction: true));
    try {
      final versionId = currentState.currentVersion.id;
      final bookId = currentState.currentBook.id;
      final chapterId = currentState.currentChapter.id;
      final chapterNum =
          chapterId.contains('.') ? chapterId.split('.').last : chapterId;

      final firstVerseNum = currentState.selectedVerseNumbers.first;
      final firstVerse = currentState.verses
          .firstWhereOrNull((v) => v.verseNumber == firstVerseNum);
      final newBookmarkState =
          firstVerse == null ? true : !firstVerse.isBookmarked;

      for (final verseNum in currentState.selectedVerseNumbers) {
        await interactionService.upsertInteraction(
          versionId: versionId,
          bookId: bookId,
          chapterNumber: chapterNum,
          verseNumber: verseNum,
          isBookmarked: newBookmarkState,
        );
      }

      final updatedVerses = await _getParsedAndMergedVerses(
        versionId: versionId,
        bookId: bookId,
        chapterId: chapterId,
        rawHtml: currentState.content.rawHtml,
      );

      emit(currentState.copyWith(
        verses: updatedVerses,
        selectedVerseNumbers: {},
        isSavingInteraction: false,
      ));
    } catch (e) {
      emit(currentState.copyWith(isSavingInteraction: false));
    }
  }

  Future<void> _onSaveNoteForSelected(
      SaveNoteForSelected event, Emitter<BibleState> emit) async {
    if (state is! BibleLoaded) return;
    final currentState = state as BibleLoaded;
    if (currentState.selectedVerseNumbers.isEmpty) return;

    emit(currentState.copyWith(isSavingInteraction: true));
    try {
      final versionId = currentState.currentVersion.id;
      final bookId = currentState.currentBook.id;
      final chapterId = currentState.currentChapter.id;
      final chapterNum =
          chapterId.contains('.') ? chapterId.split('.').last : chapterId;

      final isClear = event.noteText.trim().isEmpty;

      for (final verseNum in currentState.selectedVerseNumbers) {
        await interactionService.upsertInteraction(
          versionId: versionId,
          bookId: bookId,
          chapterNumber: chapterNum,
          verseNumber: verseNum,
          note: isClear ? null : event.noteText,
          clearNote: isClear,
        );
      }

      final updatedVerses = await _getParsedAndMergedVerses(
        versionId: versionId,
        bookId: bookId,
        chapterId: chapterId,
        rawHtml: currentState.content.rawHtml,
      );

      emit(currentState.copyWith(
        verses: updatedVerses,
        selectedVerseNumbers: {},
        isSavingInteraction: false,
      ));
    } catch (e) {
      emit(currentState.copyWith(isSavingInteraction: false));
    }
  }
}
