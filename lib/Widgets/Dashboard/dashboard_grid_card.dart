import 'package:flutter/material.dart';
import 'package:lw_app/Themes/lwp_tokens.dart';

class DashboardGridCard extends StatelessWidget {
  final String title;
  final Widget icon;
  final VoidCallback onTap;

  const DashboardGridCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolvedIcon = IconTheme.merge(
      data: IconThemeData(size: 18, color: theme.colorScheme.primary),
      child: icon,
    );

    return Material(
      color: theme.cardTheme.color ?? theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: LwpRadii.mdAll,
        side: BorderSide(
          color: theme.dividerColor.withValues(alpha: 0.55),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: LwpSpacing.sm,
            vertical: LwpSpacing.sm,
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(LwpRadii.xs),
                ),
                alignment: Alignment.center,
                child: resolvedIcon,
              ),
              const SizedBox(width: LwpSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
