import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Widgets/ProfileActionButton/profile_action_button.dart';
import 'package:lw_app/Widgets/WhatsappContactFAB/whatsapp_contact_fab.dart';
import 'package:lw_app/Models/Group/group.dart';
import 'package:lw_app/Blocs/ConnectGroups/connect_groups_bloc.dart';

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
    ConnectGroupsBloc connectGroupsBloc = BlocProvider.of<ConnectGroupsBloc>(context);

    return BlocListener<ConnectGroupsBloc, ConnectGroupsState>(
      listener: (context, state) {
        // Listen to state updates and execute logic here
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Konneksie Groepe'),
          actions: const <Widget>[ProfileActionButton()],
        ),
        floatingActionButton: const WhatsappContactFAB(),
        body: SafeArea(
          child: BlocBuilder<ConnectGroupsBloc, ConnectGroupsState>(
            builder: (context, state) {
              if (state is ConnectGroupsLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (state is ConnectGroupsSuccess) {
                if (state.connectGroups.isNotEmpty) {
                  return RefreshIndicator(
                    onRefresh: () async => connectGroupsBloc.add(const LoadConnectGroups()),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: state.connectGroups.length,
                      itemBuilder: (BuildContext context, int index) {
                        return _buildConnectGroupCard(state.connectGroups[index], () => print("clicked"));
                      },
                    ),
                  );
                } else {
                  return const Center(
                    child: Text("Geen Konneksie Groepe"),
                  );
                }
              } else {
                return const Center(
                  child: Text("Something went wrong!"),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildConnectGroupCard(Group group, VoidCallback onTap) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onTap, // TODO: check if this is necessary
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.group),
                title: Text(
                  group.title,
                  style: theme.textTheme.titleMedium,
                ),
                subtitle: Text(
                  group.description,
                  style: theme.textTheme.titleSmall,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  IconButton(
                    onPressed: () => print("clicked"), // TODO: link to google maps location
                    icon: const Icon(Icons.location_on_outlined),
                  ),
                  ElevatedButton(
                    onPressed: () => print("clicked"), // TODO: link to whatsapp group - prevent auto join?
                    child: const Text("Join WhatsApp"),
                  )
                ],
              ),
            ],
          )
        ),
      ),
    );
  }
}