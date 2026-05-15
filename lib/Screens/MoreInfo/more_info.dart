import 'package:lw_app/Widgets/LwpSnackbar/lwp_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Blocs/MoreInfo/more_info_bloc.dart';
import 'package:lw_app/Models/MetaData/meta_data.dart' as lw;
import 'package:lw_app/Widgets/WhatsappContactFAB/whatsapp_contact_fab.dart';
import 'package:lw_app/Widgets/ProfileActionButton/profile_action_button.dart';
import 'package:lw_app/Widgets/LwpBio/lwp_bio.dart';
import 'package:lw_app/Widgets/LwpError/lwp_error.dart';
import 'package:lw_app/Widgets/LwpLoader/lwp_loader.dart';
import 'package:lw_app/Widgets/LwpAnnouncement/lwp_announcement.dart';

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
    return BlocBuilder<MoreInfoBloc, MoreInfoState>(
      builder: (context, state) {
        if (state is MoreInfoLoading) {
          return const Scaffold(body: LwpLoader());
        } else if (state is MoreInfoSuccess) {
          return Scaffold(
            floatingActionButton: const WhatsappContactFAB(),
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 120.0,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      'Meer Oor Ons',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).primaryColor,
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
                      _buildSectionHeader(context, 'Ons Gemeente'),
                      ...state.data.map((item) => _createDataItem(data: item)),
                      const SizedBox(height: 24.0),
                      _buildSectionHeader(context, 'Ons Span'),
                    ]),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final roleplayer = state.roleplayers[index];
                        return LwpBio(
                          name: roleplayer.fullname ?? '',
                          title: roleplayer.title ?? '',
                          bio: roleplayer.bio ?? '',
                          publicId: roleplayer.profilePublicId ?? '',
                          onTap: () {
                            // Future: navigate to roleplayer detail
                            LwpSnackbar.showInfo(
                              context,
                              'Binnekort: Meer oor ${roleplayer.fullname}',
                            );
                          },
                        );
                      },
                      childCount: state.roleplayers.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 80.0), // Padding for FAB
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
              color: Theme.of(context).primaryColor,
            ),
      ),
    );
  }

  Widget _createDataItem({required lw.MetaData data}) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 0.0),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            data.title ?? '',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          childrenPadding: const EdgeInsets.all(16.0),
          expandedAlignment: Alignment.centerLeft,
          children: <Widget>[
            Text(
              data.content ?? '',
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.5,
              ),
            )
          ],
        ),
      ),
    );
  }
}
