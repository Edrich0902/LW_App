import 'package:cloudinary_flutter/image/cld_image.dart';
import 'package:flutter/material.dart';
import 'package:lw_app/Extensions/context_l10n.dart';
import 'package:lw_app/Models/Group/group.dart';
import 'package:lw_app/Screens/GroupDetail/group_detail.dart';
import 'package:lw_app/Themes/lwp_tokens.dart';

/// Quiet Horizon group row: square thumb, one-line copy, soft status badges.
class LwpGroupCard extends StatelessWidget {
  final Group group;
  final VoidCallback? onTap;

  const LwpGroupCard({
    super.key,
    required this.group,
    this.onTap,
  });

  static const double _thumbSize = 84.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final description = group.description.trim();
    final badges = _statusBadges(context);

    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      margin: const EdgeInsets.only(bottom: LwpSpacing.sm),
      shape: const RoundedRectangleBorder(borderRadius: LwpRadii.lgAll),
      child: InkWell(
        onTap: onTap ?? () => _openGroupDetail(context),
        child: Padding(
          padding: const EdgeInsets.all(LwpSpacing.sm - 2),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: LwpRadii.smAll,
                child: CldImageWidget(
                  publicId: group.bannerPublicId ?? 'samples/cloudinary-icon',
                  fit: BoxFit.cover,
                  width: _thumbSize,
                  height: _thumbSize,
                ),
              ),
              const SizedBox(width: LwpSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      group.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                        height: 1.25,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: LwpSpacing.xxs),
                      Text(
                        description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.hintColor,
                          height: 1.35,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: LwpSpacing.xs),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: LwpSpacing.xs,
                      runSpacing: LwpSpacing.xxs,
                      children: [
                        Text(
                          context.l10n.groupMembersCount(group.memberCount),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.hintColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '·',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.hintColor.withValues(alpha: 0.45),
                          ),
                        ),
                        Text(
                          context.l10n.groupLeadersCount(group.leaderCount),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.hintColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        ...badges,
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

  List<Widget> _statusBadges(BuildContext context) {
    final badges = <Widget>[];

    final status = group.membershipStatus;
    if (status != null && status != 'removed') {
      badges.add(
        _badge(
          label: _membershipLabel(context, status),
          color: _membershipColor(status),
        ),
      );
    }

    if (group.isLeader) {
      badges.add(
        _badge(
          label: context.l10n.groupLeaderBadge,
          color: const Color(0xFFE6C35C),
        ),
      );
    }

    if (group.pendingCount > 0) {
      badges.add(
        _badge(
          label: context.l10n.groupPendingCount(group.pendingCount),
          color: const Color(0xFFE0A45A),
        ),
      );
    }

    return badges;
  }

  Widget _badge({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: LwpSpacing.xs,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(LwpRadii.pill),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 10,
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

  String _membershipLabel(BuildContext context, String status) {
    switch (status) {
      case 'pending':
        return context.l10n.groupMembershipStatusPending;
      case 'active':
        return context.l10n.groupMembershipStatusActive;
      case 'declined':
        return context.l10n.groupMembershipStatusDeclined;
      case 'left':
        return context.l10n.groupMembershipStatusLeft;
      default:
        return status;
    }
  }

  Color _membershipColor(String status) {
    switch (status) {
      case 'pending':
        return const Color(0xFFE0A45A);
      case 'active':
        return const Color(0xFF7DCEB0);
      case 'declined':
        return Colors.red.shade400;
      case 'left':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
