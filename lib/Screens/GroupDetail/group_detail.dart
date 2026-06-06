import 'dart:io';

import 'package:cloudinary_flutter/image/cld_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lw_app/Blocs/GroupDetail/group_detail_bloc.dart';
import 'package:lw_app/Models/Group/group.dart';
import 'package:lw_app/Models/Group/group_membership.dart';
import 'package:lw_app/Screens/GroupFeed/group_feed.dart';
import 'package:lw_app/Themes/custom_theme.dart';
import 'package:lw_app/Themes/lwp_tokens.dart';
import 'package:lw_app/Utils/cloudinary_helper.dart';
import 'package:lw_app/Utils/date_formatter.dart';
import 'package:lw_app/Utils/maps_helper.dart';
import 'package:lw_app/Widgets/LwpEmpty/lwp_empty.dart';
import 'package:lw_app/Widgets/LwpError/lwp_error.dart';
import 'package:lw_app/Widgets/LwpLoader/lwp_loader.dart';
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

          return Scaffold(
            appBar: AppBar(
              title: Text(group?.title ?? 'Groep'),
              actions: [
                if (group != null && (group.isActiveMember || group.isLeader))
                  IconButton(
                    onPressed: () => _openFeed(context, group),
                    icon: const Icon(Icons.dynamic_feed_outlined),
                    tooltip: 'Open groepfeed',
                  ),
                if (group?.isLeader == true)
                  IconButton(
                    onPressed: state.isActionInProgress
                        ? null
                        : () => _showEditSheet(context, group!),
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: 'Wysig groep',
                  ),
              ],
            ),
            body: _buildBody(context, state),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, GroupDetailState state) {
    if (state.status == GroupDetailStatus.loading &&
        state.group == null &&
        !state.isRefreshing) {
      return const LwpLoader(message: 'Laai groep...');
    }

    if (state.status == GroupDetailStatus.error && state.group == null) {
      return LwpError(
        message: state.error ?? 'Kon nie groep laai nie.',
        onRetry: () => context
            .read<GroupDetailBloc>()
            .add(LoadGroupDetail(widget.groupId)),
      );
    }

    final group = state.group;
    if (group == null) {
      return const LwpEmpty(message: 'Geen groep gevind nie');
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<GroupDetailBloc>().add(RefreshGroupDetail(widget.groupId));
      },
      child: ListView(
        padding: const EdgeInsets.all(LwpSpacing.md),
        children: [
          _GroupHero(group: group),
          const SizedBox(height: LwpSpacing.md),
          _GroupStatusCard(group: group),
          const SizedBox(height: LwpSpacing.md),
          _GroupActionCard(
            group: group,
            isBusy: state.isActionInProgress,
            onRequestJoin: () => context
                .read<GroupDetailBloc>()
                .add(RequestToJoinGroup(widget.groupId)),
            onCancelRequest: () => context
                .read<GroupDetailBloc>()
                .add(CancelGroupJoinRequest(widget.groupId)),
            onLeaveGroup: () =>
                _confirmLeaveGroup(context, context.read<GroupDetailBloc>()),
            onOpenWhatsApp: () => _launchWhatsApp(context, group),
            onOpenMaps: group.hasLocation
                ? () => MapsHelper.openLocation(group.location!)
                : null,
          ),
          if (group.isActiveMember || group.isLeader) ...[
            const SizedBox(height: LwpSpacing.lg),
            _GroupFeedEntryCard(
              group: group,
              postCount: state.posts.length,
              onOpenFeed: () => _openFeed(context, group),
            ),
          ],
          if (group.isLeader) ...[
            const SizedBox(height: LwpSpacing.lg),
            _MembershipSection(
              title: 'Hangende Versoeke',
              subtitle: 'Keur nuwe aansluitings goed of af.',
              memberships: state.pendingMembers,
              emptyMessage: 'Geen hangende versoeke nie',
              actionBuilder: (membership) => Wrap(
                spacing: LwpSpacing.xs,
                runSpacing: LwpSpacing.xs,
                children: [
                  OutlinedButton(
                    onPressed: state.isActionInProgress
                        ? null
                        : () => context.read<GroupDetailBloc>().add(
                              DeclineGroupMembership(
                                widget.groupId,
                                membership.userId,
                              ),
                            ),
                    child: const Text('Keur Af'),
                  ),
                  ElevatedButton(
                    onPressed: state.isActionInProgress
                        ? null
                        : () => context.read<GroupDetailBloc>().add(
                              ApproveGroupMembership(
                                widget.groupId,
                                membership.userId,
                              ),
                            ),
                    child: const Text('Keur Goed'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: LwpSpacing.lg),
            _MembershipSection(
              title: 'Aktiewe Lede',
              subtitle: 'Verwyder lede indien nodig.',
              memberships: state.activeMembers,
              emptyMessage: 'Geen aktiewe lede nie',
              actionBuilder: (membership) => OutlinedButton.icon(
                onPressed: state.isActionInProgress
                    ? null
                    : () => _confirmRemoveMember(
                          context,
                          membership,
                          context.read<GroupDetailBloc>(),
                        ),
                icon: const Icon(Icons.person_remove_outlined),
                label: const Text('Verwyder'),
              ),
            ),
          ],
        ],
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
            title: const Text('Verlaat groep'),
            content: const Text('Is jy seker jy wil hierdie groep verlaat?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Kanselleer'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Verlaat'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) return;
    bloc.add(LeaveGroup(widget.groupId));
  }

  Future<void> _confirmRemoveMember(
    BuildContext context,
    GroupMembership membership,
    GroupDetailBloc bloc,
  ) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Verwyder lid'),
            content: Text(
              'Is jy seker jy wil ${_displayName(membership)} uit hierdie groep verwyder?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Kanselleer'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Verwyder'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) return;
    bloc.add(RemoveGroupMember(widget.groupId, membership.userId));
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
        'WhatsApp-skakel is nog nie beskikbaar vir hierdie groep nie.',
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
        'Kon nie WhatsApp oopmaak nie. Maak seker die app is geïnstalleer.',
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

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: LwpRadii.lgTop,
            child: CldImageWidget(
              publicId: group.bannerPublicId ?? 'samples/cloudinary-icon',
              width: double.infinity,
              height: 220,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(LwpSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: LwpSpacing.xs,
                  runSpacing: LwpSpacing.xs,
                  children: [
                    _PillChip(
                      label:
                          group.isConnectGroup ? 'Konneksie Groep' : 'Kom Dien',
                      backgroundColor:
                          theme.primaryColor.withValues(alpha: 0.12),
                      foregroundColor: theme.primaryColor,
                    ),
                    if (group.membershipStatus != null)
                      _PillChip(
                        label: _membershipLabel(group),
                        backgroundColor: _membershipTone(group, theme)
                            .withValues(alpha: 0.14),
                        foregroundColor: _membershipTone(group, theme),
                      ),
                    if (group.isLeader)
                      _PillChip(
                        label: 'Leier',
                        backgroundColor: Colors.amber.withValues(alpha: 0.18),
                        foregroundColor: Colors.orange.shade800,
                      ),
                  ],
                ),
                const SizedBox(height: LwpSpacing.sm),
                Text(
                  group.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: LwpSpacing.sm),
                Text(
                  group.description,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.5,
                    color: theme.hintColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupStatusCard extends StatelessWidget {
  final Group group;

  const _GroupStatusCard({
    required this.group,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _CountCard(
            label: 'Leiers',
            value: group.leaderCount,
            icon: Icons.shield_outlined,
          ),
        ),
        const SizedBox(width: LwpSpacing.sm),
        Expanded(
          child: _CountCard(
            label: 'Lede',
            value: group.memberCount,
            icon: Icons.people_outline,
          ),
        ),
        const SizedBox(width: LwpSpacing.sm),
        Expanded(
          child: _CountCard(
            label: 'Hangend',
            value: group.pendingCount,
            icon: Icons.schedule_outlined,
          ),
        ),
      ],
    );
  }
}

class _GroupActionCard extends StatelessWidget {
  final Group group;
  final bool isBusy;
  final VoidCallback onRequestJoin;
  final VoidCallback onCancelRequest;
  final VoidCallback onLeaveGroup;
  final VoidCallback onOpenWhatsApp;
  final VoidCallback? onOpenMaps;

  const _GroupActionCard({
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
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(LwpSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aksies',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: LwpSpacing.xs),
            Text(
              _actionDescription(group),
              style:
                  theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
            ),
            const SizedBox(height: LwpSpacing.md),
            if (onOpenMaps != null)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: isBusy ? null : onOpenMaps,
                  icon: const Icon(Icons.location_on_outlined),
                  label: const Text('Maak Oop In Maps'),
                ),
              ),
            if (onOpenMaps != null) const SizedBox(height: LwpSpacing.sm),
            ..._buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActionButtons(BuildContext context) {
    if (group.isLeader) {
      return [
        if (group.hasWhatsappLink)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isBusy ? null : onOpenWhatsApp,
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('Open WhatsApp Groep'),
            ),
          ),
      ];
    }

    if (group.isPending) {
      return [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: null,
            icon: const Icon(Icons.schedule),
            label: const Text('Versoek Hangend'),
          ),
        ),
        const SizedBox(height: LwpSpacing.sm),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: isBusy ? null : onCancelRequest,
            icon: const Icon(Icons.close),
            label: const Text('Kanselleer Versoek'),
          ),
        ),
      ];
    }

    if (group.isActiveMember) {
      return [
        if (group.hasWhatsappLink)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isBusy ? null : onOpenWhatsApp,
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('Open WhatsApp Groep'),
            ),
          ),
        if (group.hasWhatsappLink) const SizedBox(height: LwpSpacing.sm),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: isBusy ? null : onLeaveGroup,
            icon: const Icon(Icons.logout),
            label: const Text('Verlaat Groep'),
          ),
        ),
      ];
    }

    return [
      SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: isBusy ? null : onRequestJoin,
          icon: const Icon(Icons.group_add_outlined),
          label: const Text('Versoek Om Aan Te Sluit'),
        ),
      ),
    ];
  }

  String _actionDescription(Group group) {
    if (group.isLeader) {
      return 'Jy bestuur hierdie groep as leier. Lede en versoeke verskyn hieronder.';
    }

    if (group.isPending) {
      return 'Jou versoek is gestuur en wag vir goedkeuring.';
    }

    if (group.isActiveMember) {
      return 'Jy is reeds deel van hierdie groep.';
    }

    return 'Sluit by hierdie groep aan om toegang tot die WhatsApp-skakel en groepdeelname te kry.';
  }
}

class _GroupFeedEntryCard extends StatelessWidget {
  final Group group;
  final int postCount;
  final VoidCallback onOpenFeed;

  const _GroupFeedEntryCard({
    required this.group,
    required this.postCount,
    required this.onOpenFeed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: LwpRadii.lgAll,
        gradient: LinearGradient(
          colors: [
            theme.primaryColor.withValues(alpha: 0.95),
            theme.primaryColor.withValues(alpha: 0.72),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: LwpRadii.lgAll,
          onTap: onOpenFeed,
          child: Padding(
            padding: const EdgeInsets.all(LwpSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: LwpSpacing.xs,
                  runSpacing: LwpSpacing.xs,
                  children: [
                    _WhitePillChip(
                      icon: Icons.dynamic_feed_outlined,
                      label: '$postCount plasings',
                    ),
                    _WhitePillChip(
                      icon: Icons.people_outline,
                      label: '${group.memberCount} lede',
                    ),
                    if (group.isLeader)
                      const _WhitePillChip(
                        icon: Icons.shield_outlined,
                        label: 'Leier kan plaas',
                      ),
                  ],
                ),
                const SizedBox(height: LwpSpacing.md),
                Text(
                  'Groepfeed',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: LwpSpacing.xs),
                Text(
                  'Maak die feed volskerm oop vir opdaterings, reaksies en beter interaksie.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: LwpSpacing.md),
                Row(
                  children: [
                    Text(
                      'Open Feed',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: LwpSpacing.xs),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
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

class _WhitePillChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _WhitePillChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: LwpSpacing.sm,
        vertical: LwpSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(LwpRadii.pill),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: LwpSpacing.xs),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MembershipSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<GroupMembership> memberships;
  final String emptyMessage;
  final Widget Function(GroupMembership membership) actionBuilder;

  const _MembershipSection({
    required this.title,
    required this.subtitle,
    required this.memberships,
    required this.emptyMessage,
    required this.actionBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(LwpSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: LwpSpacing.xs),
            Text(
              subtitle,
              style:
                  theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
            ),
            const SizedBox(height: LwpSpacing.md),
            if (memberships.isEmpty)
              LwpEmpty(message: emptyMessage)
            else
              Column(
                children: memberships
                    .map(
                      (membership) => Padding(
                        padding: const EdgeInsets.only(bottom: LwpSpacing.sm),
                        child: _MembershipTile(
                          membership: membership,
                          action: actionBuilder(membership),
                        ),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class _MembershipTile extends StatelessWidget {
  final GroupMembership membership;
  final Widget action;

  const _MembershipTile({
    required this.membership,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(LwpSpacing.md),
      decoration: BoxDecoration(
        borderRadius: LwpRadii.mdAll,
        color: theme.cardColor,
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? Colors.white12
              : LightColors.outline,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: theme.primaryColor.withValues(alpha: 0.12),
                child: Text(
                  _initials(membership),
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: LwpSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _displayName(membership),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if ((membership.email ?? '').isNotEmpty) ...[
                      const SizedBox(height: LwpSpacing.xxs),
                      Text(
                        membership.email!,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: theme.hintColor),
                      ),
                    ],
                    const SizedBox(height: LwpSpacing.xs),
                    Wrap(
                      spacing: LwpSpacing.xs,
                      runSpacing: LwpSpacing.xs,
                      children: [
                        _PillChip(
                          label: _membershipStatusLabel(membership.status),
                          backgroundColor:
                              _membershipStatusColor(membership.status)
                                  .withValues(alpha: 0.14),
                          foregroundColor:
                              _membershipStatusColor(membership.status),
                        ),
                        if (membership.requestedAt != null &&
                            membership.status == GroupMembershipStatus.pending)
                          _PillChip(
                            label:
                                'Versoek ${DateFormatter.formatDate(membership.requestedAt)}',
                            backgroundColor:
                                theme.hintColor.withValues(alpha: 0.14),
                            foregroundColor: theme.hintColor,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: LwpSpacing.sm),
          action,
        ],
      ),
    );
  }
}

class _CountCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;

  const _CountCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(LwpSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: theme.primaryColor),
            const SizedBox(height: LwpSpacing.sm),
            Text(
              '$value',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: LwpSpacing.xxs),
            Text(
              label,
              style:
                  theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
            ),
          ],
        ),
      ),
    );
  }
}

class _PillChip extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  const _PillChip({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: LwpSpacing.sm,
        vertical: LwpSpacing.xs,
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
          fontSize: 12,
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
              Text('Wysig Groep', style: theme.textTheme.titleLarge),
              const SizedBox(height: LwpSpacing.sm),
              Text(
                'Werk net die lidgerigte groepinligting op.',
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
                label: const Text('Kies Nuwe Banier'),
              ),
              const SizedBox(height: LwpSpacing.md),
              TextFormField(
                controller: _titleController,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Titel word benodig'
                    : null,
                decoration: const InputDecoration(
                  labelText: 'Titel',
                  prefixIcon: Icon(Icons.title),
                ),
              ),
              const SizedBox(height: LwpSpacing.md),
              TextFormField(
                controller: _descriptionController,
                minLines: 4,
                maxLines: 6,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Beskrywing word benodig'
                    : null,
                decoration: const InputDecoration(
                  labelText: 'Beskrywing',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
              ),
              const SizedBox(height: LwpSpacing.md),
              TextFormField(
                controller: _whatsappController,
                decoration: const InputDecoration(
                  labelText: 'WhatsApp Skakel',
                  prefixIcon: Icon(Icons.chat_bubble_outline),
                ),
              ),
              const SizedBox(height: LwpSpacing.md),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Ligging',
                  prefixIcon: Icon(Icons.location_on_outlined),
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
                    : const Text('Stoor Veranderinge'),
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
        LwpSnackbar.showError(context, 'Kon nie banier oplaai nie.');
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

String _membershipLabel(Group group) {
  switch (group.membershipStatus) {
    case 'pending':
      return 'Versoek Hangend';
    case 'active':
      return 'Lid';
    case 'declined':
      return 'Afgekeur';
    case 'left':
      return 'Verlaat';
    case 'removed':
      return 'Verwyder';
    default:
      return 'Publiek';
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

String _membershipStatusLabel(String status) {
  switch (status) {
    case GroupMembershipStatus.pending:
      return 'Hangend';
    case GroupMembershipStatus.active:
      return 'Aktief';
    case GroupMembershipStatus.declined:
      return 'Afgekeur';
    case GroupMembershipStatus.left:
      return 'Verlaat';
    case GroupMembershipStatus.removed:
      return 'Verwyder';
    default:
      return status;
  }
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

  return membership.email ?? 'Onbekende lid';
}

String _initials(GroupMembership membership) {
  final name = _displayName(membership);
  final parts = name.split(' ').where((part) => part.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
}
