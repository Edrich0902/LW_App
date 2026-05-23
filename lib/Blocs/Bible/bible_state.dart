import 'package:equatable/equatable.dart';
import 'package:lw_app/Models/Bible/bible_models.dart';

abstract class BibleState extends Equatable {
  const BibleState();

  @override
  List<Object?> get props => [];
}

class BibleLoading extends BibleState {}

class BibleLoaded extends BibleState {
  final BibleVersion currentVersion;
  final BibleBook currentBook;
  final BibleChapter currentChapter;
  final BibleContent content;
  final List<BibleVersion> versions;
  final List<BibleBook> books;
  final List<BibleChapter> chapters;
  final List<BibleVerse> verses;
  final Set<String> selectedVerseNumbers;
  final bool isLoading;
  final bool isSavingInteraction;

  const BibleLoaded({
    required this.currentVersion,
    required this.currentBook,
    required this.currentChapter,
    required this.content,
    required this.versions,
    required this.books,
    required this.chapters,
    this.verses = const [],
    this.selectedVerseNumbers = const {},
    this.isLoading = false,
    this.isSavingInteraction = false,
  });

  BibleLoaded copyWith({
    BibleVersion? currentVersion,
    BibleBook? currentBook,
    BibleChapter? currentChapter,
    BibleContent? content,
    List<BibleVersion>? versions,
    List<BibleBook>? books,
    List<BibleChapter>? chapters,
    List<BibleVerse>? verses,
    Set<String>? selectedVerseNumbers,
    bool? isLoading,
    bool? isSavingInteraction,
  }) {
    return BibleLoaded(
      currentVersion: currentVersion ?? this.currentVersion,
      currentBook: currentBook ?? this.currentBook,
      currentChapter: currentChapter ?? this.currentChapter,
      content: content ?? this.content,
      versions: versions ?? this.versions,
      books: books ?? this.books,
      chapters: chapters ?? this.chapters,
      verses: verses ?? this.verses,
      selectedVerseNumbers: selectedVerseNumbers ?? this.selectedVerseNumbers,
      isLoading: isLoading ?? this.isLoading,
      isSavingInteraction: isSavingInteraction ?? this.isSavingInteraction,
    );
  }

  @override
  List<Object?> get props => [
        currentVersion,
        currentBook,
        currentChapter,
        content,
        versions,
        books,
        chapters,
        verses,
        selectedVerseNumbers,
        isLoading,
        isSavingInteraction,
      ];
}

class BibleError extends BibleState {
  final String message;
  const BibleError(this.message);

  @override
  List<Object?> get props => [message];
}
