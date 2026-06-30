import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lw_app/Extensions/context_l10n.dart';
import 'package:lw_app/Models/Bible/verse_image_draft.dart';
import 'package:lw_app/Utils/share_helper.dart';
import 'package:lw_app/Widgets/LwpSnackbar/lwp_snackbar.dart';

enum VerseImageAspectRatio {
  square(1),
  portrait(4 / 5),
  story(9 / 16);

  const VerseImageAspectRatio(this.value);

  final double value;
}

enum VerseImageTextSize {
  small(24),
  medium(30),
  large(36);

  const VerseImageTextSize(this.fontSize);

  final double fontSize;
}

extension VerseImageAspectRatioExtension on VerseImageAspectRatio {
  String getLocalizedLabel(BuildContext context) {
    switch (this) {
      case VerseImageAspectRatio.square:
        return context.l10n.bibleImageFormatSquare;
      case VerseImageAspectRatio.portrait:
        return context.l10n.bibleImageFormatPortrait;
      case VerseImageAspectRatio.story:
        return context.l10n.bibleImageFormatStory;
    }
  }
}

extension VerseImageTextSizeExtension on VerseImageTextSize {
  String getLocalizedLabel(BuildContext context) {
    switch (this) {
      case VerseImageTextSize.small:
        return context.l10n.bibleImageTextSizeSmall;
      case VerseImageTextSize.medium:
        return context.l10n.bibleImageTextSizeMedium;
      case VerseImageTextSize.large:
        return context.l10n.bibleImageTextSizeLarge;
    }
  }
}


class VerseImageEditorScreen extends StatefulWidget {
  final VerseImageDraft draft;

  const VerseImageEditorScreen({
    super.key,
    required this.draft,
  });

  @override
  State<VerseImageEditorScreen> createState() => _VerseImageEditorScreenState();
}

class _VerseImageEditorScreenState extends State<VerseImageEditorScreen> {
  final _previewKey = GlobalKey();
  final _imagePicker = ImagePicker();

  ImageProvider? _backgroundImage;
  VerseImageAspectRatio _aspectRatio = VerseImageAspectRatio.square;
  VerseImageTextSize _textSize = VerseImageTextSize.medium;
  TextAlign _textAlign = TextAlign.center;
  double _overlayStrength = 0.45;
  bool _useLightText = true;
  bool _isExporting = false;

  Future<void> _pickImage(ImageSource source) async {
    final image = await _imagePicker.pickImage(
      source: source,
      imageQuality: 92,
      maxWidth: 2400,
    );

    if (image == null) return;

    final bytes = await image.readAsBytes();
    if (!mounted) return;

    setState(() => _backgroundImage = MemoryImage(bytes));
  }

  Future<Uint8List?> _exportPng() async {
    if (_backgroundImage == null || _isExporting) return null;

    setState(() => _isExporting = true);

    try {
      await WidgetsBinding.instance.endOfFrame;
      final boundary = _previewKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _shareImage() async {
    final bytes = await _exportPng();
    if (bytes == null || !mounted) return;

    await ShareHelper.shareImage(
      context,
      bytes: bytes,
      fileName: _fileName(),
      subject: widget.draft.citation,
    );
  }

  Future<void> _saveImage() async {
    final bytes = await _exportPng();
    if (bytes == null || !mounted) return;

    try {
      await Gal.putImageBytes(
        bytes,
        album: 'Lewende Woord Paarl',
        name: _fileName(),
      );
      if (mounted) {
        LwpSnackbar.showSuccess(context, context.l10n.bibleImageSaved);
      }
    } catch (_) {
      if (mounted) {
        LwpSnackbar.showError(
          context,
          context.l10n.bibleImageSaveError,
        );
      }
    }
  }

  String _fileName() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'lw_vers_$timestamp.png';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canExport = _backgroundImage != null && !_isExporting;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.bibleCreateImage),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Center(
              child: RepaintBoundary(
                key: _previewKey,
                child: VerseImagePreview(
                  draft: widget.draft,
                  backgroundImage: _backgroundImage,
                  aspectRatio: _aspectRatio.value,
                  textSize: _textSize.fontSize,
                  textAlign: _textAlign,
                  overlayStrength: _overlayStrength,
                  useLightText: _useLightText,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: Text(context.l10n.authGallery),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: Text(context.l10n.authCamera),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _ControlLabel(context.l10n.bibleImageFormat, theme: theme),
            SegmentedButton<VerseImageAspectRatio>(
              segments: VerseImageAspectRatio.values
                  .map(
                    (ratio) => ButtonSegment(
                      value: ratio,
                      label: Text(ratio.getLocalizedLabel(context)),
                    ),
                  )
                  .toList(),
              selected: {_aspectRatio},
              onSelectionChanged: (selection) {
                setState(() => _aspectRatio = selection.first);
              },
            ),
            const SizedBox(height: 16),
            _ControlLabel(context.l10n.bibleImageTextSize, theme: theme),
            SegmentedButton<VerseImageTextSize>(
              segments: VerseImageTextSize.values
                  .map(
                    (size) => ButtonSegment(
                      value: size,
                      label: Text(size.getLocalizedLabel(context)),
                    ),
                  )
                  .toList(),
              selected: {_textSize},
              onSelectionChanged: (selection) {
                setState(() => _textSize = selection.first);
              },
            ),
            const SizedBox(height: 16),
            _ControlLabel(context.l10n.bibleImageAlignment, theme: theme),
            SegmentedButton<TextAlign>(
              segments: const [
                ButtonSegment(
                  value: TextAlign.left,
                  icon: Icon(Icons.format_align_left),
                ),
                ButtonSegment(
                  value: TextAlign.center,
                  icon: Icon(Icons.format_align_center),
                ),
                ButtonSegment(
                  value: TextAlign.right,
                  icon: Icon(Icons.format_align_right),
                ),
              ],
              selected: {_textAlign},
              onSelectionChanged: (selection) {
                setState(() => _textAlign = selection.first);
              },
            ),
            const SizedBox(height: 16),
            _ControlLabel(context.l10n.bibleImageOverlay, theme: theme),
            Slider(
              value: _overlayStrength,
              min: 0.2,
              max: 0.75,
              divisions: 11,
              label: '${(_overlayStrength * 100).round()}%',
              onChanged: (value) => setState(() => _overlayStrength = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _useLightText,
              title: Text(context.l10n.bibleImageLightText),
              onChanged: (value) => setState(() => _useLightText = value),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: canExport ? _saveImage : null,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    icon: const Icon(Icons.download_outlined),
                    label: Text(context.l10n.bibleImageDownload),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: canExport ? _shareImage : null,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    icon: const Icon(Icons.share_outlined),
                    label: Text(
                      _isExporting
                          ? context.l10n.bibleImageCreating
                          : context.l10n.commonShare,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class VerseImagePreview extends StatelessWidget {
  final VerseImageDraft draft;
  final ImageProvider? backgroundImage;
  final double aspectRatio;
  final double textSize;
  final TextAlign textAlign;
  final double overlayStrength;
  final bool useLightText;

  const VerseImagePreview({
    super.key,
    required this.draft,
    required this.backgroundImage,
    required this.aspectRatio,
    required this.textSize,
    required this.textAlign,
    required this.overlayStrength,
    required this.useLightText,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = useLightText ? Colors.white : const Color(0xFF111111);
    final overlayColor = useLightText ? Colors.black : Colors.white;

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFE9E4DC),
          image: backgroundImage == null
              ? null
              : DecorationImage(
                  image: backgroundImage!,
                  fit: BoxFit.cover,
                ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (backgroundImage == null)
              const Center(
                child: Icon(
                  Icons.add_photo_alternate_outlined,
                  size: 56,
                  color: Color(0xFF77736B),
                ),
              ),
            ColoredBox(
              color: overlayColor.withValues(alpha: overlayStrength),
            ),
            Padding(
              padding: const EdgeInsets.all(28),
              child: LayoutBuilder(
                builder: (context, constraints) => FittedBox(
                  fit: BoxFit.scaleDown,
                  child: SizedBox(
                    width: constraints.maxWidth,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: _crossAxisAlignment(textAlign),
                      children: [
                        Text(
                          draft.verseText,
                          textAlign: textAlign,
                          style: TextStyle(
                            color: textColor,
                            fontSize: textSize,
                            height: 1.22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          draft.citation,
                          textAlign: textAlign,
                          style: TextStyle(
                            color: textColor.withValues(alpha: 0.88),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (draft.footer != null &&
                            draft.footer!.isNotEmpty) ...[
                          const SizedBox(height: 28),
                          Text(
                            draft.footer!,
                            textAlign: textAlign,
                            style: TextStyle(
                              color: textColor.withValues(alpha: 0.76),
                              fontSize: 13,
                              letterSpacing: 0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  CrossAxisAlignment _crossAxisAlignment(TextAlign align) {
    switch (align) {
      case TextAlign.left:
      case TextAlign.start:
        return CrossAxisAlignment.start;
      case TextAlign.right:
      case TextAlign.end:
        return CrossAxisAlignment.end;
      case TextAlign.center:
      case TextAlign.justify:
        return CrossAxisAlignment.center;
    }
  }
}

class _ControlLabel extends StatelessWidget {
  final String text;
  final ThemeData theme;

  const _ControlLabel(this.text, {required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
