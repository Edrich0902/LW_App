import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Extensions/context_l10n.dart';
import 'package:lw_app/Widgets/Glass/lwp_chrome_scaffold.dart';
import 'package:lw_app/Widgets/WhatsappContactFAB/whatsapp_contact_fab.dart';
import 'package:lw_app/Blocs/ServiceGroups/service_groups_bloc.dart';
import 'package:lw_app/Widgets/LwpError/lwp_error.dart';
import 'package:lw_app/Widgets/LwpEmpty/lwp_empty.dart';
import 'package:lw_app/Widgets/LwpSkeleton/lwp_skeleton.dart';
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
      child: LwpChromeScaffold(
        title: context.l10n.serveGroupsTitle,
        showDefaultActions: true,
        floatingActionButton: const WhatsappContactFAB(),
        body: BlocBuilder<ServiceGroupsBloc, ServiceGroupsState>(
            builder: (context, state) {
              if (state is ServiceGroupsLoading) {
                return LwpSkeletonList.group();
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
    );
  }
}
