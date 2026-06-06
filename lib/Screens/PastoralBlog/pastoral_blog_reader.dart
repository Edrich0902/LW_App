import 'package:cloudinary_flutter/image/cld_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:lw_app/Extensions/context_l10n.dart';
import 'package:lw_app/Blocs/PastoralBlog/pastoral_blog_bloc.dart';
import 'package:lw_app/Models/PastoralBlog/pastoral_post.dart';
import 'package:lw_app/Themes/lwp_tokens.dart';
import 'package:lw_app/Utils/date_formatter.dart';
import 'package:lw_app/Utils/quill_helper.dart';
import 'package:lw_app/Widgets/LwpEmpty/lwp_empty.dart';
import 'package:lw_app/Widgets/LwpLoader/lwp_loader.dart';
import 'package:lw_app/Widgets/LwpSnackbar/lwp_snackbar.dart';

class PastoralBlogReaderPage extends StatelessWidget {
  final String postId;

  const PastoralBlogReaderPage({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    return BlocListener<PastoralBlogBloc, PastoralBlogState>(
      listenWhen: (previous, current) => previous.message != current.message,
      listener: (context, state) {
        if (state.message == null || state.message!.isEmpty) return;
        if (state.isErrorMessage) {
          LwpSnackbar.showError(context, state.message!);
        } else {
          LwpSnackbar.showSuccess(context, state.message!);
        }
        context.read<PastoralBlogBloc>().add(const ClearPastoralBlogMessage());
      },
      child: BlocBuilder<PastoralBlogBloc, PastoralBlogState>(
        builder: (context, state) {
          final post =
              state.posts.where((p) => p.id == postId).firstOrNull;

          if (state.status == PastoralBlogStatus.loading && post == null) {
            return Scaffold(
              body: LwpLoader(message: context.l10n.pastoralBlogPostLoading),
            );
          }

          if (post == null) {
            return Scaffold(
              body: LwpEmpty(message: context.l10n.pastoralBlogPostNotFound),
            );
          }

          return _ReaderScaffold(
            post: post,
            isBusy: state.isFeedActionInProgress,
            onReact: (reactionType) =>
                context.read<PastoralBlogBloc>().add(
                      TogglePastoralPostReaction(
                        post: post,
                        reactionType: reactionType,
                      ),
                    ),
          );
        },
      ),
    );
  }
}

class _ReaderScaffold extends StatelessWidget {
  final PastoralPost post;
  final bool isBusy;
  final ValueChanged<String> onReact;

  const _ReaderScaffold({
    required this.post,
    required this.isBusy,
    required this.onReact,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Collapsing header — cover image if available, plain AppBar otherwise
          SliverAppBar(
            expandedHeight: post.coverImagePublicId != null ? 260.0 : null,
            pinned: true,
            flexibleSpace: post.coverImagePublicId != null
                ? FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        CldImageWidget(
                          publicId: post.coverImagePublicId!,
                          fit: BoxFit.cover,
                        ),
                        // Gradient so the back arrow stays legible
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.4),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.6],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : null,
          ),

          // Post body
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                LwpSpacing.lg,
                LwpSpacing.lg,
                LwpSpacing.lg,
                LwpSpacing.xxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Author + date
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor:
                            theme.primaryColor.withValues(alpha: 0.12),
                        child: Icon(
                          Icons.church_outlined,
                          color: theme.primaryColor,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: LwpSpacing.sm),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.displayAuthorName,
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            DateFormatter.formatDate(post.createdAt ?? ''),
                            style: theme.textTheme.labelSmall
                                ?.copyWith(color: theme.hintColor),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: LwpSpacing.lg),

                  // Title
                  Text(
                    post.title,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: LwpSpacing.lg),
                  Divider(color: theme.dividerColor),
                  const SizedBox(height: LwpSpacing.md),

                  // Rich text content
                  _PostContent(content: post.content),

                  const SizedBox(height: LwpSpacing.xl),
                  Divider(color: theme.dividerColor),
                  const SizedBox(height: LwpSpacing.md),

                  // Reactions
                  Text(
                    context.l10n.pastoralBlogReact,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.hintColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: LwpSpacing.sm),
                  Wrap(
                    spacing: LwpSpacing.sm,
                    runSpacing: LwpSpacing.sm,
                    children: PastoralPostReactionType.values
                        .map(
                          (type) => _ReactionChip(
                            label: PastoralPostReactionType.label(context.l10n, type),
                            count: post.reactionCountFor(type),
                            icon: _reactionIcon(type),
                            isSelected: post.currentUserReaction == type,
                            isBusy: isBusy,
                            onTap: () => onReact(type),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReactionChip extends StatelessWidget {
  final String label;
  final int count;
  final IconData icon;
  final bool isSelected;
  final bool isBusy;
  final VoidCallback onTap;

  const _ReactionChip({
    required this.label,
    required this.count,
    required this.icon,
    required this.isSelected,
    required this.isBusy,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color =
        isSelected ? theme.primaryColor : theme.textTheme.bodyMedium?.color;

    return ActionChip(
      onPressed: isBusy ? null : onTap,
      avatar: Icon(icon, size: 18, color: color),
      label: Text('$label ($count)'),
      backgroundColor: isSelected
          ? theme.primaryColor.withValues(alpha: 0.12)
          : theme.cardColor,
      side: BorderSide(
        color: isSelected
            ? theme.primaryColor.withValues(alpha: 0.35)
            : theme.dividerColor,
      ),
      shape: const StadiumBorder(),
      labelStyle: TextStyle(
        color: color,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
      ),
    );
  }
}

class _PostContent extends StatefulWidget {
  final String content;
  const _PostContent({required this.content});

  @override
  State<_PostContent> createState() => _PostContentState();
}

class _PostContentState extends State<_PostContent> {
  late QuillController _controller;
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = _build(widget.content);
  }

  @override
  void didUpdateWidget(covariant _PostContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.content != widget.content) {
      _controller.dispose();
      _controller = _build(widget.content);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: QuillEditor(
        controller: _controller,
        focusNode: _focusNode,
        scrollController: _scrollController,
        config: const QuillEditorConfig(
          scrollable: false,
          expands: false,
          padding: EdgeInsets.zero,
          showCursor: false,
          enableInteractiveSelection: false,
        ),
      ),
    );
  }

  QuillController _build(String content) {
    return QuillController(
      document: QuillHelper.fromContent(content),
      selection: const TextSelection.collapsed(offset: 0),
      readOnly: true,
    );
  }
}

IconData _reactionIcon(String type) {
  switch (type) {
    case PastoralPostReactionType.amen:
      return Icons.thumb_up_alt_outlined;
    case PastoralPostReactionType.prayer:
      return Icons.volunteer_activism_outlined;
    case PastoralPostReactionType.heart:
      return Icons.favorite_border;
    default:
      return Icons.add_reaction_outlined;
  }
}
