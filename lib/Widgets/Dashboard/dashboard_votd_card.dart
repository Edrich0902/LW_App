import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:lw_app/Models/Bible/votd_model.dart';

class DashboardVotdCard extends StatelessWidget {
  final Votd votd;
  final VoidCallback onTap;

  const DashboardVotdCard({
    super.key,
    required this.votd,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (votd.imageUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
                child: Image.network(
                  votd.imageUrl!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
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
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "VERS VAN DIE DAG",
                          style: TextStyle(
                            color: theme.primaryColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.menu_book, size: 16, color: Colors.grey),
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
                  Text(
                    votd.content.citation,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
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
