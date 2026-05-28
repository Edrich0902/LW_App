import 'package:flutter/material.dart';
import 'package:lw_app/Models/YoutubeVideo/youtube_video.dart';
import 'package:lw_app/Themes/lwp_tokens.dart';
import 'package:lw_app/Widgets/LwpYoutubePlayer/lwp_youtube_player.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class SermonDetailPage extends StatelessWidget {
  final YoutubeVideo video;

  const SermonDetailPage({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preek Besonderhede'),
        actions: [
          if (video.youtubeLink != null)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () => _shareVideo(context),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LwpYoutubePlayer(
              youtubeLink: video.youtubeLink,
              thumbnailUrl: video.thumbnailUrl,
              onOpenExternal: _launchVideo,
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.customTitle ?? video.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.person, color: theme.primaryColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        video.customAuthor ?? video.authorName,
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.description,
                          color: theme.primaryColor, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          video.description ??
                              'Geen beskrywing beskikbaar nie.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _launchVideo(),
                      icon: const Icon(Icons.open_in_new),
                      label: const Text("Kyk op YouTube"),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: LwpRadii.lgAll,
                        ),
                      ),
                    ),
                  ),
                  const Divider(height: 64),
                  Text(
                    "Video Inligting",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildMetadataTile(
                    context,
                    Icons.business,
                    "Verskaffer",
                    video.providerName,
                  ),
                  if (video.youtubeLink != null) ...[
                    const Divider(height: 32),
                    _buildMetadataTile(
                      context,
                      Icons.link,
                      "Skakel",
                      video.youtubeLink!,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _launchVideo() {
    if (video.youtubeLink != null) {
      launchUrl(Uri.parse(video.youtubeLink!));
    }
  }

  void _shareVideo(BuildContext context) {
    if (video.youtubeLink != null) {
      final title = video.customTitle ?? video.title;
      final box = context.findRenderObject() as RenderBox?;
      Share.share(
        '$title\n${video.youtubeLink}',
        sharePositionOrigin:
            box != null ? box.localToGlobal(Offset.zero) & box.size : null,
      );
    }
  }

  Widget _buildMetadataTile(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: theme.primaryColor, size: 20),
      title: Text(label, style: theme.textTheme.bodyMedium),
      subtitle: Text(value, style: theme.textTheme.bodySmall),
    );
  }
}
