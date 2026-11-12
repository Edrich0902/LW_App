import 'package:flutter/material.dart';
import 'package:lw_app/Extensions/context_l10n.dart';
import 'package:lw_app/Models/Bible/bible_models.dart';
import 'package:lw_app/Models/Bible/votd_model.dart';
import 'package:lw_app/Themes/lwp_tokens.dart';

class DashboardVotdCard extends StatelessWidget {
  final Votd votd;
  final VoidCallback onTap;
  final VoidCallback onCreateImage;

  const DashboardVotdCard({
    super.key,
    required this.votd,
    required this.onTap,
    required this.onCreateImage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final verses = BibleParser.parseChapterHtml(
      rawHtml: votd.content.rawHtml,
      bookId: votd.book.id,
      chapterId: votd.chapter.id,
    );
    final quoteText = verses.map((v) => v.text.trim()).join(' ').trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: LwpSpacing.sm,
            vertical: LwpSpacing.xxs,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.12),
            borderRadius: LwpRadii.smAll,
          ),
          child: Text(
            context.l10n.dashboardVotdLabel,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
        ),
        const SizedBox(height: LwpSpacing.sm),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: LwpRadii.smAll,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.only(left: LwpSpacing.sm),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quoteText.isNotEmpty
                        ? quoteText
                        : votd.content.citation,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 17,
                      height: 1.55,
                      letterSpacing: -0.15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: LwpSpacing.sm),
                  Text(
                    '${votd.content.citation} · ${votd.version.shortLabel}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: LwpSpacing.sm),
        Wrap(
          spacing: LwpSpacing.xs,
          runSpacing: LwpSpacing.xs,
          children: [
            OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.hintColor,
                side: BorderSide(
                  color: theme.dividerColor.withValues(alpha: 0.6),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: LwpSpacing.sm,
                  vertical: LwpSpacing.xs,
                ),
                visualDensity: VisualDensity.compact,
                shape: const StadiumBorder(),
              ),
              child: Text(context.l10n.dashboardVotdReadInBible),
            ),
            OutlinedButton(
              onPressed: onCreateImage,
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.hintColor,
                side: BorderSide(
                  color: theme.dividerColor.withValues(alpha: 0.6),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: LwpSpacing.sm,
                  vertical: LwpSpacing.xs,
                ),
                visualDensity: VisualDensity.compact,
                shape: const StadiumBorder(),
              ),
              child: Text(context.l10n.dashboardVotdShareImage),
            ),
          ],
        ),
      ],
    );
  }
}
