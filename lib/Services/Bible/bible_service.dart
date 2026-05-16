import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lw_app/Models/Bible/bible_models.dart';
import 'package:lw_app/Utils/environment.dart';

class BibleService {
  final String _apiKey = Environment.youversionKey;

  Map<String, String> get _headers => {
    'X-YVP-App-Key': _apiKey,
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<List<BibleVersion>> getVersions({List<String> languages = const ['en', 'af']}) async {
    final uri = Uri.https('api.youversion.com', '/v1/bibles', {
      'language_ranges[]': languages,
    });

    final response = await http.get(
      uri,
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List versions = data['data'] ?? [];
      return versions.map((v) => BibleVersion.fromJson(v)).toList();
    } else {
      print('Bible API Error (getVersions): ${response.body}');
      throw Exception('Failed to load Bible versions: ${response.statusCode}');
    }
  }

  Future<List<BibleBook>> getBooks(String versionId) async {
    final uri = Uri.https('api.youversion.com', '/v1/bibles/$versionId/books');
    
    final response = await http.get(
      uri,
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List books = data['data'] ?? [];
      return books.map((b) => BibleBook.fromJson(b)).toList();
    } else {
      print('Bible API Error (getBooks): ${response.body}');
      throw Exception('Failed to load Bible books: ${response.statusCode}');
    }
  }

  Future<List<BibleChapter>> getChapters(String versionId, String bookId) async {
    // bookId here should be the USFM code (e.g., 'JHN')
    final uri = Uri.https('api.youversion.com', '/v1/bibles/$versionId/books/$bookId/chapters');

    final response = await http.get(
      uri,
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List chapters = data['data'] ?? [];
      return chapters.map((c) => BibleChapter.fromJson(c)).toList();
    } else {
      print('Bible API Error (getChapters): ${response.body}');
      throw Exception('Failed to load Bible chapters: ${response.statusCode}');
    }
  }

  Future<BibleContent> getChapterContent(String versionId, String bookId, String chapterId) async {
    // Using the /passages endpoint as specified in Section 8 of you_version_integration.md
    // Ensure we have a full reference (e.g., 'JHN.1')
    final reference = chapterId.contains('.') ? chapterId : '$bookId.$chapterId';
    final uri = Uri.https('api.youversion.com', '/v1/bibles/$versionId/passages/$reference');

    final response = await http.get(
      uri,
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // The passage endpoint returns a single object which might be wrapped in 'data'
      final contentData = data['data'] ?? data;
      return BibleContent.fromJson(contentData);
    } else {
      print('Bible API Error (getChapterContent): ${response.body}');
      throw Exception('Failed to load Bible content: ${response.statusCode}');
    }
  }
}
