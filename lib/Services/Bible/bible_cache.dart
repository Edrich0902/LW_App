import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local TTL cache for YouVersion responses (Phase 1).
///
/// Metadata lives in SharedPreferences; passage HTML in app-support files so
/// we do not blow prefs size limits.
class BibleCache {
  BibleCache();

  static const _prefsPrefix = 'yv_cache_v1:';
  static const versionsTtl = Duration(days: 7);
  static const booksTtl = Duration(days: 30);
  static const chaptersTtl = Duration(days: 30);
  static const passageTtl = Duration(days: 7);

  final Map<String, _MemoryEntry> _memory = {};
  Future<SharedPreferences>? _prefsFuture;
  Future<Directory>? _passageDirFuture;

  Future<SharedPreferences> get _prefs async =>
      _prefsFuture ??= SharedPreferences.getInstance();

  Future<Directory> get _passageDir async {
    return _passageDirFuture ??= () async {
      final root = await getApplicationSupportDirectory();
      final dir = Directory('${root.path}/youversion_passages');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      return dir;
    }();
  }

  /// End of local calendar day (VOTD key lifetime).
  static DateTime endOfLocalDay([DateTime? now]) {
    final n = now ?? DateTime.now();
    return DateTime(n.year, n.month, n.day, 23, 59, 59, 999);
  }

  T? getMemory<T>(String key) {
    final entry = _memory[key];
    if (entry == null) return null;
    if (DateTime.now().isAfter(entry.expiresAt)) {
      _memory.remove(key);
      return null;
    }
    return entry.value as T?;
  }

  void putMemory(String key, Object value, DateTime expiresAt) {
    _memory[key] = _MemoryEntry(value: value, expiresAt: expiresAt);
  }

  Future<Map<String, dynamic>?> getJson(String key) async {
    final mem = getMemory<Map<String, dynamic>>(key);
    if (mem != null) return mem;

    final prefs = await _prefs;
    final raw = prefs.getString('$_prefsPrefix$key');
    if (raw == null) return null;

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final expiresMs = decoded['expiresAt'] as int?;
      if (expiresMs == null) return null;
      final expiresAt = DateTime.fromMillisecondsSinceEpoch(expiresMs);
      if (DateTime.now().isAfter(expiresAt)) {
        await prefs.remove('$_prefsPrefix$key');
        return null;
      }
      final data = decoded['data'];
      if (data is Map<String, dynamic>) {
        putMemory(key, data, expiresAt);
        return data;
      }
      // List payloads wrapped as { "items": [...] }
      if (data is List) {
        final wrapped = <String, dynamic>{'items': data};
        putMemory(key, wrapped, expiresAt);
        return wrapped;
      }
      return null;
    } catch (_) {
      await prefs.remove('$_prefsPrefix$key');
      return null;
    }
  }

  Future<void> putJson(
    String key,
    Object data,
    Duration ttl,
  ) async {
    final expiresAt = DateTime.now().add(ttl);
    final wrapped = data is Map<String, dynamic>
        ? data
        : <String, dynamic>{'items': data};

    putMemory(key, wrapped, expiresAt);

    final prefs = await _prefs;
    await prefs.setString(
      '$_prefsPrefix$key',
      jsonEncode({
        'expiresAt': expiresAt.millisecondsSinceEpoch,
        'data': data,
      }),
    );
  }

  Future<void> putJsonUntil(
    String key,
    Object data,
    DateTime expiresAt,
  ) async {
    final wrapped = data is Map<String, dynamic>
        ? data
        : <String, dynamic>{'items': data};
    putMemory(key, wrapped, expiresAt);

    final prefs = await _prefs;
    await prefs.setString(
      '$_prefsPrefix$key',
      jsonEncode({
        'expiresAt': expiresAt.millisecondsSinceEpoch,
        'data': data,
      }),
    );
  }

  Future<Map<String, dynamic>?> getPassage(String key) async {
    final mem = getMemory<Map<String, dynamic>>(key);
    if (mem != null) return mem;

    try {
      final dir = await _passageDir;
      final file = File('${dir.path}/${_fileName(key)}.json');
      if (!await file.exists()) return null;
      final decoded = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      final expiresMs = decoded['expiresAt'] as int?;
      if (expiresMs == null) return null;
      final expiresAt = DateTime.fromMillisecondsSinceEpoch(expiresMs);
      if (DateTime.now().isAfter(expiresAt)) {
        await file.delete();
        return null;
      }
      final data = decoded['data'];
      if (data is Map<String, dynamic>) {
        putMemory(key, data, expiresAt);
        return data;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> putPassage(
    String key,
    Map<String, dynamic> data,
    Duration ttl,
  ) async {
    final expiresAt = DateTime.now().add(ttl);
    putMemory(key, data, expiresAt);

    try {
      final dir = await _passageDir;
      final file = File('${dir.path}/${_fileName(key)}.json');
      await file.writeAsString(
        jsonEncode({
          'expiresAt': expiresAt.millisecondsSinceEpoch,
          'data': data,
        }),
      );
    } catch (_) {
      // Memory cache still helps for this session.
    }
  }

  static String _fileName(String key) {
    // Keep filesystem-safe; collide-safe enough for our keys.
    return key.replaceAll(RegExp(r'[^A-Za-z0-9._-]+'), '_');
  }
}

class _MemoryEntry {
  _MemoryEntry({required this.value, required this.expiresAt});

  final Object value;
  final DateTime expiresAt;
}
