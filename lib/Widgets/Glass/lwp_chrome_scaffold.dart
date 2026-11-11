import 'package:flutter/material.dart';
import 'package:lw_app/Widgets/Glass/lwp_shell_insets.dart';
import 'package:lw_app/Widgets/Glass/lwp_top_bar.dart';

/// Scaffold with floating glass top chrome instead of a solid [AppBar].
///
/// Body is padded under the capsules; use [SafeArea] with `top: false` if
/// you still need left/right/bottom insets.
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

  @override
  Widget build(BuildContext context) {
    final canPop = ModalRoute.of(context)?.canPop ?? false;
    final back = showBack ?? canPop;

    return Scaffold(
      extendBody: extendBody,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      backgroundColor: backgroundColor,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(top: LwpShellInsets.top(context)),
              child: body,
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LwpTopBar(
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
