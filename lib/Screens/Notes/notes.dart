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
import 'package:lw_app/Widgets/LwpSkeleton/lwp_skeleton.dart';
import 'package:lw_app/Widgets/LwpEmpty/lwp_empty.dart';
import 'package:lw_app/Widgets/Glass/lwp_chrome_scaffold.dart';
import 'package:lw_app/Widgets/Glass/lwp_glass_fab.dart';
import 'package:lw_app/Utils/quill_helper.dart';
import 'package:lw_app/Widgets/LwpListEntrance/lwp_list_entrance.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final TextEditingController _searchController = TextEditingController();
  final _listEntrance = LwpListEntranceController();

  @override
  void initState() {
    context.read<NotesBloc>().add(const LoadNotes());
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _listEntrance.dispose();
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
      child: LwpChromeScaffold(
        title: context.l10n.notesTitle,
        floatingActionButton: LwpGlassFab(
          heroTag: 'notes-fab',
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
        body: BlocBuilder<NotesBloc, NotesState>(
            builder: (context, state) {
              if (state is NotesLoading) {
                return LwpSkeletonList.text();
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
                          : LwpListEntranceScope(
                              controller: _listEntrance,
                              child: RefreshIndicator(
                                onRefresh: () async {
                                  _listEntrance.bump();
                                  notesBloc.add(const LoadNotes());
                                },
                                child: ListView.separated(
                                  padding: const EdgeInsets.fromLTRB(
                                    LwpSpacing.md,
                                    LwpSpacing.xs,
                                    LwpSpacing.md,
                                    100,
                                  ),
                                  itemCount: filtered.length,
                                  separatorBuilder: (_, __) => Divider(
                                    height: 1,
                                    thickness: 1,
                                    color: Theme.of(context)
                                        .dividerColor
                                        .withValues(alpha: 0.35),
                                  ),
                                  itemBuilder: (context, index) {
                                    final note = filtered[index];
                                    final id = note.id ?? 'note-$index';
                                    return Dismissible(
                                      key: Key(id),
                                      direction: DismissDirection.endToStart,
                                      confirmDismiss: (_) => _confirmDelete(
                                        context,
                                      ),
                                      onDismissed: (_) {
                                        if (note.id == null) return;
                                        notesBloc.add(
                                          DeleteNote(noteId: note.id!),
                                        );
                                      },
                                      background: Container(
                                        alignment: Alignment.centerRight,
                                        padding: const EdgeInsets.only(
                                          right: LwpSpacing.lg,
                                        ),
                                        color: Colors.redAccent
                                            .withValues(alpha: 0.16),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            const Icon(
                                              Icons.delete_outline,
                                              size: 20,
                                              color: Colors.redAccent,
                                            ),
                                            const SizedBox(
                                              width: LwpSpacing.xs,
                                            ),
                                            Text(
                                              context.l10n.commonDelete,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelMedium
                                                  ?.copyWith(
                                                    color: Colors.redAccent,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      child: LwpListEntrance(
                                        id: id,
                                        child: _buildNoteRow(
                                          note,
                                          onEdit: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  NotesEditPage(
                                                noteId: note.id ?? '',
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
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
    );
  }

  Widget _buildNoteRow(Note note, {required VoidCallback onEdit}) {
    final theme = Theme.of(context);
    final preview = QuillHelper.plainTextPreview(note.content);
    final date = _formatDate(note.updatedAt ?? note.createdAt);
    final title = (note.title ?? '').trim().isEmpty
        ? context.l10n.notesTitleHint
        : note.title!;

    return InkWell(
      onTap: onEdit,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: LwpSpacing.md,
          horizontal: LwpSpacing.xxs,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                if (date != null) ...[
                  const SizedBox(width: LwpSpacing.sm),
                  Text(
                    date,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.hintColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
            if (preview.isNotEmpty) ...[
              const SizedBox(height: LwpSpacing.xs),
              Text(
                preview,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.hintColor,
                  height: 1.45,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String? _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final dt = DateTime.tryParse(raw);
    if (dt == null) return null;
    return DateFormat('d MMM').format(dt.toLocal());
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(context.l10n.notesDeleteTitle),
          content: Text(context.l10n.notesDeleteBody),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(context, rootNavigator: true).pop(false),
              child: Text(context.l10n.commonCancel),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.of(context, rootNavigator: true).pop(true),
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
    return confirmed ?? false;
  }
}
