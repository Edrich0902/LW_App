import 'package:collection/collection.dart';
import 'package:lw_app/Blocs/Bible/bible_state.dart';
import 'package:lw_app/Models/Bible/bible_models.dart';
import 'package:lw_app/Models/Bible/verse_image_draft.dart';
import 'package:lw_app/Models/Bible/votd_model.dart';

VerseImageDraft? buildVerseImageDraft(BibleLoaded state) {
  final selectedVerses = selectedVersesInReadingOrder(
    verses: state.verses,
    selectedVerseNumbers: state.selectedVerseNumbers,
  );

  if (selectedVerses.isEmpty) return null;

  final verseText = selectedVerses
      .map((verse) => '[${verse.verseNumber}] ${verse.text}')
      .join(' ');
  final citation =
      '${state.currentBook.name} ${state.currentChapter.number}:${selectedVerses.map((verse) => verse.verseNumber).join(', ')} (${state.currentVersion.name})';

  return VerseImageDraft(
    verseText: verseText,
    citation: citation,
  );
}

List<BibleVerse> selectedVersesInReadingOrder({
  required List<BibleVerse> verses,
  required Set<String> selectedVerseNumbers,
}) {
  final sortedNumbers = selectedVerseNumbers.toList()..sort(_compareVerseIds);

  return sortedNumbers
      .map((verseNumber) =>
          verses.firstWhereOrNull((verse) => verse.verseNumber == verseNumber))
      .whereType<BibleVerse>()
      .toList(growable: false);
}

int _compareVerseIds(String left, String right) {
  final leftNumber = int.tryParse(left);
  final rightNumber = int.tryParse(right);

  if (leftNumber != null && rightNumber != null) {
    return leftNumber.compareTo(rightNumber);
  }

  return left.compareTo(right);
}

/// Builds a [VerseImageDraft] directly from a [Votd] for the VOTD card image action.
VerseImageDraft? buildVerseImageDraftFromVotd(Votd votd) {
  final verses = BibleParser.parseChapterHtml(
    rawHtml: votd.content.rawHtml,
    bookId: votd.book.id,
    chapterId: votd.chapter.id,
  );

  if (verses.isEmpty) return null;

  final verseText = verses.map((v) => '[${v.verseNumber}] ${v.text}').join(' ');
  final citation = '${votd.content.citation} (${votd.version.shortLabel})';

  return VerseImageDraft(
    verseText: verseText,
    citation: citation,
  );
}
