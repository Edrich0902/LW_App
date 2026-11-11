import 'package:flutter/material.dart';
import 'package:lw_app/Themes/custom_theme.dart';
import 'package:lw_app/Widgets/Glass/lwp_glass.dart';
import 'package:lw_app/Widgets/LwpAnnouncement/lwp_announcement.dart';
import 'package:lw_app/Widgets/ProfileActionButton/profile_action_button.dart';

/// Floating glass islands over the page (Nexus TopBar pattern):
/// optional back pill, title capsule, actions cluster on the right.
class LwpTopBar extends StatelessWidget {
  const LwpTopBar({
    super.key,
    required this.title,
    this.showActions = true,
    this.showBack = false,
    this.onBack,
    this.actions,
    this.titleWidget,
  });

  final String title;

  /// Announcement + profile cluster (root-tab style).
  final bool showActions;

  /// Back chevron in its own floating pill (pushed routes).
  final bool showBack;
  final VoidCallback? onBack;

  /// Extra actions inside the right glass capsule (before default actions).
  final List<Widget>? actions;

  /// Optional custom title content (overrides [title] text).
  final Widget? titleWidget;

  static const double capsuleHeight = 44;
  static const double gap = 4;
  static const double side = 14;
  static const double islandGap = 8;

  static double heightOf(BuildContext context) =>
      MediaQuery.paddingOf(context).top + gap + capsuleHeight + 6;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final ink = isDark ? Colors.white : LightColors.primary;
    final accent = theme.primaryColor;
    final hasRight = showActions || (actions != null && actions!.isNotEmpty);

    return Material(
      type: MaterialType.transparency,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          side,
          MediaQuery.paddingOf(context).top + gap,
          side,
          0,
        ),
        child: Row(
          children: [
            if (showBack) ...[
              LwpGlass(
                child: SizedBox(
                  width: capsuleHeight,
                  height: capsuleHeight,
                  child: IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    icon: Icon(Icons.arrow_back_ios_new, size: 18, color: ink),
                    onPressed: onBack ?? () => Navigator.maybePop(context),
                  ),
                ),
              ),
              const SizedBox(width: islandGap),
            ],
            Flexible(
              child: Align(
                alignment: Alignment.centerLeft,
                child: LwpGlass(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: capsuleHeight,
                      maxWidth: MediaQuery.sizeOf(context).width *
                          (hasRight || showBack ? 0.58 : 0.92),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!showBack) ...[
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
                          // Avoid Flexible inside mainAxisSize.min — it
                          // collapses to 0 width and leaves an empty pill.
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.sizeOf(context).width *
                                      (hasRight || showBack ? 0.58 : 0.92) -
                                  28 -
                                  (showBack ? 0 : 19),
                            ),
                            child: titleWidget ??
                                Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: false,
                                  style: theme.textTheme.titleMedium?.copyWith(
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
            if (hasRight) ...[
              const SizedBox(width: gap),
              LwpGlass(
                child: SizedBox(
                  height: capsuleHeight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (actions != null)
                          ...actions!.map(
                            (w) => IconTheme(
                              data: IconThemeData(color: ink, size: 22),
                              child: w,
                            ),
                          ),
                        if (showActions) ...[
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
    );
  }
}
