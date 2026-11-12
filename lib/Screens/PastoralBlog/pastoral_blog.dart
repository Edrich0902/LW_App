import 'package:cloudinary_flutter/image/cld_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Blocs/PastoralBlog/pastoral_blog_bloc.dart';
import 'package:lw_app/Extensions/context_l10n.dart';
import 'package:lw_app/Models/PastoralBlog/pastoral_post.dart';
import 'package:lw_app/Screens/PastoralBlog/pastoral_blog_reader.dart';
import 'package:lw_app/Themes/lwp_tokens.dart';
import 'package:lw_app/Utils/date_formatter.dart';
import 'package:lw_app/Utils/quill_helper.dart';
import 'package:lw_app/Widgets/Glass/lwp_chrome_scaffold.dart';
import 'package:lw_app/Widgets/LwpEmpty/lwp_empty.dart';
import 'package:lw_app/Widgets/LwpError/lwp_error.dart';
import 'package:lw_app/Widgets/LwpListEntrance/lwp_list_entrance.dart';
import 'package:lw_app/Widgets/LwpSkeleton/lwp_skeleton.dart';

class PastoralBlogPage extends StatelessWidget {
  const PastoralBlogPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<PastoralBlogBloc>();
    if (bloc.state.status == PastoralBlogStatus.initial) {
      bloc.add(const LoadPastoralBlog());
    }
    return const _PastoralBlogView();
  }
}

class _PastoralBlogView extends StatelessWidget {
  const _PastoralBlogView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PastoralBlogBloc, PastoralBlogState>(
      builder: (context, state) {
        return LwpChromeScaffold(
          title: context.l10n.pastoralBlogTitle,
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, PastoralBlogState state) {
    if (state.status == PastoralBlogStatus.loading && !state.isRefreshing) {
      return LwpSkeletonList.media(mediaHeight: 220);
    }

    if (state.status == PastoralBlogStatus.error) {
      return LwpError(
        message: state.message ?? context.l10n.pastoralBlogLoadError,
        onRetry: () =>
            context.read<PastoralBlogBloc>().add(const LoadPastoralBlog()),
      );
    }

    return LwpListEntranceHost(
      builder: (context, entrance) {
        return RefreshIndicator(
          onRefresh: () async {
            entrance.bump();
            context.read<PastoralBlogBloc>().add(const RefreshPastoralBlog());
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              if (state.posts.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(LwpSpacing.xl),
                      child: LwpEmpty(message: context.l10n.pastoralBlogEmpty),
                    ),
                  ),
                )
              else ...[
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    LwpSpacing.md,
                    LwpSpacing.sm,
                    LwpSpacing.md,
                    LwpSpacing.xs,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: LwpListEntrance(
                      id: 'featured-${state.posts.first.id}',
                      child: _FeaturedPost(
                        post: state.posts.first,
                        onTap: () => _openReader(context, state.posts.first),
                      ),
                    ),
                  ),
                ),
                if (state.posts.length > 1) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        LwpSpacing.md,
                        LwpSpacing.md,
                        LwpSpacing.md,
                        LwpSpacing.xs,
                      ),
                      child: Text(
                        context.l10n.pastoralBlogMorePosts,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).hintColor,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.8,
                            ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.only(bottom: LwpSpacing.xxl),
                    sliver: SliverList.separated(
                      itemCount: state.posts.length - 1,
                      itemBuilder: (context, index) {
                        final post = state.posts[index + 1];
                        return LwpListEntrance(
                          id: post.id,
                          child: _CompactPostRow(
                            post: post,
                            onTap: () => _openReader(context, post),
                          ),
                        );
                      },
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        thickness: 1,
                        color: Theme.of(context)
                            .dividerColor
                            .withValues(alpha: 0.35),
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        );
      },
    );
  }

  void _openReader(BuildContext context, PastoralPost post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<PastoralBlogBloc>(),
          child: PastoralBlogReaderPage(postId: post.id),
        ),
      ),
    );
  }
}

bool _hasCover(PastoralPost post) =>
    (post.coverImagePublicId ?? '').trim().isNotEmpty;

String _metaLine(BuildContext context, PastoralPost post, {bool short = false}) {
  final author = short
      ? post.displayAuthorName.split(' ').first
      : post.displayAuthorName;
  final date = DateFormatter.formatDate(post.createdAt ?? '');
  final amen = '${context.l10n.pastoralReactionAmen} ${post.amenCount}';
  return '$author · $date · $amen';
}

class _FeaturedPost extends StatelessWidget {
  const _FeaturedPost({
    required this.post,
    required this.onTap,
  });

  final PastoralPost post;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasCover = _hasCover(post);
    final excerpt = QuillHelper.plainTextPreview(post.content, maxLength: 110);

    final titleStyle = theme.textTheme.headlineSmall?.copyWith(
      fontWeight: FontWeight.w500,
      height: 1.12,
      letterSpacing: -0.4,
      color: hasCover ? Colors.white : null,
      fontFamily: theme.textTheme.headlineSmall?.fontFamily,
    );

    final inner = Padding(
      padding: const EdgeInsets.fromLTRB(
        LwpSpacing.md,
        LwpSpacing.lg,
        LwpSpacing.md,
        LwpSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            context.l10n.pastoralBlogFeaturedLabel.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: hasCover
                  ? const Color(0xFF9FD0F3)
                  : theme.primaryColor,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.9,
            ),
          ),
          const SizedBox(height: LwpSpacing.xs),
          Text(post.title, style: titleStyle),
          if (excerpt.isNotEmpty) ...[
            const SizedBox(height: LwpSpacing.sm),
            Text(
              excerpt,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: hasCover
                    ? Colors.white.withValues(alpha: 0.78)
                    : theme.hintColor,
                height: 1.45,
              ),
            ),
          ],
          const SizedBox(height: LwpSpacing.sm),
          Row(
            children: [
              CircleAvatar(
                radius: 11,
                backgroundColor: theme.primaryColor.withValues(alpha: 0.18),
                child: Icon(
                  Icons.church_outlined,
                  size: 12,
                  color: hasCover ? Colors.white : theme.primaryColor,
                ),
              ),
              const SizedBox(width: LwpSpacing.xs),
              Expanded(
                child: Text(
                  _metaLine(context, post),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: hasCover
                        ? Colors.white.withValues(alpha: 0.72)
                        : theme.hintColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: LwpRadii.lgAll,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: LwpRadii.lgAll,
            border: hasCover
                ? null
                : Border.all(
                    color: theme.dividerColor.withValues(alpha: 0.45),
                  ),
            color: hasCover
                ? null
                : theme.primaryColor.withValues(alpha: 0.06),
            gradient: hasCover
                ? null
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.primaryColor.withValues(alpha: 0.16),
                      theme.cardColor.withValues(alpha: 0.4),
                    ],
                  ),
          ),
          child: ClipRRect(
            borderRadius: LwpRadii.lgAll,
            child: hasCover
                ? SizedBox(
                    height: 280,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Hero(
                          tag: post.coverHeroTag,
                          child: Material(
                            type: MaterialType.transparency,
                            child: CldImageWidget(
                              publicId: post.coverImagePublicId!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Color(0xEB080C10),
                              ],
                              stops: [0.35, 1],
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: inner,
                        ),
                      ],
                    ),
                  )
                : inner,
          ),
        ),
      ),
    );
  }
}

class _CompactPostRow extends StatelessWidget {
  const _CompactPostRow({
    required this.post,
    required this.onTap,
  });

  final PastoralPost post;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasCover = _hasCover(post);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: LwpSpacing.md,
          vertical: LwpSpacing.md,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: LwpSpacing.xxs),
                  Text(
                    _metaLine(context, post, short: true),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                ],
              ),
            ),
            if (hasCover) ...[
              const SizedBox(width: LwpSpacing.sm),
              Hero(
                tag: post.coverHeroTag,
                child: ClipRRect(
                  borderRadius: LwpRadii.smAll,
                  child: SizedBox(
                    width: 64,
                    height: 64,
                    child: Material(
                      type: MaterialType.transparency,
                      child: CldImageWidget(
                        publicId: post.coverImagePublicId!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
