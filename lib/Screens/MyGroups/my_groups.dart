import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
        title: const Text('My Groepe'),
        actions: const <Widget>[LwpAnnouncementButton(), ProfileActionButton()],
      ),
      floatingActionButton: const WhatsappContactFAB(),
      body: SafeArea(
        child: BlocBuilder<MyGroupsBloc, MyGroupsState>(
          builder: (context, state) {
            if (state.status == MyGroupsStatus.loading && !state.isRefreshing) {
              return const LwpLoader(message: 'Laai my groepe...');
            }

            if (state.status == MyGroupsStatus.error) {
              return LwpError(
                message: state.error ?? 'Kon nie my groepe laai nie.',
                onRetry: () =>
                    context.read<MyGroupsBloc>().add(const LoadMyGroups()),
              );
            }

            if (!state.hasGroups) {
              return const LwpEmpty(message: 'Jy het nog geen groepe nie');
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<MyGroupsBloc>().add(const RefreshMyGroups());
              },
              child: ListView(
                padding: const EdgeInsets.all(LwpSpacing.md),
                children: [
                  if (state.activeGroups.isNotEmpty) ...[
                    const _SectionHeader(
                      title: 'Aktiewe Groepe',
                      subtitle: 'Groepe waarvan jy tans deel is.',
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
                    const _SectionHeader(
                      title: 'Hangende Versoeke',
                      subtitle: 'Aansluitings wat nog op goedkeuring wag.',
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
