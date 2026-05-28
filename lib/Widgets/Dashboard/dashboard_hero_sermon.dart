import 'package:flutter/material.dart';
import 'package:lw_app/Models/Sermon/sermon.dart';
import 'package:lw_app/Themes/lwp_tokens.dart';
import 'package:lw_app/Utils/date_formatter.dart';
import 'package:lw_app/Screens/Sermons/sermons.dart';

class DashboardHeroSermon extends StatelessWidget {
  final Sermon sermon;
  final VoidCallback onTap;

  const DashboardHeroSermon({
    super.key,
    required this.sermon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.cardTheme.color ?? theme.colorScheme.surface;
    final heroStartColor = isDark
        ? Color.lerp(cardColor, theme.primaryColor, 0.4)!
        : theme.primaryColor;
    final heroEndColor = isDark
        ? Color.lerp(cardColor, theme.primaryColor, 0.22)!
        : theme.primaryColor.withValues(alpha: 0.85);
    final accentColor = isDark ? theme.primaryColor : Colors.white;

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
            ? Border.all(color: theme.primaryColor.withValues(alpha: 0.35))
            : null,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? theme.primaryColor.withValues(alpha: 0.22)
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
                        "NUUTSTE PREEK",
                        style: TextStyle(
                          color: accentColor,
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
                              builder: (context) => const SermonsPage()),
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
                            "Kyk Alle",
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: isDark ? Colors.white70 : Colors.white70,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  sermon.title ?? "Geen Titel",
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: isDark ? Colors.white : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 14,
                      color: isDark ? Colors.white70 : Colors.white70,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      sermon.pastor ?? "Onbekend",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white70 : Colors.white70,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: isDark ? Colors.white70 : Colors.white70,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      sermon.createdAt != null && sermon.createdAt!.isNotEmpty
                          ? DateFormatter.formatDate(sermon.createdAt!)
                          : "",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white70 : Colors.white70,
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
