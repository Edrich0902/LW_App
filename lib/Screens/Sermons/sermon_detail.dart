import 'package:flutter/material.dart';
import 'package:lw_app/Models/YoutubeVideo/youtube_video.dart';
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
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                video.thumbnailUrl,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
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
                      Icon(Icons.description, color: theme.primaryColor, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          video.description ?? 'Geen beskrywing beskikbaar nie.',
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
                    child: ElevatedButton.icon(
                      onPressed: () => _launchVideo(),
                      icon: const Icon(Icons.play_circle_fill),
                      label: const Text("Kyk op YouTube"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.0),
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
