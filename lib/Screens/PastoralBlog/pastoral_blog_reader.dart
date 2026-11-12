import 'package:cloudinary_flutter/image/cld_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:lw_app/Blocs/PastoralBlog/pastoral_blog_bloc.dart';
import 'package:lw_app/Extensions/context_l10n.dart';
import 'package:lw_app/Models/PastoralBlog/pastoral_post.dart';
import 'package:lw_app/Themes/lwp_tokens.dart';
import 'package:lw_app/Utils/date_formatter.dart';
import 'package:lw_app/Utils/quill_helper.dart';
import 'package:lw_app/Widgets/Glass/lwp_chrome_scaffold.dart';
import 'package:lw_app/Widgets/Glass/lwp_top_bar.dart';
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
          final post = state.posts.where((p) => p.id == postId).firstOrNull;

          if (state.status == PastoralBlogStatus.loading && post == null) {
            return LwpChromeScaffold(
              title: context.l10n.pastoralBlogTitle,
              body: LwpLoader(message: context.l10n.pastoralBlogPostLoading),
            );
          }

          if (post == null) {
            return LwpChromeScaffold(
              title: context.l10n.pastoralBlogTitle,
              body: LwpEmpty(message: context.l10n.pastoralBlogPostNotFound),
            );
          }

          return _ReaderScaffold(
            post: post,
            isBusy: state.isFeedActionInProgress,
            onReact: (reactionType) => context.read<PastoralBlogBloc>().add(
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

bool _hasCover(PastoralPost post) =>
    (post.coverImagePublicId ?? '').trim().isNotEmpty;

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
    final hasCover = _hasCover(post);
    final topInset = LwpTopBar.heightOf(context);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          CustomScrollView(
            slivers: [
              if (hasCover)
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 320,
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
                                Color(0x8C0B1218),
                                Colors.transparent,
                                Color(0x330B1218),
                                Color(0xFA0B1218),
                              ],
                              stops: [0.0, 0.28, 0.55, 1.0],
                            ),
                          ),
                        ),
                        Positioned(
                          left: LwpSpacing.lg,
                          right: LwpSpacing.lg,
                          bottom: LwpSpacing.lg,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.l10n.pastoralBlogKicker.toUpperCase(),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: const Color(0xFF9FD0F3),
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.9,
                                ),
                              ),
                              const SizedBox(height: LwpSpacing.xs),
                              Text(
                                post.title,
                                style:
                                    theme.textTheme.headlineMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  height: 1.1,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      LwpSpacing.lg,
                      topInset + LwpSpacing.sm,
                      LwpSpacing.lg,
                      0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.pastoralBlogKicker.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.9,
                          ),
                        ),
                        const SizedBox(height: LwpSpacing.sm),
                        Text(
                          post.title,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            height: 1.12,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    LwpSpacing.lg,
                    hasCover ? LwpSpacing.md : LwpSpacing.lg,
                    LwpSpacing.lg,
                    LwpSpacing.xxl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  post.displayAuthorName,
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  DateFormatter.formatDate(
                                    post.createdAt ?? '',
                                  ),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.hintColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: LwpSpacing.lg),
                      _PostContent(content: post.content),
                      const SizedBox(height: LwpSpacing.xl),
                      Divider(
                        height: 1,
                        color: theme.dividerColor.withValues(alpha: 0.45),
                      ),
                      const SizedBox(height: LwpSpacing.md),
                      Text(
                        context.l10n.pastoralBlogReact.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.hintColor,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: LwpSpacing.sm),
                      Wrap(
                        spacing: LwpSpacing.sm,
                        runSpacing: LwpSpacing.sm,
                        children: PastoralPostReactionType.values
                            .map(
                              (type) => _ReactionChip(
                                label: PastoralPostReactionType.label(
                                  context.l10n,
                                  type,
                                ),
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
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LwpTopBar(
              title: context.l10n.pastoralBlogTitle,
              showBack: true,
              showTitle: false,
              showActions: false,
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
    final selectedColor = theme.primaryColor;
    final ink = isSelected
        ? (theme.brightness == Brightness.dark
            ? const Color(0xFF9FD0F3)
            : selectedColor)
        : theme.textTheme.bodyMedium?.color;

    return Material(
      color: isSelected
          ? selectedColor.withValues(alpha: 0.16)
          : theme.brightness == Brightness.dark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.04),
      borderRadius: BorderRadius.circular(LwpRadii.pill),
      child: InkWell(
        onTap: isBusy ? null : onTap,
        borderRadius: BorderRadius.circular(LwpRadii.pill),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: LwpSpacing.sm,
            vertical: LwpSpacing.xs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: ink),
              const SizedBox(width: 6),
              Text(
                '$label · $count',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: ink,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
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
