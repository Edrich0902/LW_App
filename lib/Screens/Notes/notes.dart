import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lw_app/Blocs/Notes/notes_bloc.dart';
import 'package:lw_app/Extensions/context_l10n.dart';
import 'package:lw_app/Widgets/LwpSnackbar/lwp_snackbar.dart';
import 'package:lw_app/Models/Note/note.dart';
import 'package:lw_app/Screens/NotesEdit/notes_edit.dart';
import 'package:lw_app/Themes/lwp_tokens.dart';
import 'package:lw_app/Widgets/LwpError/lwp_error.dart';
import 'package:lw_app/Widgets/LwpLoader/lwp_loader.dart';
import 'package:lw_app/Widgets/LwpEmpty/lwp_empty.dart';
import 'package:lw_app/Utils/quill_helper.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    context.read<NotesBloc>().add(const LoadNotes());
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Note> _filterNotes(List<Note> notes) {
    final query = _searchController.text.toLowerCase().trim();
    if (query.isEmpty) return notes;
    return notes
        .where((n) => (n.title ?? '').toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final notesBloc = BlocProvider.of<NotesBloc>(context);

    return BlocListener<NotesBloc, NotesState>(
      listener: (context, state) {
        if (state is NotesDeleteSuccess) {
          HapticFeedback.mediumImpact();
          LwpSnackbar.showSuccess(context, context.l10n.notesDeleteSuccess);
        }
        if (state is NotesError) {
          LwpSnackbar.showError(context, context.l10n.notesGenericError);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.notesTitle),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotesEditPage(),
              ),
            );
          },
          child: const Icon(Icons.add),
        ),
        body: SafeArea(
          child: BlocBuilder<NotesBloc, NotesState>(
            builder: (context, state) {
              if (state is NotesLoading) {
                return const LwpLoader();
              } else if (state is NotesSuccess) {
                final filtered = _filterNotes(state.data);

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: context.l10n.notesSearchHint,
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 0),
                          border: OutlineInputBorder(
                            borderRadius: LwpRadii.lgAll,
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: LwpRadii.lgAll,
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: LwpRadii.lgAll,
                            borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: filtered.isEmpty
                          ? LwpEmpty(message: context.l10n.notesEmpty)
                          : RefreshIndicator(
                              onRefresh: () async =>
                                  notesBloc.add(const LoadNotes()),
                              child: ListView.separated(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 8, 16, 100),
                                itemCount: filtered.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final note = filtered[index];
                                  return _buildNoteCard(
                                    note,
                                    onDelete: () => _confirmDelete(
                                        context,
                                        () => notesBloc.add(
                                            DeleteNote(noteId: note.id ?? ''))),
                                    onEdit: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => NotesEditPage(
                                          noteId: note.id ?? '',
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                );
              } else {
                return const LwpError();
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNoteCard(
    Note note, {
    required VoidCallback onDelete,
    required VoidCallback onEdit,
  }) {
    final theme = Theme.of(context);
    final preview = QuillHelper.plainTextPreview(note.content);
    final date = _formatDate(note.updatedAt ?? note.createdAt);

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: LwpRadii.lgAll,
        side: BorderSide(color: theme.dividerColor),
      ),
      child: InkWell(
        onTap: onEdit,
        borderRadius: LwpRadii.lgAll,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                    child: Icon(Icons.note_alt_outlined,
                        color: theme.primaryColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          note.title ?? '',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (date != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            date,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.hintColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline,
                        color: Colors.redAccent, size: 20),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              if (preview.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  preview,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String? _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final dt = DateTime.tryParse(raw);
    if (dt == null) return null;
    return DateFormat('dd MMM yyyy, HH:mm').format(dt.toLocal());
  }

  void _confirmDelete(BuildContext context, VoidCallback confirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(context.l10n.notesDeleteTitle),
          content: Text(context.l10n.notesDeleteBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
              child: Text(context.l10n.commonCancel),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
                confirm();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              child: Text(context.l10n.commonConfirm),
            ),
          ],
        );
      },
    );
  }
}
