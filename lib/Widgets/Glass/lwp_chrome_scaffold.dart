import 'package:flutter/material.dart';
import 'package:lw_app/Widgets/Glass/lwp_glass_morph_search_bar.dart';
import 'package:lw_app/Widgets/Glass/lwp_top_bar.dart';

/// Scaffold with floating glass top chrome instead of a solid [AppBar].
///
/// Body is full-bleed under the capsules so content can scroll beneath glass
/// (same as Home). Pad scrollables with [LwpShellInsets.scrollOf] / [bodyOf].
class LwpChromeScaffold extends StatelessWidget {
  const LwpChromeScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.showDefaultActions = false,
    this.showBack,
    this.onBack,
    this.titleWidget,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.extendBody = true,
    this.resizeToAvoidBottomInset = true,
    this.backgroundColor,
    this.searchController,
    this.searchHint,
    this.onSearchChanged,
  });

  final String title;
  final Widget body;
  final List<Widget>? actions;

  /// Show announcement + profile in the right capsule.
  final bool showDefaultActions;

  /// Defaults to [Navigator.canPop].
  final bool? showBack;
  final VoidCallback? onBack;
  final Widget? titleWidget;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool extendBody;
  final bool resizeToAvoidBottomInset;
  final Color? backgroundColor;

  /// When set, the top chrome uses Concept A glass morph search.
  final TextEditingController? searchController;
  final String? searchHint;
  final ValueChanged<String>? onSearchChanged;

  @override
  Widget build(BuildContext context) {
    final canPop = ModalRoute.of(context)?.canPop ?? false;
    final back = showBack ?? canPop;
    final useMorphSearch = searchController != null;

    return Scaffold(
      extendBody: extendBody,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      backgroundColor: backgroundColor,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Full-bleed body so scrollables can pass under glass chrome
          // (same pattern as Home). Screens should pad with [LwpShellInsets].
          Positioned.fill(child: body),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: useMorphSearch
                ? LwpGlassMorphSearchBar(
                    title: title,
                    controller: searchController!,
                    searchHint: searchHint ?? '',
                    showBack: back,
                    onBack: onBack,
                    showDefaultActions: showDefaultActions,
                    actions: actions,
                    onChanged: onSearchChanged,
                  )
                : LwpTopBar(
                    title: title,
                    showBack: back,
                    onBack: onBack,
                    showActions: showDefaultActions,
                    actions: actions,
                    titleWidget: titleWidget,
                  ),
          ),
        ],
      ),
    );
  }
}
