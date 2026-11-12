import 'dart:io';

import 'package:cloudinary_flutter/image/cld_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lw_app/Blocs/GroupDetail/group_detail_bloc.dart';
import 'package:lw_app/Extensions/app_localizations_x.dart';
import 'package:lw_app/Extensions/context_l10n.dart';
import 'package:lw_app/Models/Group/group.dart';
import 'package:lw_app/Models/Group/group_membership.dart';
import 'package:lw_app/Screens/GroupFeed/group_feed.dart';
import 'package:lw_app/Themes/custom_theme.dart';
import 'package:lw_app/Themes/lwp_icons.dart';
import 'package:lw_app/Themes/lwp_tokens.dart';
import 'package:lw_app/Utils/cloudinary_helper.dart';
import 'package:lw_app/Utils/date_formatter.dart';
import 'package:lw_app/Utils/maps_helper.dart';
import 'package:lw_app/Widgets/Glass/lwp_chrome_scaffold.dart';
import 'package:lw_app/Widgets/Glass/lwp_top_bar.dart';
import 'package:lw_app/Widgets/LwpEmpty/lwp_empty.dart';
import 'package:lw_app/Widgets/LwpError/lwp_error.dart';
import 'package:lw_app/Widgets/LwpSkeleton/lwp_skeleton.dart';
import 'package:lw_app/Widgets/LwpSnackbar/lwp_snackbar.dart';
import 'package:url_launcher/url_launcher.dart';

class GroupDetailPage extends StatelessWidget {
  final String groupId;

  const GroupDetailPage({
    super.key,
    required this.groupId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GroupDetailBloc()..add(LoadGroupDetail(groupId)),
      child: _GroupDetailView(groupId: groupId),
    );
  }
}

class _GroupDetailView extends StatefulWidget {
  final String groupId;

  const _GroupDetailView({
    required this.groupId,
  });

  @override
  State<_GroupDetailView> createState() => _GroupDetailViewState();
}

class _GroupDetailViewState extends State<_GroupDetailView> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<GroupDetailBloc, GroupDetailState>(
      listenWhen: (previous, current) => previous.message != current.message,
      listener: (context, state) {
        if (state.message == null || state.message!.isEmpty) return;

        if (state.isErrorMessage) {
          LwpSnackbar.showError(context, state.message!);
        } else {
          LwpSnackbar.showSuccess(context, state.message!);
        }

        context.read<GroupDetailBloc>().add(const ClearGroupDetailMessage());
      },
      child: BlocBuilder<GroupDetailBloc, GroupDetailState>(
        builder: (context, state) {
          final group = state.group;

          if (state.status == GroupDetailStatus.loading &&
              group == null &&
              !state.isRefreshing) {
            return LwpChromeScaffold(
              title: context.l10n.groupDetailTitle,
              body: LwpSkeletonList.group(itemCount: 4),
            );
          }

          if (state.status == GroupDetailStatus.error && group == null) {
            return LwpChromeScaffold(
              title: context.l10n.groupDetailTitle,
              body: LwpError(
                message: state.error ?? 'Kon nie groep laai nie.',
                onRetry: () => context
                    .read<GroupDetailBloc>()
                    .add(LoadGroupDetail(widget.groupId)),
              ),
            );
          }

          if (group == null) {
            return LwpChromeScaffold(
              title: context.l10n.groupDetailTitle,
              body: LwpEmpty(message: context.l10n.groupFeedGroupNotFound),
            );
          }

          return Scaffold(
            body: Stack(
              fit: StackFit.expand,
              children: [
                RefreshIndicator(
                  onRefresh: () async {
                    context
                        .read<GroupDetailBloc>()
                        .add(RefreshGroupDetail(widget.groupId));
                  },
                  child: ListView(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.paddingOf(context).bottom +
                          LwpSpacing.xl,
                    ),
                    children: [
                      _GroupHero(group: group),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          LwpSpacing.md,
                          LwpSpacing.sm,
                          LwpSpacing.md,
                          0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _StatsStrip(group: group),
                            const SizedBox(height: LwpSpacing.md),
                            _GroupActions(
                              group: group,
                              isBusy: state.isActionInProgress,
                              onRequestJoin: () => context
                                  .read<GroupDetailBloc>()
                                  .add(RequestToJoinGroup(widget.groupId)),
                              onCancelRequest: () => context
                                  .read<GroupDetailBloc>()
                                  .add(CancelGroupJoinRequest(widget.groupId)),
                              onLeaveGroup: () => _confirmLeaveGroup(
                                context,
                                context.read<GroupDetailBloc>(),
                              ),
                              onOpenWhatsApp: () =>
                                  _launchWhatsApp(context, group),
                              onOpenMaps: group.hasLocation
                                  ? () =>
                                      MapsHelper.openLocation(group.location!)
                                  : null,
                            ),
                            if (group.isActiveMember || group.isLeader) ...[
                              const SizedBox(height: LwpSpacing.md),
                              _GroupFeedEntryRow(
                                postCount: state.posts.length,
                                onOpenFeed: () => _openFeed(context, group),
                              ),
                            ],
                            if (group.isLeader) ...[
                              const SizedBox(height: LwpSpacing.md),
                              _MembershipSection(
                                title: context
                                    .l10n.groupDetailPendingRequestsTitle,
                                subtitle: context
                                    .l10n.groupDetailPendingRequestsSubtitle,
                                count: state.pendingMembers.length,
                                memberships: state.pendingMembers,
                                emptyMessage: context
                                    .l10n.groupDetailPendingRequestsEmpty,
                                actionBuilder: (membership) =>
                                    _PendingActions(
                                  isBusy: state.isActionInProgress,
                                  onDecline: () =>
                                      context.read<GroupDetailBloc>().add(
                                            DeclineGroupMembership(
                                              widget.groupId,
                                              membership.userId,
                                            ),
                                          ),
                                  onApprove: () =>
                                      context.read<GroupDetailBloc>().add(
                                            ApproveGroupMembership(
                                              widget.groupId,
                                              membership.userId,
                                            ),
                                          ),
                                ),
                              ),
                              const SizedBox(height: LwpSpacing.md),
                              _ActiveMembersSection(
                                memberships: state.activeMembers,
                                isBusy: state.isActionInProgress,
                                groupId: widget.groupId,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: LwpTopBar(
                    title: group.title,
                    showBack: true,
                    showActions: false,
                    actions: [
                      if (group.isActiveMember || group.isLeader)
                        IconButton(
                          onPressed: () => _openFeed(context, group),
                          icon: const Icon(Icons.dynamic_feed_outlined),
                          tooltip: context.l10n.groupDetailOpenFeedTooltip,
                        ),
                      if (group.isLeader)
                        IconButton(
                          onPressed: state.isActionInProgress
                              ? null
                              : () => _showEditSheet(context, group),
                          icon: const Icon(Icons.edit_outlined),
                          tooltip: context.l10n.groupDetailEditTooltip,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showEditSheet(BuildContext context, Group group) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => BlocProvider.value(
        value: context.read<GroupDetailBloc>(),
        child: _EditGroupSheet(group: group),
      ),
    );
  }

  Future<void> _confirmLeaveGroup(
    BuildContext context,
    GroupDetailBloc bloc,
  ) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(context.l10n.groupDetailLeaveTitle),
            content: Text(context.l10n.groupDetailLeaveBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(context.l10n.commonCancel),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(context.l10n.groupDetailLeaveButton),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) return;
    bloc.add(LeaveGroup(widget.groupId));
  }

  Future<void> _openFeed(BuildContext context, Group group) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GroupFeedPage(groupId: group.id ?? ''),
      ),
    );

    if (!context.mounted) return;
    context.read<GroupDetailBloc>().add(RefreshGroupDetail(widget.groupId));
  }

  Future<void> _launchWhatsApp(BuildContext context, Group group) async {
    String link = (group.whatsappLink ?? '').trim();
    if (link.isEmpty) {
      LwpSnackbar.showWarning(
        context,
        context.l10n.groupDetailWhatsappUnavailable,
      );
      return;
    }

    if (!link.startsWith('http') && !link.startsWith('whatsapp:')) {
      if (link.startsWith('+')) {
        link = 'https://wa.me/$link';
      } else {
        link =
            'https://wa.me/+27${link.startsWith('0') ? link.substring(1) : link}';
      }
    }

    final uri = Uri.parse(link);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }

    if (context.mounted) {
      LwpSnackbar.showError(
        context,
        context.l10n.groupOpenWhatsappFailed,
      );
    }
  }
}

class _GroupHero extends StatelessWidget {
  final Group group;

  const _GroupHero({
    required this.group,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Banner breathes under chrome; chips/title sit lower in the hero.
    final topClearance =
        LwpTopBar.heightOf(context) + LwpSpacing.xxl + LwpSpacing.lg;
    const contentBlock = 132.0;
    final heroHeight = topClearance + contentBlock + LwpSpacing.md;

    return SizedBox(
      height: heroHeight,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CldImageWidget(
            publicId: group.bannerPublicId ?? 'samples/cloudinary-icon',
            width: double.infinity,
            height: heroHeight,
            fit: BoxFit.cover,
          ),
          // Dark scrim under chips/title so white type stays readable in
          // light mode and on bright banners; soft handoff into the page.
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.28),
                  Colors.black.withValues(alpha: 0.08),
                  Colors.black.withValues(alpha: 0.55),
                  Colors.black.withValues(alpha: 0.72),
                  theme.scaffoldBackgroundColor,
                ],
                stops: const [0.0, 0.28, 0.58, 0.88, 1.0],
              ),
            ),
          ),
          Positioned(
            left: LwpSpacing.md,
            right: LwpSpacing.md,
            top: topClearance,
            bottom: LwpSpacing.md,
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: LwpSpacing.xs,
                    runSpacing: LwpSpacing.xs,
                    children: [
                      _PillChip(
                        label: group.isConnectGroup
                            ? context.l10n.connectGroupsTitle
                            : context.l10n.serveGroupsTitle,
                        backgroundColor:
                            theme.primaryColor.withValues(alpha: 0.18),
                        foregroundColor: Colors.white,
                      ),
                      if (group.isLeader)
                        _PillChip(
                          label: context.l10n.groupLeaderBadge,
                          backgroundColor:
                              Colors.amber.withValues(alpha: 0.22),
                          foregroundColor: Colors.amber.shade100,
                        )
                      else if (group.membershipStatus != null)
                        _PillChip(
                          label: _membershipLabel(context, group),
                          backgroundColor: _membershipTone(group, theme)
                              .withValues(alpha: 0.22),
                          foregroundColor: Colors.white,
                        ),
                    ],
                  ),
                  const SizedBox(height: LwpSpacing.sm),
                  Text(
                    group.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                    ),
                  ),
                  if (group.description.trim().isNotEmpty) ...[
                    const SizedBox(height: LwpSpacing.xs),
                    Text(
                      group.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.82),
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsStrip extends StatelessWidget {
  final Group group;

  const _StatsStrip({
    required this.group,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final line = theme.brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.08)
        : LightColors.outline;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: LwpRadii.smAll,
        border: Border.all(color: line),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _StatCell(
                value: group.leaderCount,
                label: context.l10n.groupDetailLeadersLabel,
              ),
            ),
            VerticalDivider(width: 1, thickness: 1, color: line),
            Expanded(
              child: _StatCell(
                value: group.memberCount,
                label: context.l10n.groupDetailMembersLabel,
              ),
            ),
            VerticalDivider(width: 1, thickness: 1, color: line),
            Expanded(
              child: _StatCell(
                value: group.pendingCount,
                label: context.l10n.groupDetailPendingLabel,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final int value;
  final String label;

  const _StatCell({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: LwpSpacing.xs,
        vertical: LwpSpacing.sm,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$value',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.hintColor,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupActions extends StatelessWidget {
  final Group group;
  final bool isBusy;
  final VoidCallback onRequestJoin;
  final VoidCallback onCancelRequest;
  final VoidCallback onLeaveGroup;
  final VoidCallback onOpenWhatsApp;
  final VoidCallback? onOpenMaps;

  const _GroupActions({
    required this.group,
    required this.isBusy,
    required this.onRequestJoin,
    required this.onCancelRequest,
    required this.onLeaveGroup,
    required this.onOpenWhatsApp,
    required this.onOpenMaps,
  });

  @override
  Widget build(BuildContext context) {
    final secondary = <Widget>[];

    if (onOpenMaps != null) {
      secondary.add(
        Expanded(
          child: OutlinedButton(
            onPressed: isBusy ? null : onOpenMaps,
            child: Text(context.l10n.groupOpenMaps),
          ),
        ),
      );
    }

    final primary = _primaryButton(context);
    final leaveOrCancel = _secondaryFullWidth(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (primary != null) primary,
        if (secondary.isNotEmpty) ...[
          if (primary != null) const SizedBox(height: LwpSpacing.xs),
          Row(
            children: [
              for (var i = 0; i < secondary.length; i++) ...[
                if (i > 0) const SizedBox(width: LwpSpacing.xs),
                secondary[i],
              ],
            ],
          ),
        ],
        if (leaveOrCancel != null) ...[
          const SizedBox(height: LwpSpacing.xs),
          leaveOrCancel,
        ],
      ],
    );
  }

  Widget? _primaryButton(BuildContext context) {
    if (group.isLeader || group.isActiveMember) {
      if (!group.hasWhatsappLink) return null;
      return ElevatedButton.icon(
        onPressed: isBusy ? null : onOpenWhatsApp,
        icon: const FaIcon(LwpIcons.whatsapp, size: 16),
        label: Text(context.l10n.groupDetailOpenWhatsappGroup),
      );
    }

    if (group.isPending) {
      return ElevatedButton.icon(
        onPressed: null,
        icon: const Icon(Icons.schedule),
        label: Text(context.l10n.groupMembershipPending),
      );
    }

    return ElevatedButton.icon(
      onPressed: isBusy ? null : onRequestJoin,
      icon: const Icon(Icons.group_add_outlined),
      label: Text(context.l10n.groupDetailRequestJoin),
    );
  }

  Widget? _secondaryFullWidth(BuildContext context) {
    if (group.isPending) {
      return OutlinedButton.icon(
        onPressed: isBusy ? null : onCancelRequest,
        icon: const Icon(Icons.close),
        label: Text(context.l10n.groupDetailCancelRequest),
      );
    }

    if (group.isActiveMember && !group.isLeader) {
      return OutlinedButton.icon(
        onPressed: isBusy ? null : onLeaveGroup,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.redAccent.shade200,
          side: BorderSide(
            color: Colors.redAccent.withValues(alpha: 0.35),
          ),
        ),
        icon: Icon(
          Icons.logout,
          color: Colors.redAccent.shade200,
        ),
        label: Text(
          context.l10n.groupDetailLeaveGroup,
          style: TextStyle(color: Colors.redAccent.shade200),
        ),
      );
    }

    return null;
  }
}

class _GroupFeedEntryRow extends StatelessWidget {
  final int postCount;
  final VoidCallback onOpenFeed;

  const _GroupFeedEntryRow({
    required this.postCount,
    required this.onOpenFeed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final line = theme.brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.08)
        : LightColors.outline;

    return Material(
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: LwpRadii.lgAll,
        side: BorderSide(color: line),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpenFeed,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: LwpSpacing.md,
            vertical: LwpSpacing.sm,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(LwpRadii.sm),
                ),
                child: Icon(
                  Icons.dynamic_feed_outlined,
                  color: theme.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: LwpSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.groupFeedTitle,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.l10n.groupFeedPostCount(postCount),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.hintColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuietPanel extends StatelessWidget {
  final Widget child;

  const _QuietPanel({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final line = theme.brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.08)
        : LightColors.outline;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: LwpRadii.lgAll,
        border: Border.all(color: line),
      ),
      child: ClipRRect(
        borderRadius: LwpRadii.lgAll,
        child: child,
      ),
    );
  }
}

class _MembershipSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final int count;
  final List<GroupMembership> memberships;
  final String emptyMessage;
  final Widget Function(GroupMembership membership) actionBuilder;

  const _MembershipSection({
    required this.title,
    required this.subtitle,
    required this.count,
    required this.memberships,
    required this.emptyMessage,
    required this.actionBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final line = theme.brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.08)
        : LightColors.outline;

    return _QuietPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              LwpSpacing.md,
              LwpSpacing.md,
              LwpSpacing.md,
              0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                Text(
                  '$count',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              LwpSpacing.md,
              LwpSpacing.xxs,
              LwpSpacing.md,
              LwpSpacing.sm,
            ),
            child: Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.hintColor,
              ),
            ),
          ),
          if (memberships.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                LwpSpacing.md,
                0,
                LwpSpacing.md,
                LwpSpacing.md,
              ),
              child: LwpEmpty(message: emptyMessage),
            )
          else
            for (var i = 0; i < memberships.length; i++) ...[
              Divider(height: 1, thickness: 1, color: line),
              _PendingMemberRow(
                membership: memberships[i],
                action: actionBuilder(memberships[i]),
              ),
            ],
        ],
      ),
    );
  }
}

class _PendingActions extends StatelessWidget {
  final bool isBusy;
  final VoidCallback onDecline;
  final VoidCallback onApprove;

  const _PendingActions({
    required this.isBusy,
    required this.onDecline,
    required this.onApprove,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        OutlinedButton(
          onPressed: isBusy ? null : onDecline,
          style: OutlinedButton.styleFrom(
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: LwpSpacing.sm),
            minimumSize: const Size(0, 32),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: const StadiumBorder(),
          ),
          child: Text(context.l10n.groupDetailDecline),
        ),
        const SizedBox(width: LwpSpacing.xs),
        FilledButton(
          onPressed: isBusy ? null : onApprove,
          style: FilledButton.styleFrom(
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: LwpSpacing.sm),
            minimumSize: const Size(0, 32),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: const StadiumBorder(),
          ),
          child: Text(context.l10n.groupDetailApprove),
        ),
      ],
    );
  }
}

class _PendingMemberRow extends StatelessWidget {
  final GroupMembership membership;
  final Widget action;

  const _PendingMemberRow({
    required this.membership,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final email = (membership.email ?? '').trim();
    final requested = membership.requestedAt != null
        ? DateFormatter.formatDate(membership.requestedAt)
        : null;
    final subtitleParts = <String>[
      if (email.isNotEmpty) email,
      if (requested != null)
        context.l10n.groupDetailRequestDate(requested),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: LwpSpacing.md,
        vertical: LwpSpacing.sm,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: theme.primaryColor.withValues(alpha: 0.12),
            child: Text(
              _initials(membership),
              style: TextStyle(
                color: theme.primaryColor,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: LwpSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _displayName(membership),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitleParts.isNotEmpty)
                  Text(
                    subtitleParts.join(' · '),
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.hintColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          const SizedBox(width: LwpSpacing.xs),
          action,
        ],
      ),
    );
  }
}

class _ActiveMembersSection extends StatefulWidget {
  final List<GroupMembership> memberships;
  final bool isBusy;
  final String groupId;

  const _ActiveMembersSection({
    required this.memberships,
    required this.isBusy,
    required this.groupId,
  });

  @override
  State<_ActiveMembersSection> createState() => _ActiveMembersSectionState();
}

class _ActiveMembersSectionState extends State<_ActiveMembersSection> {
  String? _armedUserId;

  @override
  void didUpdateWidget(covariant _ActiveMembersSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_armedUserId == null) return;
    final stillPresent =
        widget.memberships.any((m) => m.userId == _armedUserId);
    if (!stillPresent) {
      _armedUserId = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final line = theme.brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.08)
        : LightColors.outline;

    return _QuietPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              LwpSpacing.md,
              LwpSpacing.md,
              LwpSpacing.md,
              0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    context.l10n.groupDetailActiveMembersTitle,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                Text(
                  '${widget.memberships.length}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              LwpSpacing.md,
              LwpSpacing.xxs,
              LwpSpacing.md,
              LwpSpacing.sm,
            ),
            child: Text(
              context.l10n.groupDetailActiveMembersSubtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.hintColor,
              ),
            ),
          ),
          if (widget.memberships.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                LwpSpacing.md,
                0,
                LwpSpacing.md,
                LwpSpacing.md,
              ),
              child: LwpEmpty(
                message: context.l10n.groupDetailActiveMembersEmpty,
              ),
            )
          else
            for (var i = 0; i < widget.memberships.length; i++) ...[
              Divider(height: 1, thickness: 1, color: line),
              _ActiveMemberRow(
                membership: widget.memberships[i],
                armed: _armedUserId == widget.memberships[i].userId,
                isBusy: widget.isBusy,
                onArm: () => setState(
                  () => _armedUserId = widget.memberships[i].userId,
                ),
                onCancel: () => setState(() => _armedUserId = null),
                onRemove: () {
                  final userId = widget.memberships[i].userId;
                  setState(() => _armedUserId = null);
                  context.read<GroupDetailBloc>().add(
                        RemoveGroupMember(widget.groupId, userId),
                      );
                },
              ),
            ],
        ],
      ),
    );
  }
}

class _ActiveMemberRow extends StatelessWidget {
  static const _animDuration = Duration(milliseconds: 280);
  static const _animCurve = Curves.easeOutCubic;

  final GroupMembership membership;
  final bool armed;
  final bool isBusy;
  final VoidCallback onArm;
  final VoidCallback onCancel;
  final VoidCallback onRemove;

  const _ActiveMemberRow({
    required this.membership,
    required this.armed,
    required this.isBusy,
    required this.onArm,
    required this.onCancel,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = _displayName(membership);
    final statusColor = _membershipStatusColor(membership.status);

    return AnimatedContainer(
      duration: _animDuration,
      curve: _animCurve,
      width: double.infinity,
      color: armed
          ? Colors.redAccent.withValues(alpha: 0.14)
          : Colors.transparent,
      child: AnimatedSize(
        duration: _animDuration,
        curve: _animCurve,
        alignment: Alignment.center,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            final slide = Tween<Offset>(
              begin: const Offset(0.03, 0),
              end: Offset.zero,
            ).animate(animation);
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(position: slide, child: child),
            );
          },
          child: armed
              ? KeyedSubtree(
                  key: const ValueKey('armed'),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: LwpSpacing.md,
                      vertical: LwpSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${context.l10n.commonRemove} $name?',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.redAccent.shade100,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        TextButton(
                          onPressed: isBusy ? null : onCancel,
                          child: Text(context.l10n.commonCancel),
                        ),
                        FilledButton(
                          onPressed: isBusy ? null : onRemove,
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            visualDensity: VisualDensity.compact,
                            shape: const StadiumBorder(),
                          ),
                          child: Text(context.l10n.commonRemove),
                        ),
                      ],
                    ),
                  ),
                )
              : KeyedSubtree(
                  key: const ValueKey('idle'),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: LwpSpacing.md,
                      vertical: LwpSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor:
                              theme.primaryColor.withValues(alpha: 0.12),
                          child: Text(
                            _initials(membership),
                            style: TextStyle(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: LwpSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if ((membership.email ?? '').isNotEmpty)
                                Text(
                                  membership.email!,
                                  style: theme.textTheme.bodySmall
                                      ?.copyWith(color: theme.hintColor),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: LwpSpacing.xs),
                        _PillChip(
                          label: _membershipStatusLabel(
                            context,
                            membership.status,
                          ),
                          backgroundColor: statusColor.withValues(alpha: 0.14),
                          foregroundColor: statusColor,
                          compact: true,
                        ),
                        IconButton(
                          onPressed: isBusy ? null : onArm,
                          tooltip: context.l10n.commonRemove,
                          visualDensity: VisualDensity.compact,
                          icon: Icon(
                            Icons.person_remove_outlined,
                            color: theme.hintColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

class _PillChip extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final bool compact;

  const _PillChip({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: LwpSpacing.sm,
        vertical: compact ? 4 : LwpSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(LwpRadii.pill),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foregroundColor,
          fontWeight: FontWeight.w600,
          fontSize: compact ? 11 : 12,
        ),
      ),
    );
  }
}

class _EditGroupSheet extends StatefulWidget {
  final Group group;

  const _EditGroupSheet({
    required this.group,
  });

  @override
  State<_EditGroupSheet> createState() => _EditGroupSheetState();
}

class _EditGroupSheetState extends State<_EditGroupSheet> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _whatsappController;
  late final TextEditingController _locationController;

  File? _bannerFile;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.group.title);
    _descriptionController =
        TextEditingController(text: widget.group.description);
    _whatsappController =
        TextEditingController(text: widget.group.whatsappLink ?? '');
    _locationController =
        TextEditingController(text: widget.group.location ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _whatsappController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBusy = context.select<GroupDetailBloc, bool>(
          (bloc) => bloc.state.isActionInProgress,
        ) ||
        _isUploading;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: LwpRadii.lgTop,
      ),
      padding: EdgeInsets.only(
        left: LwpSpacing.md,
        right: LwpSpacing.md,
        top: LwpSpacing.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + LwpSpacing.md,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 56,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.hintColor.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(LwpRadii.pill),
                  ),
                ),
              ),
              const SizedBox(height: LwpSpacing.md),
              Text(context.l10n.groupDetailEditTitle,
                  style: theme.textTheme.titleLarge),
              const SizedBox(height: LwpSpacing.sm),
              Text(
                context.l10n.groupDetailEditSubtitle,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.hintColor),
              ),
              const SizedBox(height: LwpSpacing.md),
              ClipRRect(
                borderRadius: LwpRadii.mdAll,
                child: _bannerFile != null
                    ? Image.file(
                        _bannerFile!,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : CldImageWidget(
                        publicId: widget.group.bannerPublicId ??
                            'samples/cloudinary-icon',
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
              ),
              const SizedBox(height: LwpSpacing.sm),
              OutlinedButton.icon(
                onPressed: isBusy ? null : _pickBanner,
                icon: const Icon(Icons.image_outlined),
                label: Text(context.l10n.groupDetailChooseNewBanner),
              ),
              const SizedBox(height: LwpSpacing.md),
              TextFormField(
                controller: _titleController,
                validator: (value) => value == null || value.trim().isEmpty
                    ? context.l10n.profileEditNameRequired
                    : null,
                decoration: InputDecoration(
                  labelText: context.l10n.notesTitleHint,
                  prefixIcon: const Icon(Icons.title),
                ),
              ),
              const SizedBox(height: LwpSpacing.md),
              TextFormField(
                controller: _descriptionController,
                minLines: 4,
                maxLines: 6,
                validator: (value) => value == null || value.trim().isEmpty
                    ? context.l10n.groupDetailDescriptionRequired
                    : null,
                decoration: InputDecoration(
                  labelText: context.l10n.groupDescriptionTitle,
                  alignLabelWithHint: true,
                  prefixIcon: const Icon(Icons.notes_outlined),
                ),
              ),
              const SizedBox(height: LwpSpacing.md),
              TextFormField(
                controller: _whatsappController,
                decoration: InputDecoration(
                  labelText: context.l10n.groupDetailWhatsappLink,
                  prefixIcon: const FaIcon(LwpIcons.whatsapp),
                ),
              ),
              const SizedBox(height: LwpSpacing.md),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: context.l10n.groupDetailLocation,
                  prefixIcon: const Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: LwpSpacing.lg),
              ElevatedButton(
                onPressed: isBusy ? null : _submit,
                child: isBusy
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(context.l10n.groupDetailSaveChanges),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickBanner() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() {
      _bannerFile = File(picked.path);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isUploading = true;
    });

    String? bannerUrl = widget.group.bannerUrl;
    String? bannerPublicId = widget.group.bannerPublicId;

    try {
      if (_bannerFile != null) {
        final uploadResponse =
            await CloudinaryHelper.uploadImage(_bannerFile!, 'lw-uploads');
        bannerPublicId = uploadResponse['public_id'];
        bannerUrl = uploadResponse['url'];
      }

      if (!mounted) return;

      context.read<GroupDetailBloc>().add(
            UpdateGroupFromLeader(
              groupId: widget.group.id ?? '',
              title: _titleController.text.trim(),
              description: _descriptionController.text.trim(),
              whatsappLink: _whatsappController.text.trim(),
              location: _locationController.text.trim(),
              bannerUrl: bannerUrl,
              bannerPublicId: bannerPublicId,
            ),
          );

      Navigator.pop(context);
    } catch (error) {
      if (mounted) {
        LwpSnackbar.showError(
            context, context.l10n.groupDetailBannerUploadError);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }
}

String _membershipLabel(BuildContext context, Group group) {
  switch (group.membershipStatus) {
    case 'pending':
      return context.l10n.groupMembershipPending;
    case 'active':
      return context.l10n.groupMembershipActive;
    case 'declined':
      return context.l10n.groupMembershipDeclined;
    case 'left':
      return context.l10n.groupMembershipLeft;
    case 'removed':
      return context.l10n.commonDelete;
    default:
      return context.l10n.groupDetailPublic;
  }
}

Color _membershipTone(Group group, ThemeData theme) {
  switch (group.membershipStatus) {
    case 'pending':
      return Colors.orange.shade700;
    case 'active':
      return Colors.green.shade700;
    default:
      return theme.hintColor;
  }
}

String _membershipStatusLabel(BuildContext context, String status) {
  return status.groupMembershipLabel(context.l10n);
}

Color _membershipStatusColor(String status) {
  switch (status) {
    case GroupMembershipStatus.pending:
      return Colors.orange.shade700;
    case GroupMembershipStatus.active:
      return Colors.green.shade700;
    default:
      return Colors.grey.shade700;
  }
}

String _displayName(GroupMembership membership) {
  final fullName = membership.fullName?.trim() ?? '';
  if (fullName.isNotEmpty) return fullName;

  final combined = [membership.firstName, membership.lastName]
      .whereType<String>()
      .where((value) => value.trim().isNotEmpty)
      .join(' ')
      .trim();
  if (combined.isNotEmpty) return combined;

  return membership.email ?? 'Unknown member';
}

String _initials(GroupMembership membership) {
  final name = _displayName(membership);
  final parts = name.split(' ').where((part) => part.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
}
