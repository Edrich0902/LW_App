import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Extensions/context_l10n.dart';
import 'package:lw_app/Widgets/Glass/lwp_chrome_scaffold.dart';
import 'package:lw_app/Widgets/WhatsappContactFAB/whatsapp_contact_fab.dart';
import 'package:lw_app/Blocs/ConnectGroups/connect_groups_bloc.dart';
import 'package:lw_app/Widgets/LwpError/lwp_error.dart';
import 'package:lw_app/Widgets/LwpEmpty/lwp_empty.dart';
import 'package:lw_app/Widgets/LwpSkeleton/lwp_skeleton.dart';
import 'package:lw_app/Widgets/Group/lwp_group_card.dart';
import 'package:lw_app/Widgets/LwpListEntrance/lwp_list_entrance.dart';

class ConnectGroupsPage extends StatefulWidget {
  const ConnectGroupsPage({super.key});

  @override
  State<ConnectGroupsPage> createState() => _ConnectGroupsPageState();
}

class _ConnectGroupsPageState extends State<ConnectGroupsPage> {
  final _listEntrance = LwpListEntranceController();

  @override
  void dispose() {
    _listEntrance.dispose();
    super.dispose();
  }

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
      child: LwpChromeScaffold(
        title: context.l10n.connectGroupsTitle,
        showDefaultActions: true,
        floatingActionButton: const WhatsappContactFAB(),
        body: BlocBuilder<ConnectGroupsBloc, ConnectGroupsState>(
            builder: (context, state) {
              if (state is ConnectGroupsLoading) {
                return LwpSkeletonList.group();
              } else if (state is ConnectGroupsSuccess) {
                if (state.connectGroups.isNotEmpty) {
                  return LwpListEntranceScope(
                    controller: _listEntrance,
                    child: RefreshIndicator(
                      onRefresh: () async {
                        _listEntrance.bump();
                        connectGroupsBloc.add(const LoadConnectGroups());
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: state.connectGroups.length,
                        itemBuilder: (BuildContext context, int index) {
                          final group = state.connectGroups[index];
                          return LwpListEntrance(
                            id: group.id ?? 'connect-$index',
                            child: LwpGroupCard(group: group),
                          );
                        },
                      ),
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
    );
  }
}
