import 'package:equatable/equatable.dart';

class VerseImageDraft extends Equatable {
  final String verseText;
  final String citation;
  final String? footer;

  const VerseImageDraft({
    required this.verseText,
    required this.citation,
    this.footer = 'Lewende Woord Paarl',
  });

  @override
  List<Object?> get props => [verseText, citation, footer];
}
