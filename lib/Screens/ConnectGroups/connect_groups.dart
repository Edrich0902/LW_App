import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Extensions/context_l10n.dart';
import 'package:lw_app/Widgets/ProfileActionButton/profile_action_button.dart';
import 'package:lw_app/Widgets/WhatsappContactFAB/whatsapp_contact_fab.dart';
import 'package:lw_app/Blocs/ConnectGroups/connect_groups_bloc.dart';
import 'package:lw_app/Widgets/LwpError/lwp_error.dart';
import 'package:lw_app/Widgets/LwpEmpty/lwp_empty.dart';
import 'package:lw_app/Widgets/LwpLoader/lwp_loader.dart';
import 'package:lw_app/Widgets/LwpAnnouncement/lwp_announcement.dart';
import 'package:lw_app/Widgets/Group/lwp_group_card.dart';

class ConnectGroupsPage extends StatefulWidget {
  const ConnectGroupsPage({super.key});

  @override
  State<ConnectGroupsPage> createState() => _ConnectGroupsPageState();
}

class _ConnectGroupsPageState extends State<ConnectGroupsPage> {
  @override
  void initState() {
    context.read<ConnectGroupsBloc>().add(const LoadConnectGroups());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ConnectGroupsBloc connectGroupsBloc =
        BlocProvider.of<ConnectGroupsBloc>(context);

    return BlocListener<ConnectGroupsBloc, ConnectGroupsState>(
      listener: (context, state) {
        // Listen to state updates and execute logic here
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.connectGroupsTitle),
          actions: const <Widget>[
            LwpAnnouncementButton(),
            ProfileActionButton()
          ],
        ),
        floatingActionButton: const WhatsappContactFAB(),
        body: SafeArea(
          child: BlocBuilder<ConnectGroupsBloc, ConnectGroupsState>(
            builder: (context, state) {
              if (state is ConnectGroupsLoading) {
                return LwpLoader(message: context.l10n.connectGroupsLoading);
              } else if (state is ConnectGroupsSuccess) {
                if (state.connectGroups.isNotEmpty) {
                  return RefreshIndicator(
                    onRefresh: () async =>
                        connectGroupsBloc.add(const LoadConnectGroups()),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: state.connectGroups.length,
                      itemBuilder: (BuildContext context, int index) {
                        return LwpGroupCard(group: state.connectGroups[index]);
                      },
                    ),
                  );
                } else {
                  return LwpEmpty(message: context.l10n.connectGroupsEmpty);
                }
              } else if (state is ConnectGroupsError) {
                return LwpError(message: state.error);
              } else {
                return const LwpError();
              }
            },
          ),
        ),
      ),
    );
  }
}
