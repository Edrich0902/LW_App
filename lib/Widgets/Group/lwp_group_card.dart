import 'package:cloudinary_flutter/image/cld_image.dart';
import 'package:flutter/material.dart';
import 'package:lw_app/Models/Group/group.dart';
import 'package:lw_app/Screens/GroupDetail/group_detail.dart';
import 'package:lw_app/Themes/custom_theme.dart';
import 'package:lw_app/Themes/lwp_tokens.dart';

class LwpGroupCard extends StatelessWidget {
  final Group group;
  final VoidCallback? onTap;

  const LwpGroupCard({
    super.key,
    required this.group,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      margin: const EdgeInsets.only(bottom: LwpSpacing.sm),
      child: InkWell(
        onTap: onTap ?? () => _openGroupDetail(context),
        child: Padding(
          padding: const EdgeInsets.all(LwpSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: LwpRadii.smAll,
                child: CldImageWidget(
                  publicId: group.bannerPublicId ?? 'samples/cloudinary-icon',
                  fit: BoxFit.cover,
                  width: 88,
                  height: 88,
                ),
              ),
              const SizedBox(width: LwpSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            group.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: LwpSpacing.xs),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: theme.hintColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: LwpSpacing.xs),
                    Text(
                      group.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.hintColor,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: LwpSpacing.sm),
                    Wrap(
                      spacing: LwpSpacing.xs,
                      runSpacing: LwpSpacing.xs,
                      children: [
                        _chip(
                          context,
                          label: '${group.leaderCount} leiers',
                        ),
                        _chip(
                          context,
                          label: '${group.memberCount} lede',
                        ),
                        if (group.pendingCount > 0)
                          _chip(
                            context,
                            label: '${group.pendingCount} hangend',
                            color: Colors.orange.shade700,
                          ),
                        if (group.membershipStatus != null &&
                            group.membershipStatus != 'removed')
                          _chip(
                            context,
                            label: _membershipLabel(group.membershipStatus!),
                            color: _membershipColor(group.membershipStatus!),
                          ),
                        if (group.isLeader)
                          _chip(
                            context,
                            label: 'Leier',
                            color: Colors.amber.shade800,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(
    BuildContext context, {
    required String label,
    Color? color,
  }) {
    final chipColor = color ?? Theme.of(context).primaryColor;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: LwpSpacing.sm,
        vertical: LwpSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(LwpRadii.pill),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: chipColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  void _openGroupDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GroupDetailPage(groupId: group.id ?? ''),
      ),
    );
  }

  String _membershipLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Versoek Hangend';
      case 'active':
        return 'Lid';
      case 'declined':
        return 'Afgekeur';
      case 'left':
        return 'Verlaat';
      default:
        return status;
    }
  }

  Color _membershipColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange.shade700;
      case 'active':
        return Colors.green.shade700;
      case 'declined':
        return Colors.red.shade700;
      case 'left':
        return LightColors.muted;
      default:
        return LightColors.muted;
    }
  }
}
