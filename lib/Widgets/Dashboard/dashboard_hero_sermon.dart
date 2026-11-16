import 'package:flutter/material.dart';
import 'package:lw_app/Extensions/context_l10n.dart';
import 'package:lw_app/Models/Sermon/sermon.dart';
import 'package:lw_app/Themes/lwp_tokens.dart';
import 'package:lw_app/Utils/date_formatter.dart';

class DashboardHeroSermon extends StatelessWidget {
  final Sermon sermon;
  final String? thumbnailUrl;
  final VoidCallback onTap;
  final VoidCallback onViewAll;

  const DashboardHeroSermon({
    super.key,
    required this.sermon,
    required this.onTap,
    required this.onViewAll,
    this.thumbnailUrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateLabel = sermon.createdAt != null && sermon.createdAt!.isNotEmpty
        ? DateFormatter.formatDate(sermon.createdAt!)
        : '';
    final metaParts = <String>[
      if ((sermon.pastor ?? '').trim().isNotEmpty) sermon.pastor!.trim(),
      if (dateLabel.isNotEmpty) dateLabel,
    ];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: LwpRadii.lgAll,
        child: ClipRRect(
          borderRadius: LwpRadii.lgAll,
          child: SizedBox(
            height: 188,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if ((thumbnailUrl ?? '').isNotEmpty)
                  Image.network(
                    thumbnailUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => ColoredBox(
                      color: theme.colorScheme.primary.withValues(alpha: 0.28),
                    ),
                  )
                else
                  ColoredBox(
                    color: theme.colorScheme.primary.withValues(alpha: 0.35),
                  ),
                // Always-on cover scrim so white type stays readable on any artwork.
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x66000000),
                        Color(0x33000000),
                        Color(0xCC000000),
                        Color(0xE6000000),
                      ],
                      stops: [0.0, 0.35, 0.72, 1.0],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    LwpSpacing.md,
                    LwpSpacing.md,
                    LwpSpacing.md,
                    LwpSpacing.sm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: _CoverChip(
                          onTap: onViewAll,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                context.l10n.dashboardWatchAllButton,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              const SizedBox(width: 2),
                              const Icon(
                                Icons.chevron_right,
                                size: 16,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      _CoverChip(
                        child: Text(
                          context.l10n.dashboardLatestSermonLabel,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                      const SizedBox(height: LwpSpacing.xs),
                      Text(
                        sermon.title ?? context.l10n.dashboardUntitledSermon,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                          height: 1.2,
                          shadows: const [
                            Shadow(
                              color: Color(0x99000000),
                              blurRadius: 10,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (metaParts.isNotEmpty) ...[
                        const SizedBox(height: LwpSpacing.xxs),
                        Text(
                          metaParts.join(' · '),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.92),
                            fontWeight: FontWeight.w500,
                            shadows: const [
                              Shadow(
                                color: Color(0x99000000),
                                blurRadius: 8,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Dark frosted chip so labels stay readable on bright and dark cover art.
class _CoverChip extends StatelessWidget {
  const _CoverChip({
    required this.child,
    this.onTap,
  });

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final chip = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: LwpSpacing.sm,
        vertical: LwpSpacing.xxs + 1,
      ),
      decoration: BoxDecoration(
        color: const Color(0xB3000000),
        borderRadius: BorderRadius.circular(LwpRadii.pill),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
        ),
      ),
      child: child,
    );

    if (onTap == null) return chip;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(LwpRadii.pill),
        child: chip,
      ),
    );
  }
}
