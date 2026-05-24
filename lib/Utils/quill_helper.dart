import 'dart:convert';

import 'package:flutter_quill/flutter_quill.dart';

class QuillHelper {
  static Document fromContent(String? content) {
    if (content == null || content.trim().isEmpty) return Document();
    try {
      final decoded = jsonDecode(content);
      if (decoded is List) return Document.fromJson(decoded);
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
      if (decoded is List) {
        final text = Document.fromJson(decoded).toPlainText().trim();
        return text.length <= maxLength ? text : '${text.substring(0, maxLength)}...';
      }
    } catch (_) {}
    final text = content.trim();
    return text.length <= maxLength ? text : '${text.substring(0, maxLength)}...';
  }
}
