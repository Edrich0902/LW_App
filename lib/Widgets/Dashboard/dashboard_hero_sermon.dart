import 'package:flutter/material.dart';
import 'package:lw_app/Extensions/context_l10n.dart';
import 'package:lw_app/Models/Sermon/sermon.dart';
import 'package:lw_app/Themes/lwp_tokens.dart';
import 'package:lw_app/Utils/date_formatter.dart';

class DashboardHeroSermon extends StatelessWidget {
  final Sermon sermon;
  final String? thumbnailUrl;
  final VoidCallback onTap;

  const DashboardHeroSermon({
    super.key,
    required this.sermon,
    required this.onTap,
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
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.22),
                        Colors.black.withValues(alpha: 0.88),
                      ],
                      stops: const [0.2, 0.55, 1.0],
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
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: LwpSpacing.sm,
                          vertical: LwpSpacing.xxs,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          borderRadius: LwpRadii.smAll,
                        ),
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
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (metaParts.isNotEmpty) ...[
                        const SizedBox(height: LwpSpacing.xxs),
                        Text(
                          metaParts.join(' · '),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.75),
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
