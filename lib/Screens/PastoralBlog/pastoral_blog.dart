import 'package:cloudinary_flutter/image/cld_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Extensions/context_l10n.dart';
import 'package:lw_app/Blocs/PastoralBlog/pastoral_blog_bloc.dart';
import 'package:lw_app/Models/PastoralBlog/pastoral_post.dart';
import 'package:lw_app/Screens/PastoralBlog/pastoral_blog_reader.dart';
import 'package:lw_app/Themes/lwp_tokens.dart';
import 'package:lw_app/Utils/date_formatter.dart';
import 'package:lw_app/Utils/quill_helper.dart';
import 'package:lw_app/Widgets/LwpEmpty/lwp_empty.dart';
import 'package:lw_app/Widgets/LwpError/lwp_error.dart';
import 'package:lw_app/Widgets/LwpLoader/lwp_loader.dart';

class PastoralBlogPage extends StatelessWidget {
  const PastoralBlogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PastoralBlogBloc()..add(const LoadPastoralBlog()),
      child: const _PastoralBlogView(),
    );
  }
}

class _PastoralBlogView extends StatelessWidget {
  const _PastoralBlogView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PastoralBlogBloc, PastoralBlogState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: Text(context.l10n.pastoralBlogTitle)),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, PastoralBlogState state) {
    if (state.status == PastoralBlogStatus.loading && !state.isRefreshing) {
      return LwpLoader(message: context.l10n.pastoralBlogLoading);
    }

    if (state.status == PastoralBlogStatus.error) {
      return LwpError(
        message: state.message ?? context.l10n.pastoralBlogLoadError,
        onRetry: () =>
            context.read<PastoralBlogBloc>().add(const LoadPastoralBlog()),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
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
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                LwpSpacing.md,
                LwpSpacing.md,
                LwpSpacing.md,
                LwpSpacing.xxl,
              ),
              sliver: SliverList.separated(
                itemCount: state.posts.length,
                itemBuilder: (context, index) {
                  final post = state.posts[index];
                  return _PastoralPostCard(
                    post: post,
                    onTap: () => _openReader(context, post),
                  );
                },
                separatorBuilder: (_, __) =>
                    const SizedBox(height: LwpSpacing.md),
              ),
            ),
        ],
      ),
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

class _PastoralPostCard extends StatelessWidget {
  final PastoralPost post;
  final VoidCallback onTap;

  const _PastoralPostCard({
    required this.post,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final excerpt = QuillHelper.plainTextPreview(post.content, maxLength: 120);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: LwpRadii.lgAll,
          border: Border.all(
            color: isDark
                ? Colors.white12
                : Colors.black.withValues(alpha: 0.07),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover image
            if (post.coverImagePublicId != null)
              SizedBox(
                height: 180,
                width: double.infinity,
                child: CldImageWidget(
                  publicId: post.coverImagePublicId!,
                  fit: BoxFit.cover,
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(LwpSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Author + date row
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor:
                            theme.primaryColor.withValues(alpha: 0.12),
                        child: Icon(
                          Icons.church_outlined,
                          color: theme.primaryColor,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: LwpSpacing.sm),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.displayAuthorName,
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            DateFormatter.formatDate(post.createdAt ?? ''),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.hintColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: LwpSpacing.md),

                  // Title
                  Text(
                    post.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),

                  // Excerpt
                  if (excerpt.isNotEmpty) ...[
                    const SizedBox(height: LwpSpacing.sm),
                    Text(
                      excerpt,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.hintColor,
                        height: 1.5,
                      ),
                    ),
                  ],

                  const SizedBox(height: LwpSpacing.md),

                  // Read more indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.l10n.pastoralBlogReadMore,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.thumb_up_alt_outlined,
                            size: 14,
                            color: theme.hintColor,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${post.reactionCount}',
                            style: theme.textTheme.labelSmall
                                ?.copyWith(color: theme.hintColor),
                          ),
                        ],
                      ),
                    ],
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
