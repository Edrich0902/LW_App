import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Widgets/ProfileActionButton/profile_action_button.dart';
import 'package:lw_app/Widgets/WhatsappContactFAB/whatsapp_contact_fab.dart';
import 'package:lw_app/Models/Group/group.dart';
import 'package:lw_app/Blocs/ServiceGroups/service_groups_bloc.dart';
import 'package:lw_app/Widgets/LwpError/lwp_error.dart';
import 'package:lw_app/Widgets/LwpEmpty/lwp_empty.dart';
import 'package:lw_app/Widgets/LwpLoader/lwp_loader.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloudinary_flutter/image/cld_image.dart';
import 'package:lw_app/Widgets/LwpAnnouncement/lwp_announcement.dart';

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
    ServiceGroupsBloc serviceGroupsBloc = BlocProvider.of<ServiceGroupsBloc>(context);

    return BlocListener<ServiceGroupsBloc, ServiceGroupsState>(
      listener: (context, state) {
        // Listen to state updates and execute logic here
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Kom Dien'),
          actions: const <Widget>[LwpAnnouncementButton(), ProfileActionButton()],
        ),
        floatingActionButton: const WhatsappContactFAB(),
        body: SafeArea(
          child: BlocBuilder<ServiceGroupsBloc, ServiceGroupsState>(
            builder: (context, state) {
              if (state is ServiceGroupsLoading) {
                return const LwpLoader(message: "Laai Kom Dien Groepe");
              } else if (state is ServiceGroupsSuccess) {
                if (state.serviceGroups.isNotEmpty) {
                  return RefreshIndicator(
                    onRefresh: () async => serviceGroupsBloc.add(const LoadServiceGroups()),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: state.serviceGroups.length,
                      itemBuilder: (BuildContext context, int index) {
                        return _buildServiceGroupCard(state.serviceGroups[index], () => debugPrint("clicked"));
                      },
                    ),
                  );
                } else {
                  return const LwpEmpty(message: "Geen Kom Dien Groepe");
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

  Widget _buildServiceGroupCard(Group group, VoidCallback onTap) {
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
                        ElevatedButton(
                          onPressed: () => _openServeGroupWhatsapp(),
                          child: const Text("Join WhatsApp"),
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
  void _openServeGroupWhatsapp() {
    String link = "https://wa.me/+27727238406";
    launchUrl(Uri.parse(link), mode: LaunchMode.externalApplication);
  }
}