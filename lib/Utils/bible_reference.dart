import 'package:lw_app/Models/Bible/bible_models.dart';

int _parseVerseNum(String v) {
  if (v.contains('-')) return int.tryParse(v.split('-').first) ?? 1;
  return int.tryParse(v) ?? 1;
}

String buildPassageReference(
    BibleBook book, BibleChapter chapter, Set<String> verseNumbers) {
  final nums = verseNumbers.map(_parseVerseNum).toList()..sort();
  final min = nums.first;
  final max = nums.last;
  final b = book.id;
  final c = chapter.number;
  return min == max ? '$b.$c.$min' : '$b.$c.$min-$b.$c.$max';
}

String buildCitation(
    BibleBook book, BibleChapter chapter, Set<String> verseNumbers) {
  final nums = verseNumbers.map(_parseVerseNum).toList()..sort();
  final min = nums.first;
  final max = nums.last;
  final bookName = book.name;
  final chNum = chapter.number;
  return min == max ? '$bookName $chNum:$min' : '$bookName $chNum:$min-$max';
}
