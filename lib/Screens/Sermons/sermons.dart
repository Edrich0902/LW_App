import 'package:flutter/material.dart';
import 'package:lw_app/Models/YoutubeVideo/youtube_video.dart';
import 'package:lw_app/Services/Youtube/youtube_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lw_app/Widgets/LwpBanner/lwp_banner.dart';

class SermonsPage extends StatefulWidget {
  const SermonsPage({super.key});

  @override
  State<SermonsPage> createState() => _SermonsPageState();
}

class _SermonsPageState extends State<SermonsPage> {
  late Future<List<YoutubeVideo>> videos;
  
  @override
  void initState() {
    super.initState();
    final youtubeService = YoutubeService();
    
    videos = youtubeService.fetchLatestSermons(recentVideos);
  }

  // TODO: make this configurable on admin screen
  final List<String> recentVideos = [
    'https://www.youtube.com/watch?v=nx8wQEBzRMw',
    'https://www.youtube.com/watch?v=Xca6EKFjwL8&pp=ygUTbGV3ZW5kZSB3b29yZCBwYWFybA%3D%3D',
    'https://www.youtube.com/watch?v=THp3CoqiyI0&t=396s&pp=ygUTbGV3ZW5kZSB3b29yZCBwYWFybA%3D%3D',
    'https://www.youtube.com/watch?v=tNyC25KXsO4&pp=ygUTbGV3ZW5kZSB3b29yZCBwYWFybA%3D%3D',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Preke'),
      ),
      body: SafeArea(
        child: FutureBuilder<List<YoutubeVideo>>(
          future: videos,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                padding: EdgeInsets.all(8),
                itemCount: snapshot.data!.length,
                itemBuilder: (BuildContext context, int index) {
                  return _buildVideoCard(snapshot.data![index], () {
                    launchUrl(Uri.parse(recentVideos[index]));
                  });
                },
              );
            } else if (snapshot.hasError) {
              print("Error: ${snapshot.error}");
              return Text("Error loading videos");
            }
            return Center(
              child: const CircularProgressIndicator(),
            );
          },
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
