import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:lw_app/Models/Sermon/sermon.dart';
import 'package:lw_app/Models/YoutubeVideo/youtube_video.dart';
import 'dart:convert';

class YoutubeService {
  Future<List<YoutubeVideo>> fetchLatestSermons(List<Sermon> sermons) async {
    List<YoutubeVideo> videoData = [];

    for (Sermon sermon in sermons) {
      String url = "https://www.youtube.com/oembed?url=${sermon.link}&format=json";
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        YoutubeVideo video = YoutubeVideo.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
        video.youtubeLink = sermon.link;
        video.description = sermon.description;
        video.customAuthor = sermon.pastor;
        video.customTitle = sermon.title;
        videoData.add(video);
      } else {
        debugPrint("Failed to fetch video ($sermon)");
      }
    }

    return videoData;
  }
}