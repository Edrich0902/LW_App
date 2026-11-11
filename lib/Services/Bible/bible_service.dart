import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:lw_app/Models/Bible/bible_models.dart';
import 'package:lw_app/Services/Bible/bible_cache.dart';
import 'package:lw_app/Utils/environment.dart';

class BibleService {
  BibleService({BibleCache? cache}) : _cache = cache ?? BibleCache();

  final String _apiKey = Environment.youversionKey;
  final BibleCache _cache;
  final Map<String, Future<dynamic>> _inflight = {};

  Map<String, String> get _headers => {
        'X-YVP-App-Key': _apiKey,
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  Future<T> _dedupe<T>(String key, Future<T> Function() loader) {
    final existing = _inflight[key];
    if (existing != null) {
      return existing.then((value) => value as T);
    }

    final future = loader();
    _inflight[key] = future;
    future.whenComplete(() {
      if (identical(_inflight[key], future)) {
        _inflight.remove(key);
      }
    });
    return future;
  }

  Future<List<BibleVersion>> getVersions({
    List<String> languages = const ['en', 'af'],
  }) {
    final langKey = List<String>.from(languages)..sort();
    final cacheKey = 'versions:${langKey.join(',')}';

    return _dedupe(cacheKey, () async {
      final cached = await _cache.getJson(cacheKey);
      final items = cached?['items'];
      if (items is List) {
        return items
            .whereType<Map>()
            .map((e) => BibleVersion.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }

      final uri = Uri.https('api.youversion.com', '/v1/bibles', {
        'language_ranges[]': languages,
      });

      final response = await http.get(uri, headers: _headers);
      if (response.statusCode != 200) {
        throw Exception('Failed to load Bible versions: ${response.statusCode}');
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final List versions = data['data'] ?? [];
      await _cache.putJson(cacheKey, versions, BibleCache.versionsTtl);
      return versions
          .map((v) => BibleVersion.fromJson(Map<String, dynamic>.from(v as Map)))
          .toList();
    });
  }

  Future<List<BibleBook>> getBooks(String versionId) {
    final cacheKey = 'books:$versionId';

    return _dedupe(cacheKey, () async {
      final cached = await _cache.getJson(cacheKey);
      final items = cached?['items'];
      if (items is List) {
        return items
            .whereType<Map>()
            .map((e) => BibleBook.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }

      final uri =
          Uri.https('api.youversion.com', '/v1/bibles/$versionId/books');
      final response = await http.get(uri, headers: _headers);
      if (response.statusCode != 200) {
        throw Exception('Failed to load Bible books: ${response.statusCode}');
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final List books = data['data'] ?? [];
      await _cache.putJson(cacheKey, books, BibleCache.booksTtl);
      return books
          .map((b) => BibleBook.fromJson(Map<String, dynamic>.from(b as Map)))
          .toList();
    });
  }

  Future<List<BibleChapter>> getChapters(String versionId, String bookId) {
    final cacheKey = 'chapters:$versionId:$bookId';

    return _dedupe(cacheKey, () async {
      final cached = await _cache.getJson(cacheKey);
      final items = cached?['items'];
      if (items is List) {
        return items
            .whereType<Map>()
            .map((e) => BibleChapter.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }

      final uri = Uri.https(
        'api.youversion.com',
        '/v1/bibles/$versionId/books/$bookId/chapters',
      );
      final response = await http.get(uri, headers: _headers);
      if (response.statusCode != 200) {
        throw Exception('Failed to load Bible chapters: ${response.statusCode}');
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final List chapters = data['data'] ?? [];
      await _cache.putJson(cacheKey, chapters, BibleCache.chaptersTtl);
      return chapters
          .map((c) => BibleChapter.fromJson(Map<String, dynamic>.from(c as Map)))
          .toList();
    });
  }

  Future<BibleContent> getChapterContent(
    String versionId,
    String bookId,
    String chapterId,
  ) {
    final reference = chapterId.contains('.') ? chapterId : '$bookId.$chapterId';
    return getPassageContent(versionId, reference);
  }

  Future<BibleContent> getPassageContent(String versionId, String reference) {
    final cacheKey = 'passage:$versionId:$reference';

    return _dedupe(cacheKey, () async {
      final cached = await _cache.getPassage(cacheKey);
      if (cached != null) {
        return BibleContent.fromCachedJson(cached);
      }

      final uri = Uri.https(
        'api.youversion.com',
        '/v1/bibles/$versionId/passages/$reference',
        {'format': 'html'},
      );

      final response = await http.get(uri, headers: _headers);
      if (response.statusCode != 200) {
        throw Exception('Failed to load Bible content: ${response.statusCode}');
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final contentData =
          Map<String, dynamic>.from((data['data'] ?? data) as Map);
      await _cache.putPassage(cacheKey, contentData, BibleCache.passageTtl);
      return BibleContent.fromJson(contentData);
    });
  }

  Future<String> getVotdPassageId(int day) {
    final now = DateTime.now();
    final cacheKey = 'votd:${now.year}:$day';

    return _dedupe(cacheKey, () async {
      final cached = await _cache.getJson(cacheKey);
      final passageId = cached?['passage_id'];
      if (passageId is String && passageId.isNotEmpty) {
        return passageId;
      }

      final uri =
          Uri.https('api.youversion.com', '/v1/verse_of_the_days/$day');
      final response = await http.get(uri, headers: _headers);
      if (response.statusCode != 200) {
        throw Exception(
            'Failed to load VOTD passage ID: ${response.statusCode}');
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final id = data['passage_id'] as String;
      await _cache.putJsonUntil(
        cacheKey,
        {'passage_id': id},
        BibleCache.endOfLocalDay(now),
      );
      return id;
    });
  }
}
