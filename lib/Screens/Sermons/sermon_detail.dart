import 'package:flutter/material.dart';
import 'package:lw_app/Models/YoutubeVideo/youtube_video.dart';
import 'package:lw_app/Widgets/LwpBanner/lwp_banner.dart';
import 'package:url_launcher/url_launcher.dart';

class SermonDetailPage extends StatelessWidget {
  final YoutubeVideo video;

  const SermonDetailPage({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preek Besonderhede'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LwpBanner(
              imageUrl: video.thumbnail_url,
              onTap: () => _launchVideo(),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.custom_title ?? 'N/A',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.person, color: theme.primaryColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        video.custom_author ?? 'N/A',
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.description, color: theme.primaryColor, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          video.description ?? '',
                          style: theme.textTheme.bodyMedium,
                          maxLines: 4,
                          overflow: TextOverflow.fade,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _launchVideo(),
                      icon: const Icon(Icons.play_circle_fill),
                      label: const Text("Kyk op YouTube"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Colors.red
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    "Video Inligting",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(),
                  _buildMetadataTile(
                    context,
                    Icons.business,
                    "Verskaffer",
                    video.provider_name,
                  ),
                  if (video.youtubeLink != null)
                    _buildMetadataTile(
                      context,
                      Icons.link,
                      "Skakel",
                      video.youtubeLink!,
                    ),
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
      title: Text(
        label,
        style: theme.textTheme.bodyMedium
      ),
      subtitle: Text(
        value,
        style: theme.textTheme.bodySmall
      ),
    );
  }
}
