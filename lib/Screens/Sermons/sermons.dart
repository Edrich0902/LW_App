import 'package:flutter/material.dart';
import 'package:lw_app/Models/YoutubeVideo/youtube_video.dart';
import 'package:lw_app/Services/Youtube/youtube_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lw_app/Widgets/LwpBanner/lwp_banner.dart';
import 'package:lw_app/Widgets/ProfileActionButton/profile_action_button.dart';
import 'package:lw_app/Blocs/Sermons/sermons_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Utils/snackbar.dart';

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
          title: Text('Preke'),
          actions: <Widget>[ProfileActionButton()],
        ),
        body: SafeArea(
          child: BlocBuilder<SermonsBloc, SermonsState>(
            builder: (context, state) {
              if (state is SermonsLoading) {
                return const Center(
                  child: const CircularProgressIndicator(),
                );
              } else if (state is SermonsSuccess) {
                if (state.youtubeVideos.isNotEmpty) {
                  return RefreshIndicator(
                    onRefresh: () async => sermonsBloc.add(LoadSermons()),
                    child: ListView.builder(
                      padding: EdgeInsets.all(8.0),
                      itemCount: state.youtubeVideos.length,
                      itemBuilder: (BuildContext context, int index) {
                        return _buildVideoCard(state.youtubeVideos[index], () {
                          launchUrl(Uri.parse(state.youtubeVideos[index].youtubeLink ?? ''));
                        });
                      },
                    ),
                  );
                } else {
                  return const Center(
                    // TODO: create generic empty list screen
                    child: const Text("Geen Preke Beskikbaar"),
                  );
                }
              } else {
                return const Center(
                  // TODO: create generic fallback error screen
                  child: const Text("Something went wrong!"),
                );
              }
            }
          ),
        ),
      ),
    );
  }

  Widget _buildVideoCard(YoutubeVideo video, VoidCallback onTap) {
    return LwpBanner(
      imageUrl: video.thumbnail_url,
      onTap: onTap,
    );
  }
}
