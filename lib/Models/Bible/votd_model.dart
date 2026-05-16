import 'package:equatable/equatable.dart';
import 'package:lw_app/Models/Bible/bible_models.dart';

class Votd extends Equatable {
  final int day;
  final String passageId;
  final BibleContent content;
  final BibleVersion version;
  final BibleBook book;
  final BibleChapter chapter;
  final String? imageUrl;

  const Votd({
    required this.day,
    required this.passageId,
    required this.content,
    required this.version,
    required this.book,
    required this.chapter,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [day, passageId, content, version, book, chapter, imageUrl];
}
