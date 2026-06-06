import 'dart:convert';

import 'package:flutter_quill/flutter_quill.dart';

class QuillHelper {
  static Document fromContent(String? content) {
    if (content == null || content.trim().isEmpty) return Document();
    try {
      final decoded = jsonDecode(content);
      // Plain ops array: [...] — stored by older Quill integrations
      if (decoded is List) return Document.fromJson(decoded);
      // Delta object: {"ops": [...]} — stored by the portal's LwpQuillEditor
      if (decoded is Map && decoded['ops'] is List) {
        return Document.fromJson(decoded['ops'] as List);
      }
    } catch (_) {}
    // Legacy plain-text fallback
    return Document()..insert(0, content);
  }

  static String toJson(QuillController controller) =>
      jsonEncode(controller.document.toDelta().toJson());

  static String plainTextPreview(String? content, {int maxLength = 150}) {
    if (content == null || content.trim().isEmpty) return '';
    try {
      final decoded = jsonDecode(content);
      List? ops;
      if (decoded is List) ops = decoded;
      if (decoded is Map && decoded['ops'] is List) ops = decoded['ops'] as List;
      if (ops != null) {
        final text = Document.fromJson(ops).toPlainText().trim();
        return text.length <= maxLength ? text : '${text.substring(0, maxLength)}...';
      }
    } catch (_) {}
    final text = content.trim();
    return text.length <= maxLength ? text : '${text.substring(0, maxLength)}...';
  }
}
