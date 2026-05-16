import 'package:equatable/equatable.dart';
import 'package:lw_app/Models/Bible/bible_models.dart';

abstract class BibleEvent extends Equatable {
  const BibleEvent();

  @override
  List<Object?> get props => [];
}

class LoadBibleInitial extends BibleEvent {}

class LoadSpecificPassage extends BibleEvent {
  final BibleVersion version;
  final BibleBook book;
  final BibleChapter chapter;

  const LoadSpecificPassage({
    required this.version,
    required this.book,
    required this.chapter,
  });

  @override
  List<Object?> get props => [version, book, chapter];
}

class ChangeVersion extends BibleEvent {
  final BibleVersion version;
  const ChangeVersion(this.version);

  @override
  List<Object?> get props => [version];
}

class ChangeBook extends BibleEvent {
  final BibleBook book;
  const ChangeBook(this.book);

  @override
  List<Object?> get props => [book];
}

class ChangeChapter extends BibleEvent {
  final BibleChapter chapter;
  const ChangeChapter(this.chapter);

  @override
  List<Object?> get props => [chapter];
}

class NavigateNextChapter extends BibleEvent {}

class NavigatePreviousChapter extends BibleEvent {}
