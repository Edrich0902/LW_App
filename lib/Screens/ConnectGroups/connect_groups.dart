import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Widgets/ProfileActionButton/profile_action_button.dart';
import 'package:lw_app/Widgets/WhatsappContactFAB/whatsapp_contact_fab.dart';
import 'package:lw_app/Models/Group/group.dart';
import 'package:lw_app/Blocs/ConnectGroups/connect_groups_bloc.dart';
import 'package:lw_app/Widgets/LwpError/lwp_error.dart';
import 'package:lw_app/Widgets/LwpEmpty/lwp_empty.dart';
import 'package:lw_app/Widgets/LwpLoader/lwp_loader.dart';
import 'package:lw_app/Utils/maps_helper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloudinary_flutter/image/cld_image.dart';
import 'package:lw_app/Widgets/LwpAnnouncement/lwp_announcement.dart';

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
          actions: const <Widget>[LwpAnnouncementButton(), ProfileActionButton()],
        ),
        floatingActionButton: const WhatsappContactFAB(),
        body: SafeArea(
          child: BlocBuilder<ConnectGroupsBloc, ConnectGroupsState>(
            builder: (context, state) {
              if (state is ConnectGroupsLoading) {
                return const LwpLoader(message: "Laai Konneksie Groepe");
              } else if (state is ConnectGroupsSuccess) {
                if (state.connectGroups.isNotEmpty) {
                  return RefreshIndicator(
                    onRefresh: () async => connectGroupsBloc.add(const LoadConnectGroups()),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: state.connectGroups.length,
                      itemBuilder: (BuildContext context, int index) {
                        return _buildConnectGroupCard(state.connectGroups[index], () => debugPrint("clicked"));
                      },
                    ),
                  );
                } else {
                  return const LwpEmpty(message: "Geen Konneksie Groepe");
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

  Widget _buildConnectGroupCard(Group group, VoidCallback onTap) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: InkWell(
        onTap: onTap, // TODO: check if this is necessary
        child: Column(
          children: <Widget>[
            CldImageWidget(
                publicId: group.bannerPublicId ?? 'samples/cloudinary-icon',
                fit: BoxFit.fill
            ),
            Padding(
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
                          onPressed: () => MapsHelper.openLocation(group.location),
                          icon: const Icon(Icons.location_on_outlined),
                        ),
                        ElevatedButton(
                          onPressed: () => _openConnectGroupWhatsapp(),
                          child: const Text("Sluit aan op WhatsApp"),
                        )
                      ],
                    ),
                  ],
                )
            ),
          ],
        ),
      ),
    );
  }

  // TODO: get community link to open community from app
  void _openConnectGroupWhatsapp() {
    String link = "https://wa.me/+27727238406";
    launchUrl(Uri.parse(link), mode: LaunchMode.externalApplication);
  }
}