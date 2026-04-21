import 'package:flutter/material.dart';
import 'package:lw_app/Models/YoutubeVideo/youtube_video.dart';
import 'package:lw_app/Widgets/LwpBanner/lwp_banner.dart';
import 'package:lw_app/Widgets/ProfileActionButton/profile_action_button.dart';
import 'package:lw_app/Blocs/Sermons/sermons_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Widgets/LwpError/lwp_error.dart';
import 'package:lw_app/Widgets/LwpEmpty/lwp_empty.dart';
import 'package:lw_app/Widgets/LwpLoader/lwp_loader.dart';
import 'package:lw_app/Widgets/LwpAnnouncement/lwp_announcement.dart';
import 'package:lw_app/Screens/Sermons/sermon_detail.dart';

class SermonsPage extends StatefulWidget {
  const SermonsPage({super.key});

  @override
  State<SermonsPage> createState() => _SermonsPageState();
}

class _SermonsPageState extends State<SermonsPage> {
  @override
  void initState() {
    context.read<SermonsBloc>().add(const LoadSermons());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SermonsBloc sermonsBloc = BlocProvider.of<SermonsBloc>(context);

    return BlocListener<SermonsBloc, SermonsState>(
      listener: (context, state) {
        // Listen to state updates and execute logic here
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Preke'),
          actions: const <Widget>[LwpAnnouncementButton(), ProfileActionButton()],
        ),
        body: SafeArea(
          child: BlocBuilder<SermonsBloc, SermonsState>(
            builder: (context, state) {
              if (state is SermonsLoading) {
                return const LwpLoader(message: "Laai Preke");
              } else if (state is SermonsSuccess) {
                if (state.youtubeVideos.isNotEmpty) {
                  return RefreshIndicator(
                    onRefresh: () async => sermonsBloc.add(const LoadSermons()),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: state.youtubeVideos.length,
                      itemBuilder: (BuildContext context, int index) {
                        return _buildVideoCard(state.youtubeVideos[index], () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SermonDetailPage(video: state.youtubeVideos[index]),
                            ),
                          );
                        });
                      },
                    ),
                  );
                } else {
                  return const LwpEmpty(message: "Geen Preke Beskikbaar");
                }
              } else {
                return const LwpError();
              }
            }
          ),
        ),
      ),
    );
  }

  Widget _buildVideoCard(YoutubeVideo video, VoidCallback onTap) {
    return LwpBanner(
      imageUrl: video.thumbnailUrl,
      onTap: onTap,
    );
  }
}
