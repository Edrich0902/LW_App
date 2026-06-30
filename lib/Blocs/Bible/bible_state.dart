import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:lw_app/Extensions/context_l10n.dart';
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
  final String? focusVerseNumber;

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
    this.focusVerseNumber,
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
    String? focusVerseNumber,
    bool clearFocusVerse = false,
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
      focusVerseNumber:
          clearFocusVerse ? null : (focusVerseNumber ?? this.focusVerseNumber),
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
        focusVerseNumber,
      ];
}

class BibleError extends BibleState {
  final String message;
  final String? arg;
  const BibleError(this.message, {this.arg});

  @override
  List<Object?> get props => [message, arg];

  String getLocalizedMessage(BuildContext context) {
    switch (message) {
      case 'bibleErrorLoadSpecificVerse':
        return context.l10n.bibleErrorLoadSpecificVerse(arg ?? '');
      case 'bibleErrorNavigatePreviousBook':
        return context.l10n.bibleErrorNavigatePreviousBook(arg ?? '');
      case 'bibleErrorLoadBible':
        return context.l10n.bibleErrorLoadBible(arg ?? '');
      case 'bibleErrorChangeTranslation':
        return context.l10n.bibleErrorChangeTranslation(arg ?? '');
      case 'bibleErrorChangeBook':
        return context.l10n.bibleErrorChangeBook(arg ?? '');
      case 'bibleErrorChangeChapter':
        return context.l10n.bibleErrorChangeChapter(arg ?? '');
      case 'bibleErrorNoTranslations':
        return context.l10n.bibleErrorNoTranslations;
      case 'bibleErrorNoBooks':
        return context.l10n.bibleErrorNoBooks;
      case 'bibleErrorNoChapters':
        return context.l10n.bibleErrorNoChapters;
      default:
        return message;
    }
  }
}
