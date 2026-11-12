import 'package:flutter/material.dart';
import 'package:lw_app/Extensions/app_localizations_x.dart';
import 'package:lw_app/Extensions/context_l10n.dart';
import 'package:lw_app/Models/PrayerRequest/prayer_request.dart';
import 'package:lw_app/Themes/lwp_tokens.dart';
import 'package:lw_app/Utils/date_formatter.dart';

/// Minimal prayer row: body → meta line → optional praise/note → pray / ⋯
class PrayerRequestCard extends StatelessWidget {
  const PrayerRequestCard({
    super.key,
    required this.request,
    this.onPrayTap,
    this.onResolveTap,
    this.showStatus = false,
  });

  final PrayerRequest request;
  final VoidCallback? onPrayTap;
  final VoidCallback? onResolveTap;
  final bool showStatus;

  bool get _hasPraise =>
      request.status == PrayerRequestStatus.resolved &&
      (request.praiseReport ?? '').trim().isNotEmpty;

  bool get _hasModerationNote =>
      (request.moderationNote ?? '').trim().isNotEmpty;

  bool get _isResolved => request.status == PrayerRequestStatus.resolved;

  /// Status only when it adds signal (pending / rejected on My requests).
  bool get _showStatusInMeta =>
      showStatus &&
      (request.status == PrayerRequestStatus.pending ||
          request.status == PrayerRequestStatus.rejected);

  Color _statusColor(BuildContext context) {
    switch (request.status) {
      case PrayerRequestStatus.pending:
        return Colors.orange.shade700;
      case PrayerRequestStatus.rejected:
        return Colors.redAccent;
      case PrayerRequestStatus.approved:
        return Colors.green.shade700;
      case PrayerRequestStatus.resolved:
        return Theme.of(context).primaryColor;
    }
  }

  String _metaLine(BuildContext context) {
    // Backend views hardcode Afrikaans "Anoniem" in display_name — always
    // localize anonymous labels from the active locale.
    final name = request.isAnonymous
        ? context.l10n.prayerAnonymousName
        : (request.displayName ?? context.l10n.prayerAnonymousName);
    final parts = <String>[
      name,
      request.category.label(context.l10n),
      if (request.createdAt != null)
        DateFormatter.formatDate(request.createdAt!),
    ];
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasMenu = onResolveTap != null && !_isResolved;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        LwpSpacing.md,
        LwpSpacing.md,
        hasMenu ? LwpSpacing.xs : LwpSpacing.md,
        LwpSpacing.md,
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(right: hasMenu ? 28 : 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.body,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.5,
                    letterSpacing: -0.15,
                  ),
                ),
                const SizedBox(height: LwpSpacing.xs),
                Text.rich(
                  TextSpan(
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                      height: 1.4,
                    ),
                    children: [
                      TextSpan(text: _metaLine(context)),
                      if (_showStatusInMeta) ...[
                        const TextSpan(text: ' · '),
                        TextSpan(
                          text: request.status.label(context.l10n),
                          style: TextStyle(
                            color: _statusColor(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (_hasModerationNote) ...[
                  const SizedBox(height: LwpSpacing.sm),
                  _ReplyBlock(
                    label: context.l10n.prayerNoteShortLabel,
                    body: request.moderationNote!.trim(),
                    labelColor: Colors.orange.shade700,
                  ),
                ],
                if (_hasPraise) ...[
                  const SizedBox(height: LwpSpacing.sm),
                  _ReplyBlock(
                    label: context.l10n.prayerPraiseShortLabel,
                    body: request.praiseReport!.trim(),
                    labelColor: theme.primaryColor,
                  ),
                ],
                if (_showPrayRow) ...[
                  const SizedBox(height: LwpSpacing.xs),
                  if (onPrayTap != null && !_isResolved)
                    _PrayControl(
                      count: request.reactionCount,
                      pressed: request.hasReacted,
                      onTap: onPrayTap!,
                    )
                  else if (_isResolved && request.reactionCount > 0)
                    _PrayControl(
                      count: request.reactionCount,
                      pressed: true,
                      onTap: null,
                    ),
                ],
              ],
            ),
          ),
          if (hasMenu)
            Positioned(
              top: -4,
              right: 0,
              child: PopupMenuButton<String>(
                tooltip: context.l10n.prayerResolveAction,
                onSelected: (value) {
                  if (value == 'resolve') onResolveTap?.call();
                },
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    value: 'resolve',
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline, size: 20),
                        const SizedBox(width: LwpSpacing.sm),
                        Text(context.l10n.prayerResolveAction),
                      ],
                    ),
                  ),
                ],
                icon: Icon(
                  Icons.more_vert,
                  color: theme.hintColor,
                ),
              ),
            ),
        ],
      ),
    );
  }

  bool get _showPrayRow =>
      (onPrayTap != null && !_isResolved) ||
      (_isResolved && request.reactionCount > 0);
}

class _ReplyBlock extends StatelessWidget {
  const _ReplyBlock({
    required this.label,
    required this.body,
    required this.labelColor,
  });

  final String label;
  final String body;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: labelColor,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          body,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.hintColor,
            height: 1.5,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _PrayControl extends StatelessWidget {
  const _PrayControl({
    required this.count,
    required this.pressed,
    required this.onTap,
  });

  final int count;
  final bool pressed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final active = pressed;
    final color = active ? theme.primaryColor : theme.hintColor;

    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          active
              ? Icons.volunteer_activism
              : Icons.volunteer_activism_outlined,
          size: 18,
          color: color,
        ),
        if (count > 0) ...[
          const SizedBox(width: 6),
          Text(
            '$count',
            style: theme.textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ],
    );

    if (onTap == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: child,
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(LwpRadii.xs),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          child: child,
        ),
      ),
    );
  }
}
