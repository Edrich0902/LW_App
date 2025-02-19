import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Widgets/LwpError/lwp_error.dart';
import 'package:lw_app/Widgets/LwpLoader/lwp_loader.dart';
import 'package:lw_app/Widgets/LwpEmpty/lwp_empty.dart';
import 'package:lw_app/Blocs/UserAnnouncements/user_announcement_bloc.dart';
import 'package:lw_app/Models/UserAnnouncement/user_announcement.dart';
import 'package:cloudinary_flutter/image/cld_image.dart';
import 'package:cloudinary_url_gen/transformation/transformation.dart';
import 'package:cloudinary_url_gen/transformation/transformation_utils.dart';

class UserAnnouncementsPage extends StatefulWidget {
  const UserAnnouncementsPage({super.key});

  @override
  State<UserAnnouncementsPage> createState() => _UserAnnouncementsPageState();
}

class _UserAnnouncementsPageState extends State<UserAnnouncementsPage> {
  @override
  void initState() {
    context.read<UserAnnouncementBloc>().add(const LoadUserAnnouncements());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    UserAnnouncementBloc userAnnouncementBloc = BlocProvider.of<UserAnnouncementBloc>(context);

    return BlocListener<UserAnnouncementBloc, UserAnnouncementState>(
      listener: (context, state) {
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Aankondigings'),
        ),
        body: SafeArea(
          child: BlocBuilder<UserAnnouncementBloc, UserAnnouncementState>(
            builder: (context, state) {
              if (state is UserAnnouncementLoading) {
                return const LwpLoader(message: "Laai Aankondigings");
              } else if (state is UserAnnouncementSuccess) {
                if (state.userAnnouncements.isNotEmpty) {
                  userAnnouncementBloc.add(ReadUserAnnouncements()); // On view mark list of announcements as read
                  return ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: state.userAnnouncements.length,
                    itemBuilder: (context, index) {
                      return _createAnnouncementItem(state.userAnnouncements.elementAt(index));
                    },
                  );
                } else {
                  return const LwpEmpty(message: "Geen Aankondigings");
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

  Widget _createAnnouncementItem(UserAnnouncement announcement) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: () {}, //TODO: check if needed to implement
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: CldImageWidget(
                  publicId: announcement.imagePublicId ?? 'samples/cloudinary-icon',
                  fit: BoxFit.contain,
                  width: 100,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      announcement.title,
                      style: theme.textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      announcement.body,
                      style: theme.textTheme.bodyMedium,
                      maxLines: 2,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}