import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Extensions/context_l10n.dart';
import 'package:lw_app/Blocs/MyGroups/my_groups_bloc.dart';
import 'package:lw_app/Screens/GroupDetail/group_detail.dart';
import 'package:lw_app/Widgets/Group/lwp_group_card.dart';
import 'package:lw_app/Widgets/LwpEmpty/lwp_empty.dart';
import 'package:lw_app/Widgets/LwpError/lwp_error.dart';
import 'package:lw_app/Widgets/LwpLoader/lwp_loader.dart';
import 'package:lw_app/Widgets/LwpAnnouncement/lwp_announcement.dart';
import 'package:lw_app/Widgets/ProfileActionButton/profile_action_button.dart';
import 'package:lw_app/Widgets/WhatsappContactFAB/whatsapp_contact_fab.dart';
import 'package:lw_app/Themes/lwp_tokens.dart';

class MyGroupsPage extends StatelessWidget {
  const MyGroupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MyGroupsBloc()..add(const LoadMyGroups()),
      child: const _MyGroupsView(),
    );
  }
}

class _MyGroupsView extends StatelessWidget {
  const _MyGroupsView();

  @override
  Widget build(BuildContext context) {
    final myGroupsBloc = context.read<MyGroupsBloc>();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.myGroupsTitle),
        actions: const <Widget>[LwpAnnouncementButton(), ProfileActionButton()],
      ),
      floatingActionButton: const WhatsappContactFAB(),
      body: SafeArea(
        child: BlocBuilder<MyGroupsBloc, MyGroupsState>(
          builder: (context, state) {
            if (state.status == MyGroupsStatus.loading && !state.isRefreshing) {
              return LwpLoader(message: context.l10n.myGroupsLoading);
            }

            if (state.status == MyGroupsStatus.error) {
              return LwpError(
                message: state.error ?? context.l10n.myGroupsLoadError,
                onRetry: () =>
                    context.read<MyGroupsBloc>().add(const LoadMyGroups()),
              );
            }

            if (!state.hasGroups) {
              return LwpEmpty(message: context.l10n.myGroupsEmpty);
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<MyGroupsBloc>().add(const RefreshMyGroups());
              },
              child: ListView(
                padding: const EdgeInsets.all(LwpSpacing.md),
                children: [
                  if (state.activeGroups.isNotEmpty) ...[
                    _SectionHeader(
                      title: context.l10n.myGroupsActiveSectionTitle,
                      subtitle: context.l10n.myGroupsActiveSectionSubtitle,
                    ),
                    const SizedBox(height: LwpSpacing.sm),
                    ...state.activeGroups.map(
                      (group) => LwpGroupCard(
                        group: group,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                GroupDetailPage(groupId: group.id ?? ''),
                          ),
                        ).then((_) {
                          myGroupsBloc.add(const RefreshMyGroups());
                        }),
                      ),
                    ),
                    const SizedBox(height: LwpSpacing.lg),
                  ],
                  if (state.pendingGroups.isNotEmpty) ...[
                    _SectionHeader(
                      title: context.l10n.myGroupsPendingSectionTitle,
                      subtitle: context.l10n.myGroupsPendingSectionSubtitle,
                    ),
                    const SizedBox(height: LwpSpacing.sm),
                    ...state.pendingGroups.map(
                      (group) => LwpGroupCard(
                        group: group,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                GroupDetailPage(groupId: group.id ?? ''),
                          ),
                        ).then((_) {
                          myGroupsBloc.add(const RefreshMyGroups());
                        }),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: LwpSpacing.xxs),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
        ),
      ],
    );
  }
}
