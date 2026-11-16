import 'package:flutter/material.dart';
import 'package:lw_app/Themes/custom_theme.dart';
import 'package:lw_app/Themes/lwp_tokens.dart';
import 'package:lw_app/Widgets/Glass/lwp_glass.dart';
import 'package:lw_app/Widgets/Glass/lwp_top_bar.dart';
import 'package:lw_app/Widgets/LwpAnnouncement/lwp_announcement.dart';
import 'package:lw_app/Widgets/ProfileActionButton/profile_action_button.dart';

/// Concept A: idle glass chrome morphs into a full-bleed glass search field.
class LwpGlassMorphSearchBar extends StatefulWidget {
  const LwpGlassMorphSearchBar({
    super.key,
    required this.title,
    required this.controller,
    required this.searchHint,
    this.showBack = false,
    this.onBack,
    this.showDefaultActions = true,
    this.actions,
    this.onChanged,
  });

  final String title;
  final TextEditingController controller;
  final String searchHint;
  final bool showBack;
  final VoidCallback? onBack;
  final bool showDefaultActions;
  final List<Widget>? actions;
  final ValueChanged<String>? onChanged;

  @override
  State<LwpGlassMorphSearchBar> createState() =>
      _LwpGlassMorphSearchBarState();
}

class _LwpGlassMorphSearchBarState extends State<LwpGlassMorphSearchBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _idleOpacity;
  late final Animation<double> _idleScale;
  late final Animation<double> _searchOpacity;
  late final Animation<double> _searchScaleX;
  late final Animation<double> _searchScaleY;
  final FocusNode _focusNode = FocusNode();
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
      reverseDuration: const Duration(milliseconds: 320),
    );
    final curved = CurvedAnimation(
      parent: _controller,
      curve: const Cubic(0.2, 0.8, 0.2, 1),
      reverseCurve: const Cubic(0.4, 0.0, 0.2, 1),
    );
    _idleOpacity = Tween<double>(begin: 1, end: 0).animate(curved);
    _idleScale = Tween<double>(begin: 1, end: 0.96).animate(curved);
    _searchOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.08, 1, curve: Cubic(0.2, 0.8, 0.2, 1)),
        reverseCurve: const Interval(0.0, 0.7, curve: Curves.easeIn),
      ),
    );
    _searchScaleX = Tween<double>(begin: 0.18, end: 1).animate(curved);
    _searchScaleY = Tween<double>(begin: 0.92, end: 1).animate(curved);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _focusNode.requestFocus();
      }
      if (status == AnimationStatus.dismissed) {
        _focusNode.unfocus();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _openSearch() async {
    if (_open) return;
    setState(() => _open = true);
    await _controller.forward();
  }

  Future<void> _closeSearch() async {
    if (!_open) return;
    widget.controller.clear();
    widget.onChanged?.call('');
    await _controller.reverse();
    if (mounted) setState(() => _open = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final ink = isDark ? Colors.white : LightColors.primary;
    final accent = theme.primaryColor;
    final hasRight =
        widget.showDefaultActions || (widget.actions?.isNotEmpty ?? false);

    return Material(
      type: MaterialType.transparency,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          LwpTopBar.side,
          MediaQuery.paddingOf(context).top + LwpTopBar.gap,
          LwpTopBar.side,
          0,
        ),
        child: SizedBox(
          height: LwpTopBar.capsuleHeight,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Stack(
                alignment: Alignment.centerRight,
                children: [
                  IgnorePointer(
                    ignoring: _open,
                    child: Opacity(
                      opacity: _idleOpacity.value.clamp(0.0, 1.0),
                      child: Transform.scale(
                        scale: _idleScale.value,
                        alignment: Alignment.center,
                        child: Row(
                          children: [
                            if (widget.showBack) ...[
                              LwpGlass(
                                child: SizedBox(
                                  width: LwpTopBar.capsuleHeight,
                                  height: LwpTopBar.capsuleHeight,
                                  child: IconButton(
                                    visualDensity: VisualDensity.compact,
                                    padding: EdgeInsets.zero,
                                    icon: Icon(
                                      Icons.arrow_back_ios_new,
                                      size: 18,
                                      color: ink,
                                    ),
                                    onPressed: widget.onBack ??
                                        () => Navigator.maybePop(context),
                                  ),
                                ),
                              ),
                              const SizedBox(width: LwpTopBar.islandGap),
                            ],
                            Flexible(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: LwpGlass(
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minHeight: LwpTopBar.capsuleHeight,
                                      maxWidth:
                                          MediaQuery.sizeOf(context).width *
                                              (hasRight || widget.showBack
                                                  ? 0.42
                                                  : 0.72),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (!widget.showBack) ...[
                                            Container(
                                              width: 10,
                                              height: 10,
                                              decoration: BoxDecoration(
                                                color: accent,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 9),
                                          ],
                                          ConstrainedBox(
                                            constraints: BoxConstraints(
                                              maxWidth: MediaQuery.sizeOf(
                                                        context,
                                                      ).width *
                                                      (hasRight ||
                                                              widget.showBack
                                                          ? 0.42
                                                          : 0.72) -
                                                  28 -
                                                  (widget.showBack ? 0 : 19),
                                            ),
                                            child: Text(
                                              widget.title,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              softWrap: false,
                                              style: theme
                                                  .textTheme.titleMedium
                                                  ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                color: ink,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: LwpTopBar.islandGap),
                            LwpGlass(
                              child: SizedBox(
                                width: LwpTopBar.capsuleHeight,
                                height: LwpTopBar.capsuleHeight,
                                child: IconButton(
                                  tooltip: widget.searchHint,
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                  icon: Icon(Icons.search, color: ink),
                                  onPressed: _openSearch,
                                ),
                              ),
                            ),
                            if (hasRight) ...[
                              const SizedBox(width: LwpTopBar.gap),
                              LwpGlass(
                                child: SizedBox(
                                  height: LwpTopBar.capsuleHeight,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 2,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (widget.actions != null)
                                          ...widget.actions!.map(
                                            (w) => IconTheme(
                                              data: IconThemeData(
                                                color: ink,
                                                size: 22,
                                              ),
                                              child: w,
                                            ),
                                          ),
                                        if (widget.showDefaultActions) ...[
                                          LwpAnnouncementButton(color: ink),
                                          ProfileActionButton(color: ink),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  IgnorePointer(
                    ignoring: !_open && _controller.isDismissed,
                    child: Opacity(
                      opacity: _searchOpacity.value.clamp(0.0, 1.0),
                      child: Transform(
                        alignment: Alignment.centerRight,
                        transform: Matrix4.diagonal3Values(
                          _searchScaleX.value,
                          _searchScaleY.value,
                          1,
                        ),
                        child: LwpGlass(
                          thick: true,
                          child: SizedBox(
                            height: LwpTopBar.capsuleHeight,
                            width: double.infinity,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 14,
                                right: 6,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.search_rounded,
                                    color: ink.withValues(alpha: 0.85),
                                    size: 22,
                                  ),
                                  const SizedBox(width: LwpSpacing.xs),
                                  Expanded(
                                    child: TextField(
                                      controller: widget.controller,
                                      focusNode: _focusNode,
                                      onChanged: widget.onChanged,
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                        color: ink,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      cursorColor: accent,
                                      textInputAction: TextInputAction.search,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        filled: false,
                                        fillColor: Colors.transparent,
                                        hintText: widget.searchHint,
                                        hintStyle: theme
                                            .textTheme.titleMedium
                                            ?.copyWith(
                                          color: ink.withValues(alpha: 0.45),
                                          fontWeight: FontWeight.w500,
                                        ),
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ),
                                  Material(
                                    color: ink.withValues(alpha: 0.10),
                                    shape: const CircleBorder(),
                                    child: InkWell(
                                      customBorder: const CircleBorder(),
                                      onTap: _closeSearch,
                                      child: SizedBox(
                                        width: 32,
                                        height: 32,
                                        child: Icon(
                                          Icons.close_rounded,
                                          size: 18,
                                          color: ink,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
