import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:lw_app/Blocs/NoteEdit/note_edit_bloc.dart';
import 'package:lw_app/Blocs/Notes/notes_bloc.dart';
import 'package:lw_app/Models/Note/note.dart';
import 'package:lw_app/Utils/quill_helper.dart';
import 'package:lw_app/Widgets/LwpSnackbar/lwp_snackbar.dart';
import 'package:lw_app/Widgets/LwpError/lwp_error.dart';
import 'package:lw_app/Widgets/LwpLoader/lwp_loader.dart';

class NotesEditPage extends StatefulWidget {
  final String? noteId;

  const NotesEditPage({super.key, this.noteId});

  @override
  State<NotesEditPage> createState() => _NotesEditPageState();
}

class _NotesEditPageState extends State<NotesEditPage> {
  bool _isEdit = false;
  bool _isInitialized = false;
  bool _showSaved = false;
  Note? _currentNote;

  Timer? _debounceTimer;
  Timer? _savedTimer;
  StreamSubscription<DocChange>? _quillSubscription;

  late final TextEditingController _titleController;
  late final FocusNode _editorFocusNode;
  late final ScrollController _editorScrollController;
  QuillController? _quillController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _editorFocusNode = FocusNode();
    _editorScrollController = ScrollController();

    if (widget.noteId != null && widget.noteId != '') {
      _isEdit = true;
      context.read<NoteEditBloc>().add(LoadNote(widget.noteId!));
    } else {
      _isEdit = false;
      context.read<NoteEditBloc>().add(const CreateNote('', ''));
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _savedTimer?.cancel();
    _quillSubscription?.cancel();
    _titleController.dispose();
    _editorFocusNode.dispose();
    _editorScrollController.dispose();
    _quillController?.dispose();
    super.dispose();
  }

  void _initForm(Note note) {
    if (_isInitialized) return;
    _titleController.text = note.title ?? '';
    _quillController = QuillController(
      document: QuillHelper.fromContent(note.content),
      selection: const TextSelection.collapsed(offset: 0),
    );
    _currentNote = note;
    _quillSubscription = _quillController!.changes.listen((change) {
      if (change.source == ChangeSource.local) _scheduleSave();
    });
    setState(() => _isInitialized = true);
  }

  void _scheduleSave() {
    if (!_isInitialized || _currentNote == null) return;
    // Hide the saved icon if it's still showing
    if (_showSaved) setState(() => _showSaved = false);
    _savedTimer?.cancel();
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 450), _performSave);
  }

  void _performSave() {
    if (_currentNote == null || !mounted) return;
    context.read<NoteEditBloc>().add(UpdateNote(
      note: Note(
        id: _currentNote!.id,
        userId: _currentNote!.userId,
        title: _titleController.text,
        content: QuillHelper.toJson(_quillController!),
        createdAt: _currentNote!.createdAt,
      ),
    ));
  }

  void _handleBack() {
    _debounceTimer?.cancel();
    _savedTimer?.cancel();

    final notesBloc = context.read<NotesBloc>();
    final noteEditBloc = context.read<NoteEditBloc>();

    if (_currentNote != null && _isInitialized) {
      final title = _titleController.text.trim();
      final content = QuillHelper.toJson(_quillController!);
      final plainText = QuillHelper.plainTextPreview(content);

      if (title.isEmpty && plainText.isEmpty) {
        notesBloc.add(DeleteNote(noteId: _currentNote!.id!));
      } else {
        noteEditBloc.add(UpdateNote(
          note: Note(
            id: _currentNote!.id,
            userId: _currentNote!.userId,
            title: _titleController.text,
            content: content,
            createdAt: _currentNote!.createdAt,
          ),
        ));
      }
    }

    notesBloc.add(const LoadNotes());
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = (theme.appBarTheme.foregroundColor ?? theme.colorScheme.onSurface)
        .withValues(alpha: 0.6);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleBack();
      },
      child: BlocListener<NoteEditBloc, NoteEditState>(
        listener: (context, state) {
          if (state is NoteCreateSuccess) _initForm(state.note);
          if (state is NoteSuccess) _initForm(state.note);
          if (state is NoteUpdateSuccess) {
            setState(() => _showSaved = true);
            _savedTimer?.cancel();
            _savedTimer = Timer(const Duration(seconds: 2), () {
              if (mounted) setState(() => _showSaved = false);
            });
          }
          if (state is NoteError) {
            LwpSnackbar.showError(context, 'Iets het fout gegaan');
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(_isEdit ? 'Wysig Nota' : 'Skep Nota'),
            actions: [
              if (_isInitialized)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _showSaved
                        ? Icon(
                            Icons.cloud_done_outlined,
                            key: const ValueKey(true),
                            size: 20,
                            color: iconColor,
                          )
                        : SizedBox.shrink(key: const ValueKey(false)),
                  ),
                ),
            ],
          ),
          body: SafeArea(
            child: BlocBuilder<NoteEditBloc, NoteEditState>(
              buildWhen: (previous, current) =>
                  current is NoteLoading || current is NoteError,
              builder: (context, state) {
                if (!_isInitialized) {
                  if (state is NoteError) return const LwpError();
                  return const LwpLoader();
                }
                return _buildEditor(theme);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditor(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: TextField(
            controller: _titleController,
            style: theme.textTheme.titleLarge,
            decoration: InputDecoration(
              hintText: 'Titel',
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
            onChanged: (_) => _scheduleSave(),
          ),
        ),
        const Divider(height: 1),
        QuillSimpleToolbar(
          controller: _quillController!,
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
          child: QuillEditor(
            controller: _quillController!,
            focusNode: _editorFocusNode,
            scrollController: _editorScrollController,
            config: const QuillEditorConfig(
              expands: true,
              scrollable: true,
              placeholder: 'Skryf jou nota hier...',
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              autoFocus: false,
            ),
          ),
        ),
      ],
    );
  }
}
