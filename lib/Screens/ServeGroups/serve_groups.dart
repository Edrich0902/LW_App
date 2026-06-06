import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Extensions/context_l10n.dart';
import 'package:lw_app/Widgets/ProfileActionButton/profile_action_button.dart';
import 'package:lw_app/Widgets/WhatsappContactFAB/whatsapp_contact_fab.dart';
import 'package:lw_app/Blocs/ServiceGroups/service_groups_bloc.dart';
import 'package:lw_app/Widgets/LwpError/lwp_error.dart';
import 'package:lw_app/Widgets/LwpEmpty/lwp_empty.dart';
import 'package:lw_app/Widgets/LwpLoader/lwp_loader.dart';
import 'package:lw_app/Widgets/LwpAnnouncement/lwp_announcement.dart';
import 'package:lw_app/Widgets/Group/lwp_group_card.dart';

class ServeGroupsPage extends StatefulWidget {
  const ServeGroupsPage({super.key});

  @override
  State<ServeGroupsPage> createState() => _ServeGroupsPageState();
}

class _ServeGroupsPageState extends State<ServeGroupsPage> {
  @override
  void initState() {
    context.read<ServiceGroupsBloc>().add(const LoadServiceGroups());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ServiceGroupsBloc serviceGroupsBloc =
        BlocProvider.of<ServiceGroupsBloc>(context);

    return BlocListener<ServiceGroupsBloc, ServiceGroupsState>(
      listener: (context, state) {
        // Listen to state updates and execute logic here
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.serveGroupsTitle),
          actions: const <Widget>[
            LwpAnnouncementButton(),
            ProfileActionButton()
          ],
        ),
        floatingActionButton: const WhatsappContactFAB(),
        body: SafeArea(
          child: BlocBuilder<ServiceGroupsBloc, ServiceGroupsState>(
            builder: (context, state) {
              if (state is ServiceGroupsLoading) {
                return LwpLoader(message: context.l10n.serveGroupsLoading);
              } else if (state is ServiceGroupsSuccess) {
                if (state.serviceGroups.isNotEmpty) {
                  return RefreshIndicator(
                    onRefresh: () async =>
                        serviceGroupsBloc.add(const LoadServiceGroups()),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: state.serviceGroups.length,
                      itemBuilder: (BuildContext context, int index) {
                        return LwpGroupCard(group: state.serviceGroups[index]);
                      },
                    ),
                  );
                } else {
                  return LwpEmpty(message: context.l10n.serveGroupsEmpty);
                }
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
