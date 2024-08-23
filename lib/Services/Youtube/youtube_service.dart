import 'package:http/http.dart' as http;
import 'package:lw_app/Models/YoutubeVideo/youtube_video.dart';
import 'dart:convert';

class YoutubeService {
  Future<List<YoutubeVideo>> fetchLatestSermons(List<String?> sermonLinks) async {
    List<YoutubeVideo> videoData = [];

    for (String? sermon in sermonLinks) {
      String url = "https://www.youtube.com/oembed?url=${sermon}&format=json";
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        YoutubeVideo video = YoutubeVideo.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
        video.youtubeLink = sermon;
        videoData.add(video);
      } else print("Failed to fetch video (${sermon})");
    }

    return videoData;
  }
}