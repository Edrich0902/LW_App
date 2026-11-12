import 'package:flutter/material.dart';
import 'package:lw_app/Extensions/context_l10n.dart';
import 'package:lw_app/Widgets/Glass/lwp_chrome_scaffold.dart';
import 'package:lw_app/Models/YoutubeVideo/youtube_video.dart';
import 'package:lw_app/Themes/lwp_tokens.dart';
import 'package:lw_app/Blocs/Sermons/sermons_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Widgets/LwpError/lwp_error.dart';
import 'package:lw_app/Widgets/LwpEmpty/lwp_empty.dart';
import 'package:lw_app/Widgets/LwpSkeleton/lwp_skeleton.dart';
import 'package:lw_app/Screens/Sermons/sermon_detail.dart';
import 'package:lw_app/Widgets/LwpListEntrance/lwp_list_entrance.dart';

class SermonsPage extends StatefulWidget {
  const SermonsPage({super.key});

  @override
  State<SermonsPage> createState() => _SermonsPageState();
}

class _SermonsPageState extends State<SermonsPage> {
  final TextEditingController _searchController = TextEditingController();
  final _listEntrance = LwpListEntranceController();

  @override
  void initState() {
    context.read<SermonsBloc>().add(const LoadSermons());
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _listEntrance.dispose();
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
      child: LwpChromeScaffold(
        title: context.l10n.sermonsTitle,
        showDefaultActions: true,
        body: BlocBuilder<SermonsBloc, SermonsState>(
            builder: (context, state) {
              if (state is SermonsLoading) {
                return LwpSkeletonList.media();
              } else if (state is SermonsSuccess) {
                if (state.youtubeVideos.isNotEmpty) {
                  return StatefulBuilder(
                    builder: (context, setInnerState) {
                      final filtered = _filterSermons(state.youtubeVideos);
                      return LwpListEntranceScope(
                        controller: _listEntrance,
                        child: RefreshIndicator(
                          onRefresh: () async {
                            _listEntrance.bump();
                            sermonsBloc.add(const LoadSermons());
                          },
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
                              final rowIndex = index - 1;
                              return LwpListEntrance(
                                id: video.youtubeLink ?? 'sermon-$rowIndex',
                                child: _buildVideoCard(video, () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          SermonDetailPage(video: video),
                                    ),
                                  );
                                }),
                              );
                            },
                          ),
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
    );
  }

  Widget _buildVideoCard(YoutubeVideo video, VoidCallback onTap) {
    final theme = Theme.of(context);
    final title = video.customTitle ?? video.title;
    final author = video.customAuthor ?? video.authorName;

    return Card(
      margin: const EdgeInsets.only(bottom: LwpSpacing.sm),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: const RoundedRectangleBorder(borderRadius: LwpRadii.lgAll),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 132,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    video.thumbnailUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => ColoredBox(
                      color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  Center(
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                LwpSpacing.sm,
                LwpSpacing.sm,
                LwpSpacing.sm,
                LwpSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                      height: 1.25,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (author.trim().isNotEmpty) ...[
                    const SizedBox(height: LwpSpacing.xxs),
                    Text(
                      author,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.hintColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
}
