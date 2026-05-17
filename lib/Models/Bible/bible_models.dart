import 'package:equatable/equatable.dart';

class BibleVersion extends Equatable {
  final String id;
  final String name;
  final String language;

  const BibleVersion({
    required this.id,
    required this.name,
    required this.language,
  });

  factory BibleVersion.fromJson(Map<String, dynamic> json) {
    return BibleVersion(
      id: json['id'].toString(),
      name: json['title'] ?? json['localized_title'] ?? '',
      language: json['language_tag'] ?? '',
    );
  }

  @override
  List<Object?> get props => [id, name, language];
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
  final String html;
  final String citation;

  const BibleContent({
    required this.html,
    required this.citation,
  });

  factory BibleContent.fromJson(Map<String, dynamic> json) {
    String rawHtml = json['content'] ?? '';
    return BibleContent(
      html: _processHtml(rawHtml),
      citation: json['reference'] ?? '',
    );
  }

  static String _processHtml(String html) {
    // 1. Wrap raw numbers followed by non-breaking space or letter
    // This handles cases where verse numbers are just raw text in the HTML
    String processed = html.replaceAllMapped(RegExp(r'(?<=^|>|\s)(\d+)(?=[a-zA-Z\u00A0])'), (match) {
      return '<span class="v">${match[1]}</span>';
    });

    // 2. Ensure common YouVersion classes are treated as verse markers
    processed = processed.replaceAll('class="label"', 'class="v"');
    processed = processed.replaceAll('class="verse"', 'class="v"');
    
    // 3. Ensure <sup> tags are styled correctly
    processed = processed.replaceAll('<sup', '<sup class="v"');

    return processed;
  }

  @override
  List<Object?> get props => [html, citation];
}
