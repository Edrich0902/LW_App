import 'package:lw_app/Screens/MoreInfo/roleplayer_detail.dart';
import 'package:lw_app/Widgets/LwpBio/roleplayer_grid_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Extensions/context_l10n.dart';
import 'package:lw_app/Blocs/MoreInfo/more_info_bloc.dart';
import 'package:lw_app/Widgets/ProfileActionButton/profile_action_button.dart';
import 'package:lw_app/Widgets/LwpError/lwp_error.dart';
import 'package:lw_app/Widgets/LwpLoader/lwp_loader.dart';
import 'package:lw_app/Widgets/LwpAnnouncement/lwp_announcement.dart';
import 'package:collection/collection.dart';

class MoreInfoPage extends StatefulWidget {
  const MoreInfoPage({super.key});

  @override
  State<MoreInfoPage> createState() => _MoreInfoPageState();
}

class _MoreInfoPageState extends State<MoreInfoPage> {
  @override
  void initState() {
    context.read<MoreInfoBloc>().add(const LoadMoreInfo());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<MoreInfoBloc, MoreInfoState>(
      builder: (context, state) {
        if (state is MoreInfoLoading) {
          return const Scaffold(body: LwpLoader());
        } else if (state is MoreInfoSuccess) {
          final mission =
              state.data.firstWhereOrNull((m) => m.key == 'mission_statement');
          final vision =
              state.data.firstWhereOrNull((v) => v.key == 'vision_statement');

          return Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 120.0,
                  floating: false,
                  pinned: true,
                  scrolledUnderElevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      context.l10n.navMoreInfo,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    centerTitle: false,
                    titlePadding: const EdgeInsetsDirectional.only(
                      start: 16,
                      bottom: 16,
                    ),
                  ),
                  actions: const <Widget>[
                    LwpAnnouncementButton(),
                    ProfileActionButton()
                  ],
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      if (mission != null) ...[
                        _buildSectionHeader(
                            context, context.l10n.moreInfoMission),
                        _buildSectionContent(context, mission.content ?? ''),
                        const SizedBox(height: 24.0),
                      ],
                      if (vision != null) ...[
                        _buildSectionHeader(
                            context, context.l10n.moreInfoVision),
                        _buildSectionContent(context, vision.content ?? ''),
                        const SizedBox(height: 32.0),
                      ],
                      _buildSectionHeader(context, context.l10n.moreInfoTeam),
                    ]),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16.0,
                      crossAxisSpacing: 16.0,
                      childAspectRatio: 0.85,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final roleplayer = state.roleplayers[index];
                        return RoleplayerGridCard(
                          roleplayer: roleplayer,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RoleplayerDetailScreen(
                                  roleplayer: roleplayer,
                                ),
                              ),
                            );
                          },
                        );
                      },
                      childCount: state.roleplayers.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100.0), // Padding for FAB
                ),
              ],
            ),
          );
        } else {
          return const Scaffold(body: LwpError());
        }
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 4.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildSectionContent(BuildContext context, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Text(
        content,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.6,
              color: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.color
                  ?.withValues(alpha: 0.8),
            ),
      ),
    );
  }
}
