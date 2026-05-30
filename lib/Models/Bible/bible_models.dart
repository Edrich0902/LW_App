import 'package:equatable/equatable.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;

class BibleVersion extends Equatable {
  final String id;
  final String name;
  final String language;
  final String? abbreviation;

  const BibleVersion({
    required this.id,
    required this.name,
    required this.language,
    this.abbreviation,
  });

  factory BibleVersion.fromJson(Map<String, dynamic> json) {
    return BibleVersion(
      id: json['id'].toString(),
      name: json['title'] ?? json['localized_title'] ?? '',
      language: json['language_tag'] ?? '',
      abbreviation: json['abbreviation']?.toString(),
    );
  }

  /// Full display name with code prefix: "AMP - Amplified Bible"
  String get displayName => (abbreviation != null && abbreviation!.isNotEmpty)
      ? '$abbreviation - $name'
      : name;

  /// Short label for compact spaces — just the code: "AMP"
  String get shortLabel =>
      (abbreviation != null && abbreviation!.isNotEmpty) ? abbreviation! : name;

  @override
  List<Object?> get props => [id, name, language, abbreviation];
}

class BibleBook extends Equatable {
  final String id;
  final String name;

  const BibleBook({
    required this.id,
    required this.name,
  });

  factory BibleBook.fromJson(Map<String, dynamic> json) {
    return BibleBook(
      id: json['id'].toString(),
      name: json['title'] ?? json['name'] ?? '',
    );
  }

  @override
  List<Object?> get props => [id, name];
}

class BibleChapter extends Equatable {
  final String id;
  final String number;

  const BibleChapter({
    required this.id,
    required this.number,
  });

  factory BibleChapter.fromJson(Map<String, dynamic> json) {
    String id = json['id'].toString();
    String? number = json['number']?.toString();

    // If number is missing, try to extract it from ID (e.g. "JHN.1" -> "1")
    if (number == null || number == 'null') {
      if (id.contains('.')) {
        number = id.split('.').last;
      } else {
        number = id;
      }
    }

    return BibleChapter(
      id: id,
      number: number,
    );
  }

  @override
  List<Object?> get props => [id, number];
}

class BibleContent extends Equatable {
  final String html; // Pre-processed HTML for flutter_html display
  final String rawHtml; // Raw HTML from API for parsing into BibleVerse list
  final String citation;

  const BibleContent({
    required this.html,
    required this.rawHtml,
    required this.citation,
  });

  factory BibleContent.fromJson(Map<String, dynamic> json) {
    final String rawHtml = json['content'] ?? '';
    return BibleContent(
      html: _processHtml(rawHtml),
      rawHtml: rawHtml,
      citation: json['reference'] ?? '',
    );
  }

  static String _processHtml(String html) {
    // Use a simple class rename approach — no lookbehind (not supported in Dart)
    String processed = html;

    // Ensure common YouVersion classes are treated as verse markers
    processed = processed.replaceAll('class="label"', 'class="v"');
    processed = processed.replaceAll('class="verse"', 'class="v"');

    // Ensure <sup> tags are styled correctly
    processed = processed.replaceAll('<sup', '<sup class="v"');

    return processed;
  }

  @override
  List<Object?> get props => [html, rawHtml, citation];
}

class BibleVerse extends Equatable {
  final String bookId;
  final String chapterId;
  final String verseNumber;
  final String text;
  final String? heading;

  // Interactive properties (synced from Supabase)
  final String? highlightColor;
  final bool isBookmarked;
  final String? note;

  const BibleVerse({
    required this.bookId,
    required this.chapterId,
    required this.verseNumber,
    required this.text,
    this.heading,
    this.highlightColor,
    this.isBookmarked = false,
    this.note,
  });

  BibleVerse copyWith({
    String? highlightColor,
    bool? isBookmarked,
    String? note,
    bool clearHighlight = false,
    bool clearNote = false,
  }) {
    return BibleVerse(
      bookId: bookId,
      chapterId: chapterId,
      verseNumber: verseNumber,
      text: text,
      heading: heading,
      highlightColor:
          clearHighlight ? null : (highlightColor ?? this.highlightColor),
      isBookmarked: isBookmarked ?? this.isBookmarked,
      note: clearNote ? null : (note ?? this.note),
    );
  }

  @override
  List<Object?> get props => [
        bookId,
        chapterId,
        verseNumber,
        text,
        heading,
        highlightColor,
        isBookmarked,
        note,
      ];
}

class BibleParser {
  static List<BibleVerse> parseChapterHtml({
    required String rawHtml, // Use the raw, unprocessed HTML from the API
    required String bookId,
    required String chapterId,
  }) {
    final document = html_parser.parse(rawHtml);
    final List<BibleVerse> parsedVerses = [];

    String? pendingHeading;
    String? currentVerseNum;
    final StringBuffer currentVerseText = StringBuffer();

    void completeCurrentVerse() {
      if (currentVerseNum != null && currentVerseText.isNotEmpty) {
        parsedVerses.add(BibleVerse(
          bookId: bookId,
          chapterId: chapterId,
          verseNumber: currentVerseNum!,
          text: currentVerseText
              .toString()
              .replaceAll(RegExp(r'\s+'), ' ')
              .trim(),
          heading: pendingHeading,
        ));
        pendingHeading = null; // Consume heading
        currentVerseText.clear();
      }
    }

    void traverse(dom.Node node) {
      if (node.nodeType == dom.Node.ELEMENT_NODE) {
        final element = node as dom.Element;
        final className = element.className.toLowerCase();
        final localName = element.localName?.toLowerCase() ?? '';

        // 1. Skip verse labels to prevent duplicating numbers in text
        if (className.contains('yv-vlbl') || className.contains('vlbl')) {
          return;
        }

        // 2. Capture headings and complete the previous verse
        if (className.contains('s1') ||
            className.contains('s2') ||
            localName == 'h2' ||
            localName == 'h3') {
          completeCurrentVerse();
          pendingHeading = element.text.trim();
          return;
        }

        // 3. Detect verse markers
        final isVerseMarker = className.contains('yv-v') ||
            element.attributes.containsKey('v') ||
            className.contains('v') ||
            localName == 'sup';

        if (isVerseMarker) {
          String? newVerse = element.attributes['v'] ?? element.text.trim();
          if (newVerse.isNotEmpty) {
            completeCurrentVerse();
            currentVerseNum = newVerse;
            return;
          }
        }
      }

      if (node.nodeType == dom.Node.TEXT_NODE) {
        if (currentVerseNum != null) {
          currentVerseText.write(node.text);
        }
      }

      for (final child in node.nodes) {
        traverse(child);
      }
    }

    if (document.body != null) {
      traverse(document.body!);
      completeCurrentVerse();
    }

    return parsedVerses;
  }
}
