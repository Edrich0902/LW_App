import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:lw_app/Extensions/context_l10n.dart';
import 'package:lw_app/Models/Group/group_post.dart';
import 'package:lw_app/Themes/lwp_tokens.dart';
import 'package:lw_app/Utils/quill_helper.dart';

class GroupPostDraft {
  final String title;
  final String content;

  const GroupPostDraft({
    required this.title,
    required this.content,
  });
}

class GroupPostEditPage extends StatefulWidget {
  final GroupPost? post;

  const GroupPostEditPage({
    super.key,
    this.post,
  });

  @override
  State<GroupPostEditPage> createState() => _GroupPostEditPageState();
}

class _GroupPostEditPageState extends State<GroupPostEditPage> {
  late final TextEditingController _titleController;
  late final FocusNode _editorFocusNode;
  late final ScrollController _editorScrollController;
  late final QuillController _quillController;

  bool _isSaving = false;

  bool get _isEdit => widget.post != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.post?.title ?? '');
    _editorFocusNode = FocusNode();
    _editorScrollController = ScrollController();
    _quillController = QuillController(
      document: QuillHelper.fromContent(widget.post?.content),
      selection: const TextSelection.collapsed(offset: 0),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _editorFocusNode.dispose();
    _editorScrollController.dispose();
    _quillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEdit ? context.l10n.groupPostEditTitle : context.l10n.groupPostNewTitle,
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _submit,
            child: Text(
              _isEdit ? context.l10n.commonSave : context.l10n.groupPostPublish,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: LwpSpacing.md,
                vertical: LwpSpacing.sm,
              ),
              child: TextField(
                controller: _titleController,
                style: theme.textTheme.titleLarge,
                decoration: InputDecoration(
                  hintText: context.l10n.groupPostTitleOptional,
                  hintStyle: theme.textTheme.titleLarge?.copyWith(
                    color: theme.hintColor,
                    fontWeight: FontWeight.normal,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
            const Divider(height: 1),
            QuillSimpleToolbar(
              controller: _quillController,
              config: const QuillSimpleToolbarConfig(
                multiRowsDisplay: false,
                showDividers: false,
                showFontFamily: false,
                showFontSize: false,
                showSmallButton: false,
                showLineHeightButton: false,
                showStrikeThrough: false,
                showInlineCode: false,
                showColorButton: false,
                showBackgroundColorButton: false,
                showClearFormat: false,
                showAlignmentButtons: false,
                showListCheck: false,
                showCodeBlock: false,
                showQuote: false,
                showIndent: false,
                showLink: false,
                showDirection: false,
                showSearchButton: false,
                showSubscript: false,
                showSuperscript: false,
                showBoldButton: true,
                showItalicButton: true,
                showUnderLineButton: true,
                showHeaderStyle: true,
                showListBullets: true,
                showListNumbers: true,
                showUndo: true,
                showRedo: true,
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Stack(
                children: [
                  QuillEditor(
                    controller: _quillController,
                    focusNode: _editorFocusNode,
                    scrollController: _editorScrollController,
                    config: const QuillEditorConfig(
                      expands: true,
                      scrollable: true,
                      placeholder: '',
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      autoFocus: false,
                    ),
                ),
                  Positioned.fill(
                    child: IgnorePointer(
                      ignoring: true,
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: ListenableBuilder(
                            listenable: _quillController,
                            builder: (context, _) {
                              final plain = QuillHelper.plainTextPreview(
                                QuillHelper.toJson(_quillController),
                                maxLength: 10,
                              ).trim();
                              if (plain.isNotEmpty) {
                                return const SizedBox.shrink();
                              }
                              return Text(
                                context.l10n.groupPostBodyPlaceholder,
                                style: TextStyle(color: theme.hintColor),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_isSaving)
                    const Positioned.fill(
                      child: ColoredBox(
                        color: Color(0x66000000),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    final content = QuillHelper.toJson(_quillController);
    final plainText = QuillHelper.plainTextPreview(content, maxLength: 5000);

    if (plainText.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.groupPostBodyRequired)),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    Navigator.of(context).pop(
      GroupPostDraft(
        title: _titleController.text.trim(),
        content: content,
      ),
    );
  }
}
