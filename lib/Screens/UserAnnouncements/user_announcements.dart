import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Widgets/LwpError/lwp_error.dart';
import 'package:lw_app/Widgets/LwpLoader/lwp_loader.dart';
import 'package:lw_app/Widgets/LwpEmpty/lwp_empty.dart';
import 'package:lw_app/Blocs/UserAnnouncements/user_announcement_bloc.dart';
import 'package:lw_app/Models/UserAnnouncement/user_announcement.dart';
import 'package:cloudinary_flutter/image/cld_image.dart';

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
              if (state is UserAnnouncementSuccess) {
                if (state.userAnnouncements.isNotEmpty) {
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    itemCount: state.userAnnouncements.length,
                    itemBuilder: (context, index) {
                      final announcement = state.userAnnouncements[index];
                      return Dismissible(
                        key: Key(announcement.id ?? index.toString()),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) {
                          context.read<UserAnnouncementBloc>().add(DismissUserAnnouncement(announcement.id!));
                        },
                        background: Container(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withAlpha(50),
                            borderRadius: BorderRadius.circular(24.0),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20.0),
                          child: Icon(
                            Icons.check_circle_outline,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        child: _createAnnouncementItem(announcement),
                      );
                    },
                  );
                } else {
                  return const LwpEmpty(message: "Geen Aankondigings");
                }
              } else if (state is UserAnnouncementError) {
                return const LwpError();
              } else {
                return const LwpLoader(message: "Laai Aankondigings");
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _createAnnouncementItem(UserAnnouncement announcement) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
          side: BorderSide(
            color: theme.dividerColor.withAlpha(50),
            width: 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(24.0),
          onTap: () => _showAnnouncementDetails(context, announcement),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(16.0),
                  child: CldImageWidget(
                    publicId: announcement.imagePublicId ?? 'samples/cloudinary-icon',
                    fit: BoxFit.cover,
                    width: 80,
                    height: 80,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        announcement.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        announcement.body,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodyMedium?.color?.withAlpha(200),
                        ),
                        maxLines: 3,
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
      ),
    );
  }

  void _showAnnouncementDetails(BuildContext context, UserAnnouncement announcement) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: theme.dividerColor.withAlpha(50),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            if (announcement.imagePublicId != null)
              Container(
                width: double.infinity,
                height: 250,
                margin: const EdgeInsets.all(16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: CldImageWidget(
                    publicId: announcement.imagePublicId!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text(
                announcement.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text(
                announcement.body,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.textTheme.bodyLarge?.color?.withAlpha(200),
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}