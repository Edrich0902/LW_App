import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:lw_app/Extensions/context_l10n.dart';
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

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: LwpRadii.lgAll,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (votd.imageUrl != null)
              ClipRRect(
                borderRadius: LwpRadii.lgTop,
                child: Image.network(
                  votd.imageUrl!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.shrink(),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: LwpRadii.smAll,
                        ),
                        child: Text(
                          context.l10n.dashboardVotdLabel,
                          style: TextStyle(
                            color: theme.primaryColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: onCreateImage,
                        child: Icon(Icons.image_outlined,
                            size: 18, color: theme.hintColor),
                      ),
                      const SizedBox(width: 10),
                      Icon(Icons.menu_book, size: 16, color: theme.hintColor),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Html(
                    data: votd.content.html,
                    style: {
                      "body": Style(
                        fontSize: FontSize(18.0),
                        lineHeight: LineHeight.em(1.5),
                        margin: Margins.zero,
                        padding: HtmlPaddings.zero,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                      ".yv-vlbl, .v, sup": Style(
                        fontSize: FontSize(11.0),
                        fontWeight: FontWeight.bold,
                        verticalAlign: VerticalAlign.sup,
                        color: theme.primaryColor.withValues(alpha: 0.8),
                        padding: HtmlPaddings.only(right: 4),
                      ),
                    },
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: LwpSpacing.sm,
                    runSpacing: LwpSpacing.xs,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        votd.content.citation,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 260),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: LwpSpacing.sm,
                            vertical: LwpSpacing.xxs,
                          ),
                          decoration: ShapeDecoration(
                            color: theme.primaryColor.withValues(alpha: 0.1),
                            shape: const StadiumBorder(),
                          ),
                          child: Text(
                            votd.version.shortLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
