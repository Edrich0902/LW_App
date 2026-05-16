import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Blocs/Bible/bible_event.dart';
import 'package:lw_app/Blocs/Bible/bible_state.dart';
import 'package:lw_app/Services/Bible/bible_service.dart';
import 'package:collection/collection.dart';

class BibleBloc extends Bloc<BibleEvent, BibleState> {
  final BibleService bibleService;

  BibleBloc({required this.bibleService}) : super(BibleLoading()) {
    on<LoadBibleInitial>(_onLoadBibleInitial);
    on<LoadSpecificPassage>(_onLoadSpecificPassage);
    on<ChangeVersion>(_onChangeVersion);
    on<ChangeBook>(_onChangeBook);
    on<ChangeChapter>(_onChangeChapter);
    on<NavigateNextChapter>(_onNavigateNextChapter);
    on<NavigatePreviousChapter>(_onNavigatePreviousChapter);
  }

  Future<void> _onLoadSpecificPassage(LoadSpecificPassage event, Emitter<BibleState> emit) async {
    emit(BibleLoading());
    try {
      final allVersions = await bibleService.getVersions(languages: ['en', 'af']);
      final books = await bibleService.getBooks(event.version.id);
      final chapters = await bibleService.getChapters(event.version.id, event.book.id);
      final content = await bibleService.getChapterContent(event.version.id, event.book.id, event.chapter.id);

      emit(BibleLoaded(
        currentVersion: event.version,
        currentBook: event.book,
        currentChapter: event.chapter,
        content: content,
        versions: allVersions,
        books: books,
        chapters: chapters,
      ));
    } catch (e) {
      emit(BibleError('Fout met die laai van die spesifieke vers: $e'));
    }
  }

  Future<void> _onNavigateNextChapter(NavigateNextChapter event, Emitter<BibleState> emit) async {
    if (state is! BibleLoaded) return;
    final currentState = state as BibleLoaded;

    final currentIndex = currentState.chapters.indexWhere((c) => c.id == currentState.currentChapter.id);

    if (currentIndex < currentState.chapters.length - 1) {
      // Next chapter in same book
      add(ChangeChapter(currentState.chapters[currentIndex + 1]));
    } else {
      // Next book
      final currentBookIndex = currentState.books.indexWhere((b) => b.id == currentState.currentBook.id);
      if (currentBookIndex < currentState.books.length - 1) {
        add(ChangeBook(currentState.books[currentBookIndex + 1]));
      }
    }
  }

  Future<void> _onNavigatePreviousChapter(NavigatePreviousChapter event, Emitter<BibleState> emit) async {
    if (state is! BibleLoaded) return;
    final currentState = state as BibleLoaded;

    final currentIndex = currentState.chapters.indexWhere((c) => c.id == currentState.currentChapter.id);

    if (currentIndex > 0) {
      // Previous chapter in same book
      add(ChangeChapter(currentState.chapters[currentIndex - 1]));
    } else {
      // Previous book
      final currentBookIndex = currentState.books.indexWhere((b) => b.id == currentState.currentBook.id);
      if (currentBookIndex > 0) {
        final previousBook = currentState.books[currentBookIndex - 1];
        
        emit(currentState.copyWith(isLoading: true));
        try {
          final chapters = await bibleService.getChapters(currentState.currentVersion.id, previousBook.id);
          final lastChapter = chapters.last;
          
          final content = await bibleService.getChapterContent(
            currentState.currentVersion.id,
            previousBook.id,
            lastChapter.id,
          );

          emit(currentState.copyWith(
            currentBook: previousBook,
            currentChapter: lastChapter,
            content: content,
            chapters: chapters,
            isLoading: false,
          ));
        } catch (e) {
          emit(BibleError('Fout met die navigasie na vorige boek: $e'));
        }
      }
    }
  }

  Future<void> _onLoadBibleInitial(LoadBibleInitial event, Emitter<BibleState> emit) async {
    emit(BibleLoading());
    try {
      // 1. Fetch versions (English and Afrikaans) in one call
      final allVersions = await bibleService.getVersions(languages: ['en', 'af']);

      if (allVersions.isEmpty) {
        emit(const BibleError('Geen Bybelvertalings gevind nie.'));
        return;
      }

      // 2. Default version: NIV or first available
      final defaultVersion = allVersions.firstWhereOrNull((v) => v.name.contains('NIV')) ?? allVersions.first;

      // 3. Fetch books
      final books = await bibleService.getBooks(defaultVersion.id);
      if (books.isEmpty) {
        emit(const BibleError('Geen boeke gevind nie.'));
        return;
      }

      // 4. Default book: John or first
      final defaultBook = books.firstWhereOrNull((b) => b.id == 'JHN' || b.name.contains('Johannes')) ?? books.first;

      // 5. Fetch chapters
      final chapters = await bibleService.getChapters(defaultVersion.id, defaultBook.id);
      if (chapters.isEmpty) {
        emit(const BibleError('Geen hoofstukke gevind nie.'));
        return;
      }

      // 6. Default chapter: 1 or first
      final defaultChapter = chapters.firstWhereOrNull((c) => c.number == '1') ?? chapters.first;

      // 7. Fetch content
      final content = await bibleService.getChapterContent(defaultVersion.id, defaultBook.id, defaultChapter.id);

      emit(BibleLoaded(
        currentVersion: defaultVersion,
        currentBook: defaultBook,
        currentChapter: defaultChapter,
        content: content,
        versions: allVersions,
        books: books,
        chapters: chapters,
      ));
    } catch (e) {
      emit(BibleError('Fout met die laai van die Bybel: $e'));
    }
  }

  Future<void> _onChangeVersion(ChangeVersion event, Emitter<BibleState> emit) async {
    if (state is! BibleLoaded) return;
    final currentState = state as BibleLoaded;

    emit(currentState.copyWith(isLoading: true));
    try {
      final books = await bibleService.getBooks(event.version.id);
      // Try to find same book in new version, else first
      final book = books.firstWhereOrNull((b) => b.id == currentState.currentBook.id) ?? books.first;

      final chapters = await bibleService.getChapters(event.version.id, book.id);
      // Try to find same chapter, else first
      final chapter = chapters.firstWhereOrNull((c) => c.number == currentState.currentChapter.number) ?? chapters.first;

      final content = await bibleService.getChapterContent(event.version.id, book.id, chapter.id);

      emit(currentState.copyWith(
        currentVersion: event.version,
        currentBook: book,
        currentChapter: chapter,
        content: content,
        books: books,
        chapters: chapters,
        isLoading: false,
      ));
    } catch (e) {
      emit(BibleError('Fout met die verandering van vertaling: $e'));
    }
  }

  Future<void> _onChangeBook(ChangeBook event, Emitter<BibleState> emit) async {
    if (state is! BibleLoaded) return;
    final currentState = state as BibleLoaded;

    emit(currentState.copyWith(isLoading: true, currentBook: event.book));
    try {
      final chapters = await bibleService.getChapters(currentState.currentVersion.id, event.book.id);
      final chapter = chapters.first; // Default to chapter 1 when changing book

      final content = await bibleService.getChapterContent(currentState.currentVersion.id, event.book.id, chapter.id);

      emit(currentState.copyWith(
        currentBook: event.book,
        currentChapter: chapter,
        content: content,
        chapters: chapters,
        isLoading: false,
      ));
    } catch (e) {
      emit(BibleError('Fout met die verandering van boek: $e'));
    }
  }

  Future<void> _onChangeChapter(ChangeChapter event, Emitter<BibleState> emit) async {
    if (state is! BibleLoaded) return;
    final currentState = state as BibleLoaded;

    emit(currentState.copyWith(isLoading: true, currentChapter: event.chapter));
    try {
      final content = await bibleService.getChapterContent(
        currentState.currentVersion.id,
        currentState.currentBook.id,
        event.chapter.id,
      );

      emit(currentState.copyWith(
        currentChapter: event.chapter,
        content: content,
        isLoading: false,
      ));
    } catch (e) {
      emit(BibleError('Fout met die verandering van hoofstuk: $e'));
    }
  }
}
