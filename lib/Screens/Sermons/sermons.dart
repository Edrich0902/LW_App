import 'package:flutter/material.dart';
import 'package:lw_app/Extensions/context_l10n.dart';
import 'package:lw_app/Models/YoutubeVideo/youtube_video.dart';
import 'package:lw_app/Themes/lwp_tokens.dart';
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
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    context.read<SermonsBloc>().add(const LoadSermons());
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<YoutubeVideo> _filterSermons(List<YoutubeVideo> videos) {
    final query = _searchController.text.toLowerCase().trim();
    if (query.isEmpty) return videos;
    return videos.where((v) {
      final title = (v.customTitle ?? v.title).toLowerCase();
      final author = (v.customAuthor ?? v.authorName).toLowerCase();
      return title.contains(query) || author.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    SermonsBloc sermonsBloc = BlocProvider.of<SermonsBloc>(context);

    return BlocListener<SermonsBloc, SermonsState>(
      listener: (context, state) {},
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.sermonsTitle),
          actions: const <Widget>[
            LwpAnnouncementButton(),
            ProfileActionButton()
          ],
        ),
        body: SafeArea(
          child: BlocBuilder<SermonsBloc, SermonsState>(
            builder: (context, state) {
              if (state is SermonsLoading) {
                return LwpLoader(message: context.l10n.sermonsLoading);
              } else if (state is SermonsSuccess) {
                if (state.youtubeVideos.isNotEmpty) {
                  return StatefulBuilder(
                    builder: (context, setInnerState) {
                      final filtered = _filterSermons(state.youtubeVideos);
                      return RefreshIndicator(
                        onRefresh: () async =>
                            sermonsBloc.add(const LoadSermons()),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: filtered.length + 1,
                          itemBuilder: (BuildContext context, int index) {
                            if (index == 0) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (_) => setInnerState(() {}),
                                  decoration: InputDecoration(
                                    hintText: context.l10n.sermonsSearchHint,
                                    prefixIcon: const Icon(Icons.search),
                                    suffixIcon:
                                        _searchController.text.isNotEmpty
                                            ? IconButton(
                                                icon: const Icon(Icons.clear),
                                                onPressed: () {
                                                  _searchController.clear();
                                                  setInnerState(() {});
                                                },
                                              )
                                            : null,
                                    border: OutlineInputBorder(
                                      borderRadius: LwpRadii.lgAll,
                                      borderSide: BorderSide.none,
                                    ),
                                    filled: true,
                                  ),
                                ),
                              );
                            }
                            final video = filtered[index - 1];
                            return _buildVideoCard(video, () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      SermonDetailPage(video: video),
                                ),
                              );
                            });
                          },
                        ),
                      );
                    },
                  );
                } else {
                  return LwpEmpty(message: context.l10n.sermonsEmpty);
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

  Widget _buildVideoCard(YoutubeVideo video, VoidCallback onTap) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: LwpSpacing.lg),
      shape: RoundedRectangleBorder(
        borderRadius: LwpRadii.lgAll,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: LwpRadii.lgAll,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: LwpRadii.lgTop,
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  video.thumbnailUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.customTitle ?? video.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    video.customAuthor ?? video.authorName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
