import 'package:flutter/material.dart';
import 'package:lw_app/Extensions/context_l10n.dart';
import 'package:lw_app/Models/PastoralBlog/pastoral_post.dart';
import 'package:lw_app/Themes/lwp_tokens.dart';
import 'package:lw_app/Utils/date_formatter.dart';
import 'package:lw_app/Screens/PastoralBlog/pastoral_blog.dart';

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
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.cardTheme.color ?? theme.colorScheme.surface;
    
    // Emerald / Teal themed gradients to contrast with the Blue Sermon card
    final heroStartColor = isDark
        ? Color.lerp(cardColor, const Color(0xFF10B981), 0.25)!
        : Colors.teal;
    final heroEndColor = isDark
        ? Color.lerp(cardColor, Colors.teal, 0.15)!
        : Colors.teal.withValues(alpha: 0.85);
    final accentColor = isDark ? const Color(0xFF10B981) : Colors.white;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: LwpRadii.lgAll,
        gradient: LinearGradient(
          colors: [heroStartColor, heroEndColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: isDark
            ? Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3))
            : null,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? const Color(0xFF10B981).withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.1),
            blurRadius: isDark ? 16 : 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: LwpRadii.lgAll,
          child: Padding(
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
                        color: accentColor.withValues(alpha: 0.2),
                        borderRadius: LwpRadii.smAll,
                      ),
                      child: Text(
                        context.l10n.dashboardLatestBlogLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const PastoralBlogPage()),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Row(
                        children: [
                          Text(
                            context.l10n.dashboardReadAllButton,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: Colors.white70,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  post.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline,
                      size: 14,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      post.displayAuthorName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      post.createdAt != null && post.createdAt!.isNotEmpty
                          ? DateFormatter.formatDate(post.createdAt!)
                          : "",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
