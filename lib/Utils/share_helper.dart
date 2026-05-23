import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lw_app/Widgets/LwpSnackbar/lwp_snackbar.dart';
import 'package:share_plus/share_plus.dart';

class ShareHelper {
  const ShareHelper._();

  static Future<void> shareText(
    BuildContext context, {
    required String text,
    String? subject,
    String clipboardMessage = 'Gekopieër na klembord',
  }) async {
    try {
      await Share.share(
        text,
        subject: subject,
        sharePositionOrigin: _sharePositionOrigin(context),
      );
    } on PlatformException {
      // ignore: use_build_context_synchronously
      await _copyToClipboard(context, text, clipboardMessage);
    } catch (_) {
      // ignore: use_build_context_synchronously
      await _copyToClipboard(context, text, clipboardMessage);
    }
  }

  static Future<void> shareImage(
    BuildContext context, {
    required Uint8List bytes,
    required String fileName,
    String? subject,
  }) async {
    try {
      await Share.shareXFiles(
        [
          XFile.fromData(
            bytes,
            name: fileName,
            mimeType: 'image/png',
          ),
        ],
        subject: subject,
        sharePositionOrigin: _sharePositionOrigin(context),
      );
    } catch (_) {
      if (context.mounted) {
        LwpSnackbar.showError(context, 'Kon nie die beeld deel nie');
      }
    }
  }

  static Rect _sharePositionOrigin(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    if (size.width <= 0 || size.height <= 0) {
      return const Rect.fromLTWH(1, 1, 1, 1);
    }

    final originWidth = size.width < 1 ? size.width : 1.0;
    final originHeight = size.height < 1 ? size.height : 1.0;

    return Rect.fromLTWH(
      (size.width - originWidth) / 2,
      (size.height - originHeight) / 2,
      originWidth,
      originHeight,
    );
  }

  static Future<void> _copyToClipboard(
    BuildContext context,
    String text,
    String message,
  ) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      LwpSnackbar.showSuccess(context, message);
    }
  }
}
