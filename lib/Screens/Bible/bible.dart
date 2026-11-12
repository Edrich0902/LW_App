import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Extensions/context_l10n.dart';
import 'package:lw_app/Blocs/Bible/bible_bloc.dart';
import 'package:lw_app/Blocs/Bible/bible_event.dart';
import 'package:lw_app/Blocs/Bible/bible_state.dart';
import 'package:lw_app/Blocs/CompareTranslations/compare_translations_bloc.dart';
import 'package:lw_app/Blocs/CompareTranslations/compare_translations_event.dart';
import 'package:lw_app/Models/Bible/bible_models.dart';
import 'package:lw_app/Screens/Bible/verse_image_editor.dart';
import 'package:lw_app/Utils/bible_reference.dart';
import 'package:lw_app/Themes/custom_theme.dart';
import 'package:lw_app/Themes/lwp_tokens.dart';
import 'package:lw_app/Utils/share_helper.dart';
import 'package:lw_app/Utils/verse_image_formatter.dart';
import 'package:lw_app/Widgets/Bible/compare_translations_sheet.dart';
import 'package:lw_app/Widgets/LwpLoader/lwp_loader.dart';
import 'package:lw_app/Widgets/LwpError/lwp_error.dart';
import 'package:lw_app/Widgets/ProfileActionButton/profile_action_button.dart';
import 'package:lw_app/Widgets/LwpAnnouncement/lwp_announcement.dart';
import 'package:lw_app/Widgets/LwpSnackbar/lwp_snackbar.dart';
import 'package:lw_app/Widgets/LwpEmpty/lwp_empty.dart';
import 'package:lw_app/Widgets/LwpListEntrance/lwp_list_entrance.dart';
import 'package:lw_app/Widgets/Glass/lwp_glass.dart';
import 'package:lw_app/Widgets/Glass/lwp_glass_fab.dart';
import 'package:lw_app/Widgets/Glass/lwp_sheet.dart';
import 'package:lw_app/Widgets/Glass/lwp_shell_insets.dart';
import 'package:lw_app/Widgets/Glass/lwp_top_bar.dart';
import 'package:lw_app/Screens/Bible/saved_verses.dart';
import 'package:collection/collection.dart';

// ---------------------------------------------------------------------------
// Preset highlight colours. Keys are stored in Supabase as hex strings.
// ---------------------------------------------------------------------------
const List<MapEntry<String, Color>> _kPresetHighlightColors = [
  MapEntry('#FFF176', Color(0xFFFFF176)), // soft yellow
  MapEntry('#A5D6A7', Color(0xFFA5D6A7)), // soft green
  MapEntry('#90CAF9', Color(0xFF90CAF9)), // soft blue
  MapEntry('#F48FB1', Color(0xFFF48FB1)), // soft pink
  MapEntry('#FFCC80', Color(0xFFFFCC80)), // soft orange
  MapEntry('#CE93D8', Color(0xFFCE93D8)), // soft purple
  MapEntry('#80DEEA', Color(0xFF80DEEA)), // soft teal
  MapEntry('#EF9A9A', Color(0xFFEF9A9A)), // soft red
  MapEntry('#BCAAA4', Color(0xFFBCAAA4)), // soft brown
  MapEntry('#B0BEC5', Color(0xFFB0BEC5)), // soft grey-blue
];

// Converts a stored colour value (hex string like '#FFF176' or legacy name
// like 'yellow') into a display Color.
Color? highlightColorFromString(String? value, {bool dark = false}) {
  if (value == null) return null;
  // Hex format
  if (value.startsWith('#')) {
    try {
      final hex = value.replaceFirst('#', '');
      final fullHex = hex.length == 6 ? 'FF$hex' : hex;
      final base = Color(int.parse(fullHex, radix: 16));
      return base.withValues(alpha: dark ? 0.35 : 0.55);
    } catch (_) {
      return null;
    }
  }
  // Legacy named colours
  final alpha = dark ? 0.2 : 0.3;
  switch (value.toLowerCase()) {
    case 'yellow':
      return Colors.yellow.withValues(alpha: alpha);
    case 'green':
      return Colors.green.withValues(alpha: alpha);
    case 'blue':
      return Colors.blue.withValues(alpha: dark ? 0.15 : 0.2);
    case 'pink':
      return Colors.pink.withValues(alpha: dark ? 0.15 : 0.2);
    case 'orange':
      return Colors.orange.withValues(alpha: alpha);
    default:
      return null;
  }
}

class BiblePage extends StatefulWidget {
  const BiblePage({super.key});

  @override
  State<BiblePage> createState() => _BiblePageState();
}

class _BiblePageState extends State<BiblePage> {
  final GlobalKey _focusedVerseKey = GlobalKey();
  String? _lastHandledFocusVerse;

  void _openSavedVerses() {
    final bibleBloc = context.read<BibleBloc>();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SavedVersesPage()),
    ).then((_) {
      if (bibleBloc.state is BibleLoaded) {
        bibleBloc.add(LoadChapterInteractions());
      }
    });
  }

  void _showNavigation(BuildContext context, BibleLoaded state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const BibleNavigationSheet(),
    );
  }

  void _showNoteBottomSheet(BuildContext context, BibleLoaded state) {
    final textController = TextEditingController();

    if (state.selectedVerseNumbers.length == 1) {
      final selectedNum = state.selectedVerseNumbers.first;
      final verseObj = state.verses.firstWhereOrNull(
        (v) => v.verseNumber == selectedNum,
      );
      if (verseObj != null && verseObj.note != null) {
        textController.text = verseObj.note!;
      }
    }

    showLwpSheet<void>(
      context,
      title: context.l10n.bibleNoteTitle,
      builder: (modalContext) {
        final theme = Theme.of(context);
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.bibleNoteDescription(
                state.currentBook.name,
                state.currentChapter.number,
                state.selectedVerseNumbers.join(', '),
              ),
              style: TextStyle(color: theme.hintColor, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: textController,
              maxLines: 5,
              autofocus: true,
              decoration: InputDecoration(
                hintText: context.l10n.notesBodyPlaceholder,
                border: OutlineInputBorder(
                  borderRadius: LwpRadii.lgAll,
                  borderSide: BorderSide(
                    color: theme.primaryColor.withValues(alpha: 0.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: LwpRadii.lgAll,
                  borderSide: BorderSide(
                    color: theme.primaryColor,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(modalContext),
                  child: Text(
                    context.l10n.commonCancel,
                    style: TextStyle(color: theme.hintColor),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    context.read<BibleBloc>().add(
                      SaveNoteForSelected(textController.text),
                    );
                    Navigator.pop(modalContext);
                    LwpSnackbar.showSuccess(
                      context,
                      context.l10n.bibleNoteSaved,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: LwpRadii.lgAll,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    context.l10n.commonSave,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _shareSelectedVerses(
    BuildContext context,
    BibleLoaded state,
  ) async {
    final draft = buildVerseImageDraft(state);
    if (draft == null) return;

    final shareText =
        '"${draft.verseText}"\n\n- ${draft.citation}\n\n${context.l10n.bibleSharedViaApp}';

    await ShareHelper.shareText(
      context,
      text: shareText,
      subject: draft.citation,
      clipboardMessage: context.l10n.bibleVerseCopied,
    );

    if (context.mounted) context.read<BibleBloc>().add(ClearSelection());
  }

  void _openVerseImageEditor(BuildContext context, BibleLoaded state) {
    final draft = buildVerseImageDraft(state);
    if (draft == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => VerseImageEditorScreen(draft: draft)),
    );
  }

  void _showCompareTranslationsSheet(BuildContext context, BibleLoaded state) {
    final reference = buildPassageReference(
      state.currentBook,
      state.currentChapter,
      state.selectedVerseNumbers,
    );
    final citation = buildCitation(
      state.currentBook,
      state.currentChapter,
      state.selectedVerseNumbers,
    );

    final compareBloc = context.read<CompareTranslationsBloc>();
    compareBloc.add(
      LoadComparison(
        reference: reference,
        citation: citation,
        versions: state.versions,
      ),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => BlocProvider.value(
        value: compareBloc,
        child: CompareTranslationsSheet(
          book: state.currentBook,
          chapter: state.currentChapter,
        ),
      ),
    );
  }

  void _showColorPicker(BuildContext context) {
    const hues = [
      0.0,
      30.0,
      60.0,
      90.0,
      120.0,
      150.0,
      180.0,
      210.0,
      240.0,
      270.0,
      300.0,
      330.0,
    ];
    const lights = [0.82, 0.70, 0.58];

    showLwpSheet<void>(
      context,
      title: 'Kies Kleur',
      builder: (ctx) {
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final h in hues)
              for (final l in lights)
                Builder(
                  builder: (innerCtx) {
                    final color = HSLColor.fromAHSL(1.0, h, 0.75, l).toColor();
                    final argb = color.toARGB32();
                    final r = ((argb >> 16) & 0xFF)
                        .toRadixString(16)
                        .padLeft(2, '0')
                        .toUpperCase();
                    final g = ((argb >> 8) & 0xFF)
                        .toRadixString(16)
                        .padLeft(2, '0')
                        .toUpperCase();
                    final b = (argb & 0xFF)
                        .toRadixString(16)
                        .padLeft(2, '0')
                        .toUpperCase();
                    final hex = '#$r$g$b';
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(ctx);
                        innerCtx.read<BibleBloc>().add(
                          HighlightSelectedVerses(hex),
                        );
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<BibleBloc, BibleState>(
      listenWhen: (prev, cur) {
        if (cur is! BibleLoaded || cur.isLoading) return false;
        if (cur.focusVerseNumber == null) return false;
        if (prev is BibleLoaded &&
            prev.focusVerseNumber == cur.focusVerseNumber &&
            !prev.isLoading) {
          return false;
        }
        return true;
      },
      listener: (context, state) {
        if (state is! BibleLoaded) return;
        final focus = state.focusVerseNumber;
        if (focus == null || focus == _lastHandledFocusVerse) return;
        _lastHandledFocusVerse = focus;
        final bibleBloc = context.read<BibleBloc>();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final ctx = _focusedVerseKey.currentContext;
          if (ctx != null) {
            Scrollable.ensureVisible(
              ctx,
              alignment: 0.3,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
            );
          }
          Future.delayed(const Duration(milliseconds: 2500), () {
            if (mounted) {
              bibleBloc.add(ClearVerseFocus());
              _lastHandledFocusVerse = null;
            }
          });
        });
      },
      child: Scaffold(
        body: BlocBuilder<BibleBloc, BibleState>(
          builder: (context, state) {
            final topInset = _bibleChromeHeight(context, hasTranslation: state is BibleLoaded);

            if (state is BibleLoading) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: topInset),
                    child: Center(
                      child: LwpLoader(message: context.l10n.bibleLoading),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: _BibleGlassTopBar(
                      title: context.l10n.navBible,
                      onTitleTap: null,
                      onBookmarks: _openSavedVerses,
                    ),
                  ),
                ],
              );
            } else if (state is BibleError) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: topInset),
                    child: LwpError(
                      message: state.getLocalizedMessage(context),
                      onRetry: () =>
                          context.read<BibleBloc>().add(LoadBibleInitial()),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: _BibleGlassTopBar(
                      title: context.l10n.navBible,
                      onTitleTap: null,
                      onBookmarks: _openSavedVerses,
                    ),
                  ),
                ],
              );
            } else if (state is BibleLoaded) {
              final hasAnyBookmark = state.selectedVerseNumbers.any((verseNum) {
                final v = state.verses.firstWhereOrNull(
                  (verse) => verse.verseNumber == verseNum,
                );
                return v?.isBookmarked ?? false;
              });

              return Stack(
                children: [
                  Positioned.fill(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        16,
                        topInset + 8,
                        16,
                        LwpShellInsets.bottom(context) + 100,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (state.isLoading || state.isSavingInteraction)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 8),
                              child: LinearProgressIndicator(minHeight: 2),
                            ),
                          if (state.verses.isEmpty)
                            Padding(
                              padding: EdgeInsets.all(32.0),
                              child: LwpEmpty(
                                message: context.l10n.bibleChapterParseError,
                              ),
                            )
                          else
                            ...state.verses.map((verse) {
                              final isSelected = state.selectedVerseNumbers
                                  .contains(verse.verseNumber);
                              final isFocused =
                                  verse.verseNumber == state.focusVerseNumber;
                              return _VerseItem(
                                key: isFocused ? _focusedVerseKey : null,
                                verse: verse,
                                isSelected: isSelected,
                                isFocused: isFocused,
                                onTap: () {
                                  context.read<BibleBloc>().add(
                                    ToggleVerseSelection(verse.verseNumber),
                                  );
                                },
                                onLongPress: () {
                                  context.read<BibleBloc>().add(
                                    ToggleVerseSelection(verse.verseNumber),
                                  );
                                },
                              );
                            }),
                          const SizedBox(height: 24),
                          const Divider(),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Text(
                                    state.content.citation,
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    context.l10n.bibleProvidedByYouVersion,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: _BibleGlassTopBar(
                      title:
                          '${state.currentBook.name} ${state.currentChapter.number}',
                      onTitleTap: () => _showNavigation(context, state),
                      onBookmarks: _openSavedVerses,
                      translationLabel: state.currentVersion.displayName,
                      onChooseTranslation: () =>
                          _showNavigation(context, state),
                    ),
                  ),
                  // Floating Sequential Navigation Buttons (Only show when NO verses are selected)
                  if (state.selectedVerseNumbers.isEmpty)
                    Positioned(
                      bottom: LwpShellInsets.bottom(context) + 8,
                      left: 16,
                      right: 16,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _NavigationButton(
                            icon: Icons.arrow_back_ios_new,
                            onPressed: () => context.read<BibleBloc>().add(
                              NavigatePreviousChapter(),
                            ),
                            enabled: !state.isLoading,
                          ),
                          _NavigationButton(
                            icon: Icons.arrow_forward_ios,
                            onPressed: () => context.read<BibleBloc>().add(
                              NavigateNextChapter(),
                            ),
                            enabled: !state.isLoading,
                          ),
                        ],
                      ),
                    ),
                  // Floating Action Bar overlay (Show when one or more verses are selected)
                  if (state.selectedVerseNumbers.isNotEmpty)
                    Positioned(
                      bottom: LwpShellInsets.bottom(context) + 8,
                      left: 16,
                      right: 16,
                      child: LwpGlass(
                        radius: LwpRadii.lg,
                        thick: true,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Header row: selection count + close
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    context.l10n.bibleVersesSelected(
                                      state.selectedVerseNumbers.length,
                                    ),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () => context.read<BibleBloc>().add(
                                      ClearSelection(),
                                    ),
                                    child: Icon(
                                      Icons.close,
                                      size: 20,
                                      color: theme.hintColor,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 16),
                              // Row 1: Colour pickers (scrollable)
                              SizedBox(
                                height: 44,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      // 10 curated preset colours stored as hex
                                      ..._kPresetHighlightColors.map(
                                        (entry) => _ColorCircle(
                                          color: entry.value,
                                          onTap: () =>
                                              context.read<BibleBloc>().add(
                                                HighlightSelectedVerses(
                                                  entry.key,
                                                ),
                                              ),
                                        ),
                                      ),
                                      // Custom colour picker
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4.0,
                                        ),
                                        child: InkWell(
                                          customBorder: const CircleBorder(),
                                          onTap: () =>
                                              _showColorPicker(context),
                                          child: Container(
                                            width: 32,
                                            height: 32,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: const SweepGradient(
                                                colors: [
                                                  Colors.red,
                                                  Colors.yellow,
                                                  Colors.green,
                                                  Colors.cyan,
                                                  Colors.blue,
                                                  Colors.purple,
                                                  Colors.red,
                                                ],
                                              ),
                                              border: Border.all(
                                                color: Colors.white,
                                                width: 2,
                                              ),
                                            ),
                                            child: const Icon(
                                              Icons.add,
                                              size: 14,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Remove highlight
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4.0,
                                        ),
                                        child: InkWell(
                                          onTap: () =>
                                              context.read<BibleBloc>().add(
                                                const HighlightSelectedVerses(
                                                  null,
                                                ),
                                              ),
                                          customBorder: const CircleBorder(),
                                          child: Container(
                                            width: 32,
                                            height: 32,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: theme.hintColor
                                                    .withValues(alpha: 0.5),
                                              ),
                                            ),
                                            child: Icon(
                                              Icons.format_color_reset,
                                              size: 16,
                                              color: theme.hintColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Row 2: Actions
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    _ActionButton(
                                      icon: hasAnyBookmark
                                          ? Icons.bookmark
                                          : Icons.bookmark_border,
                                      label: context.l10n.commonSave,
                                      onTap: () {
                                        HapticFeedback.lightImpact();
                                        context.read<BibleBloc>().add(
                                          ToggleBookmarkSelected(),
                                        );
                                        LwpSnackbar.showSuccess(
                                          context,
                                          context.l10n.bibleBookmarkUpdated,
                                        );
                                      },
                                    ),
                                    _ActionButton(
                                      icon: Icons.note_alt_outlined,
                                      label: context.l10n.notesTitle,
                                      onTap: () =>
                                          _showNoteBottomSheet(context, state),
                                    ),
                                    _ActionButton(
                                      icon: Icons.image_outlined,
                                      label: context.l10n.bibleImageLabel,
                                      onTap: () =>
                                          _openVerseImageEditor(context, state),
                                    ),
                                    _ActionButton(
                                      icon: Icons.share_outlined,
                                      label: context.l10n.commonShare,
                                      onTap: () =>
                                          _shareSelectedVerses(context, state),
                                    ),
                                    _ActionButton(
                                      icon: Icons.compare_arrows,
                                      label: context.l10n.bibleCompareLabel,
                                      onTap: () =>
                                          _showCompareTranslationsSheet(
                                            context,
                                            state,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              );
            }
            return Center(child: Text(context.l10n.commonLoad));
          },
        ),
      ),
    );
  }
}

class _NavigationButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool enabled;

  const _NavigationButton({
    required this.icon,
    required this.onPressed,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return LwpGlassFab(
      onPressed: enabled ? onPressed : null,
      child: Icon(icon, size: 22),
    );
  }
}

double _bibleChromeHeight(BuildContext context, {required bool hasTranslation}) {
  final top = MediaQuery.paddingOf(context).top + LwpTopBar.gap;
  final row1 = LwpTopBar.capsuleHeight;
  if (!hasTranslation) return top + row1 + 6;
  return top + row1 + LwpTopBar.gap + 40 + 6;
}

class _BibleGlassTopBar extends StatelessWidget {
  const _BibleGlassTopBar({
    required this.title,
    required this.onTitleTap,
    required this.onBookmarks,
    this.translationLabel,
    this.onChooseTranslation,
  });

  final String title;
  final VoidCallback? onTitleTap;
  final VoidCallback onBookmarks;
  final String? translationLabel;
  final VoidCallback? onChooseTranslation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final ink = isDark ? Colors.white : LightColors.primary;

    return Material(
      type: MaterialType.transparency,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          LwpTopBar.side,
          MediaQuery.paddingOf(context).top + LwpTopBar.gap,
          LwpTopBar.side,
          0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                LwpGlass(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onTitleTap,
                    child: Container(
                      height: LwpTopBar.capsuleHeight,
                      padding: const EdgeInsets.only(left: 14, right: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.sizeOf(context).width * 0.42,
                            ),
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: ink,
                              ),
                            ),
                          ),
                          if (onTitleTap != null)
                            Icon(Icons.arrow_drop_down, color: ink),
                        ],
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                LwpGlass(
                  child: SizedBox(
                    height: LwpTopBar.capsuleHeight,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.bookmarks_outlined, color: ink),
                            tooltip: context.l10n.bibleSavedVersesTooltip,
                            onPressed: onBookmarks,
                          ),
                          LwpAnnouncementButton(color: ink),
                          ProfileActionButton(color: ink),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (translationLabel != null) ...[
              const SizedBox(height: LwpTopBar.gap),
              LwpGlass(
                child: SizedBox(
                  height: 40,
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            translationLabel!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: ink,
                            ),
                          ),
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: onChooseTranslation,
                          child: Text(
                            context.l10n.bibleChooseTranslation,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _VerseItem extends StatelessWidget {
  final BibleVerse verse;
  final bool isSelected;
  final bool isFocused;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _VerseItem({
    super.key,
    required this.verse,
    required this.isSelected,
    this.isFocused = false,
    required this.onTap,
    required this.onLongPress,
  });

  Color? _getHighlightColor(BuildContext context, String? colorName) {
    return highlightColorFromString(
      colorName,
      dark: Theme.of(context).brightness == Brightness.dark,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final highlight = _getHighlightColor(context, verse.highlightColor);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (verse.heading != null) ...[
          const SizedBox(height: 20),
          Text(
            verse.heading!,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
        ],
        InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(LwpRadii.xs),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            // Only add padding/decoration when selected or highlighted;
            // otherwise render flush with no margin so verses flow like a book.
            padding: (isSelected || highlight != null || isFocused)
                ? const EdgeInsets.symmetric(horizontal: 6, vertical: 2)
                : EdgeInsets.zero,
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.primaryColor.withValues(alpha: isDark ? 0.2 : 0.15)
                  : (highlight ??
                        (isFocused
                            ? theme.primaryColor.withValues(
                                alpha: isDark ? 0.18 : 0.12,
                              )
                            : null)),
              borderRadius: BorderRadius.circular(LwpRadii.xs),
              border: Border.all(
                color: isSelected ? theme.primaryColor : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Text.rich(
              TextSpan(
                children: [
                  // Superscript verse number
                  WidgetSpan(
                    alignment: PlaceholderAlignment.top,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 3, top: 1),
                          child: Text(
                            verse.verseNumber,
                            style: TextStyle(
                              fontSize: 10.0,
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                            ),
                          ),
                        ),
                        if (verse.isBookmarked)
                          Padding(
                            padding: const EdgeInsets.only(right: 2, top: 2),
                            child: Icon(
                              Icons.bookmark,
                              size: 9,
                              color: theme.primaryColor,
                            ),
                          ),
                        if (verse.note != null && verse.note!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(right: 3, top: 2),
                            child: Icon(
                              Icons.note_alt,
                              size: 9,
                              color: theme.primaryColor,
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Verse text — inline, no trailing newline
                  TextSpan(
                    text: verse.text,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: 17.0,
                      height: 1.7,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  // Single space separator between verses
                  const TextSpan(text: ' '),
                ],
              ),
              textAlign: TextAlign.justify,
            ),
          ),
        ),
      ],
    );
  }
}

class _ColorCircle extends StatelessWidget {
  final Color color;
  final VoidCallback onTap;

  const _ColorCircle({required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.6),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(LwpRadii.xs),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 22, color: theme.primaryColor),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(fontSize: 10, color: theme.hintColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BibleNavigationSheet extends StatefulWidget {
  const BibleNavigationSheet({super.key});

  @override
  State<BibleNavigationSheet> createState() => _BibleNavigationSheetState();
}

class _BibleNavigationSheetState extends State<BibleNavigationSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _versionSearchController =
      TextEditingController();
  final TextEditingController _bookSearchController = TextEditingController();
  final _listEntrance = LwpListEntranceController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _versionSearchController.dispose();
    _bookSearchController.dispose();
    _listEntrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      borderRadius: LwpRadii.lgTop,
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: BlocBuilder<BibleBloc, BibleState>(
          builder: (context, state) {
            if (state is! BibleLoaded) {
              return Center(
                child: LwpLoader(message: context.l10n.commonLoad),
              );
            }

            final filteredVersions = state.versions.where((v) {
              final query = _versionSearchController.text.toLowerCase();
              return v.name.toLowerCase().contains(query) ||
                  (v.abbreviation?.toLowerCase().contains(query) ?? false);
            }).toList();

            final filteredBooks = state.books.where((b) {
              return b.name.toLowerCase().contains(
                _bookSearchController.text.toLowerCase(),
              );
            }).toList();

            return LwpListEntranceScope(
              controller: _listEntrance,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: TabBar(
                      controller: _tabController,
                      labelColor: Theme.of(context).primaryColor,
                      unselectedLabelColor: Theme.of(context).hintColor,
                      indicatorColor: Theme.of(context).primaryColor,
                      tabs: [
                        Tab(text: context.l10n.bibleTranslationTab),
                        Tab(text: context.l10n.bibleBookTab),
                        Tab(text: context.l10n.bibleChapterTab),
                      ],
                    ),
                  ),
                  if (state.isLoading)
                    const LinearProgressIndicator(minHeight: 2),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: TextField(
                                controller: _versionSearchController,
                                decoration: InputDecoration(
                                  hintText:
                                      context.l10n.bibleSearchTranslationHint,
                                  prefixIcon: const Icon(Icons.search),
                                  border: OutlineInputBorder(
                                    borderRadius: LwpRadii.lgAll,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                ),
                                onChanged: (value) => setState(() {}),
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                itemCount: filteredVersions.length,
                                itemBuilder: (context, index) {
                                  final version = filteredVersions[index];
                                  return LwpListEntrance(
                                    id: 'version-${version.id}',
                                    child: ListTile(
                                      title: Text(version.displayName),
                                      trailing: version.id ==
                                              state.currentVersion.id
                                          ? const Icon(
                                              Icons.check,
                                              color: Colors.green,
                                            )
                                          : null,
                                      onTap: () {
                                        context.read<BibleBloc>().add(
                                          ChangeVersion(version),
                                        );
                                        Navigator.pop(context);
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: TextField(
                                controller: _bookSearchController,
                                decoration: InputDecoration(
                                  hintText: context.l10n.bibleSearchBookHint,
                                  prefixIcon: const Icon(Icons.search),
                                  border: OutlineInputBorder(
                                    borderRadius: LwpRadii.lgAll,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                ),
                                onChanged: (value) => setState(() {}),
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                itemCount: filteredBooks.length,
                                itemBuilder: (context, index) {
                                  final book = filteredBooks[index];
                                  return LwpListEntrance(
                                    id: 'book-${book.id}',
                                    child: ListTile(
                                      title: Text(book.name),
                                      trailing: book.id == state.currentBook.id
                                          ? const Icon(
                                              Icons.check,
                                              color: Colors.green,
                                            )
                                          : null,
                                      onTap: () {
                                        context.read<BibleBloc>().add(
                                          ChangeBook(book),
                                        );
                                        _tabController.animateTo(2);
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 5,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                          itemCount: state.chapters.length,
                          itemBuilder: (context, index) {
                            final chapter = state.chapters[index];
                            final isSelected =
                                chapter.id == state.currentChapter.id;
                            return LwpListEntrance(
                              id: 'chapter-${chapter.id}',
                              child: InkWell(
                                onTap: () {
                                  context.read<BibleBloc>().add(
                                    ChangeChapter(chapter),
                                  );
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Theme.of(context).primaryColor
                                        : Theme.of(context)
                                            .hintColor
                                            .withValues(alpha: 0.1),
                                    borderRadius: LwpRadii.smAll,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    chapter.number,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : null,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : null,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ],
              ),
            );
          },
        ),
      ),
    );
  }
}
