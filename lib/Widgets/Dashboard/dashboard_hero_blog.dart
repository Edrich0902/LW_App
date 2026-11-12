import 'package:cloudinary_flutter/image/cld_image.dart';
import 'package:flutter/material.dart';
import 'package:lw_app/Extensions/context_l10n.dart';
import 'package:lw_app/Models/PastoralBlog/pastoral_post.dart';
import 'package:lw_app/Themes/lwp_tokens.dart';
import 'package:lw_app/Utils/date_formatter.dart';

class DashboardHeroBlog extends StatelessWidget {
  final PastoralPost post;
  final VoidCallback onTap;

  const DashboardHeroBlog({
    super.key,
    required this.post,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateLabel = post.createdAt != null && post.createdAt!.isNotEmpty
        ? DateFormatter.formatDate(post.createdAt!)
        : '';
    final metaParts = <String>[
      post.displayAuthorName,
      if (dateLabel.isNotEmpty) dateLabel,
    ];
    final hasCover = (post.coverImagePublicId ?? '').isNotEmpty ||
        (post.coverImageUrl ?? '').isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: LwpRadii.smAll,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: LwpSpacing.xs),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: LwpRadii.smAll,
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: hasCover
                      ? (post.coverImagePublicId?.isNotEmpty == true
                          ? CldImageWidget(
                              publicId: post.coverImagePublicId!,
                              width: 72,
                              height: 72,
                              fit: BoxFit.cover,
                            )
                          : Image.network(
                              post.coverImageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => ColoredBox(
                                color: theme.colorScheme.primary
                                    .withValues(alpha: 0.18),
                              ),
                            ))
                      : ColoredBox(
                          color:
                              theme.colorScheme.primary.withValues(alpha: 0.18),
                          child: Icon(
                            Icons.article_outlined,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: LwpSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.dashboardLatestBlogLabel,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: const Color(0xFF10B981),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: LwpSpacing.xxs),
                    Text(
                      post.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                        height: 1.25,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (metaParts.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        metaParts.join(' · '),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.hintColor,
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
    );
  }
}
