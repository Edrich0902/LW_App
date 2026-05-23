import 'package:flutter_test/flutter_test.dart';
import 'package:lw_app/Blocs/Bible/bible_state.dart';
import 'package:lw_app/Models/Bible/bible_models.dart';
import 'package:lw_app/Utils/verse_image_formatter.dart';

void main() {
  group('buildVerseImageDraft', () {
    test('formats a single selected verse', () {
      final draft = buildVerseImageDraft(
        _loadedState(selectedVerseNumbers: {'16'}),
      );

      expect(draft, isNotNull);
      expect(draft!.verseText, '[16] Want so lief het God die wereld gehad');
      expect(draft.citation, 'Johannes 3:16 (AFR20)');
      expect(draft.footer, 'Lewende Woord Paarl');
    });

    test('formats multiple selected verses in verse order', () {
      final draft = buildVerseImageDraft(
        _loadedState(selectedVerseNumbers: {'17', '16'}),
      );

      expect(
        draft!.verseText,
        '[16] Want so lief het God die wereld gehad [17] God het nie sy Seun gestuur om te veroordeel nie',
      );
      expect(draft.citation, 'Johannes 3:16, 17 (AFR20)');
    });

    test('skips selected verse IDs missing from the chapter', () {
      final draft = buildVerseImageDraft(
        _loadedState(selectedVerseNumbers: {'99', '16'}),
      );

      expect(draft!.verseText, '[16] Want so lief het God die wereld gehad');
      expect(draft.citation, 'Johannes 3:16 (AFR20)');
    });
  });
}

BibleLoaded _loadedState({required Set<String> selectedVerseNumbers}) {
  return BibleLoaded(
    currentVersion: const BibleVersion(
      id: 'afr20',
      name: 'AFR20',
      language: 'af',
    ),
    currentBook: const BibleBook(id: 'JHN', name: 'Johannes'),
    currentChapter: const BibleChapter(id: 'JHN.3', number: '3'),
    content: const BibleContent(html: '', rawHtml: '', citation: 'Johannes 3'),
    versions: const [],
    books: const [],
    chapters: const [],
    verses: const [
      BibleVerse(
        bookId: 'JHN',
        chapterId: 'JHN.3',
        verseNumber: '16',
        text: 'Want so lief het God die wereld gehad',
      ),
      BibleVerse(
        bookId: 'JHN',
        chapterId: 'JHN.3',
        verseNumber: '17',
        text: 'God het nie sy Seun gestuur om te veroordeel nie',
      ),
    ],
    selectedVerseNumbers: selectedVerseNumbers,
  );
}
