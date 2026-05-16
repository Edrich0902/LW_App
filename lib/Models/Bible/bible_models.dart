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
    return BibleChapter(
      id: json['id'].toString(),
      number: json['number'].toString(),
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
    return BibleContent(
      html: json['content'] ?? '',
      citation: json['reference'] ?? '',
    );
  }

  @override
  List<Object?> get props => [html, citation];
}
