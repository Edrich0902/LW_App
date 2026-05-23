import 'package:equatable/equatable.dart';

class UserVerseInteraction extends Equatable {
  final String? id;
  final String userId;
  final String versionId;
  final String bookId;
  final String chapterNumber;
  final String verseNumber;
  final String? highlightColor;
  final bool isBookmarked;
  final String? note;
  final String? createdAt;
  final String? updatedAt;

  const UserVerseInteraction({
    this.id,
    required this.userId,
    required this.versionId,
    required this.bookId,
    required this.chapterNumber,
    required this.verseNumber,
    this.highlightColor,
    this.isBookmarked = false,
    this.note,
    this.createdAt,
    this.updatedAt,
  });

  factory UserVerseInteraction.fromJson(Map<String, dynamic> json) {
    return UserVerseInteraction(
      id: json['id']?.toString(),
      userId: json['user_id']?.toString() ?? '',
      versionId: json['version_id']?.toString() ?? '',
      bookId: json['book_id']?.toString() ?? '',
      chapterNumber: json['chapter_number']?.toString() ?? '',
      verseNumber: json['verse_number']?.toString() ?? '',
      highlightColor: json['highlight_color']?.toString(),
      isBookmarked: json['is_bookmarked'] == true,
      note: json['note']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'version_id': versionId,
      'book_id': bookId,
      'chapter_number': chapterNumber,
      'verse_number': verseNumber,
      'highlight_color': highlightColor,
      'is_bookmarked': isBookmarked,
      'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    };
  }

  UserVerseInteraction copyWith({
    String? highlightColor,
    bool? isBookmarked,
    String? note,
  }) {
    return UserVerseInteraction(
      id: id,
      userId: userId,
      versionId: versionId,
      bookId: bookId,
      chapterNumber: chapterNumber,
      verseNumber: verseNumber,
      highlightColor: highlightColor ?? this.highlightColor,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      note: note ?? this.note,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        versionId,
        bookId,
        chapterNumber,
        verseNumber,
        highlightColor,
        isBookmarked,
        note,
        createdAt,
        updatedAt,
      ];
}
