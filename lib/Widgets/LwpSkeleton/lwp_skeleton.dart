import 'package:flutter/material.dart';
import 'package:lw_app/Themes/lwp_tokens.dart';

/// Soft shimmer bone used by skeleton card presets.
class LwpSkeletonBone extends StatefulWidget {
  const LwpSkeletonBone({
    super.key,
    this.width,
    this.height = 14,
    this.radius = LwpRadii.sm,
  });

  final double? width;
  final double height;
  final double radius;

  @override
  State<LwpSkeletonBone> createState() => _LwpSkeletonBoneState();
}

class _LwpSkeletonBoneState extends State<LwpSkeletonBone>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.06);
    final highlight = isDark
        ? Colors.white.withValues(alpha: 0.14)
        : Colors.white.withValues(alpha: 0.55);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment(-1.4 + 2.8 * _controller.value, 0),
              end: Alignment(-0.2 + 2.8 * _controller.value, 0),
              colors: [base, highlight, base],
              stops: const [0.25, 0.5, 0.75],
            ),
          ),
        );
      },
    );
  }
}

/// Shared card chrome matching list cards across the app.
class LwpSkeletonCardShell extends StatelessWidget {
  const LwpSkeletonCardShell({
    super.key,
    required this.child,
    this.margin = const EdgeInsets.only(bottom: LwpSpacing.md),
    this.padding,
  });

  final Widget child;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: LwpRadii.lgAll,
        border: Border.all(
          color: isDark
              ? Colors.white12
              : Colors.black.withValues(alpha: 0.07),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: padding == null
          ? child
          : Padding(padding: padding!, child: child),
    );
  }
}

/// Media-top card (sermons / blog cover style).
class LwpSkeletonMediaCard extends StatelessWidget {
  const LwpSkeletonMediaCard({
    super.key,
    this.mediaHeight = 160,
    this.compact = false,
  });

  final double mediaHeight;

  /// Fits tight dashboard placeholders — media fills available height with
  /// title lines overlaid at the bottom (no overflow).
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return LwpSkeletonCardShell(
        margin: EdgeInsets.zero,
        padding: null,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const LwpSkeletonBone(
              width: double.infinity,
              height: double.infinity,
              radius: 0,
            ),
            Positioned(
              left: LwpSpacing.md,
              right: LwpSpacing.md,
              bottom: LwpSpacing.md,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: const [
                  LwpSkeletonBone(width: 160, height: 14),
                  SizedBox(height: LwpSpacing.xs),
                  LwpSkeletonBone(width: 110, height: 10),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return LwpSkeletonCardShell(
      padding: null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          LwpSkeletonBone(
            width: double.infinity,
            height: mediaHeight,
            radius: 0,
          ),
          const Padding(
            padding: EdgeInsets.all(LwpSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LwpSkeletonBone(width: 180, height: 16),
                SizedBox(height: LwpSpacing.sm),
                LwpSkeletonBone(width: double.infinity, height: 12),
                SizedBox(height: LwpSpacing.xs),
                LwpSkeletonBone(width: 140, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Thumbnail + text row (announcements / events style).
class LwpSkeletonThumbCard extends StatelessWidget {
  const LwpSkeletonThumbCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const LwpSkeletonCardShell(
      padding: EdgeInsets.all(LwpSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LwpSkeletonBone(width: 80, height: 80, radius: LwpRadii.sm),
          SizedBox(width: LwpSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LwpSkeletonBone(width: 160, height: 16),
                SizedBox(height: LwpSpacing.sm),
                LwpSkeletonBone(width: double.infinity, height: 12),
                SizedBox(height: LwpSpacing.xs),
                LwpSkeletonBone(width: double.infinity, height: 12),
                SizedBox(height: LwpSpacing.xs),
                LwpSkeletonBone(width: 100, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Text-only note / feedback style card.
class LwpSkeletonTextCard extends StatelessWidget {
  const LwpSkeletonTextCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const LwpSkeletonCardShell(
      padding: EdgeInsets.all(LwpSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LwpSkeletonBone(width: 140, height: 16),
          SizedBox(height: LwpSpacing.sm),
          LwpSkeletonBone(width: double.infinity, height: 12),
          SizedBox(height: LwpSpacing.xs),
          LwpSkeletonBone(width: double.infinity, height: 12),
          SizedBox(height: LwpSpacing.xs),
          LwpSkeletonBone(width: 180, height: 12),
        ],
      ),
    );
  }
}

/// Group / connect card with avatar + lines.
class LwpSkeletonGroupCard extends StatelessWidget {
  const LwpSkeletonGroupCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const LwpSkeletonCardShell(
      padding: EdgeInsets.all(LwpSpacing.md),
      child: Row(
        children: [
          LwpSkeletonBone(width: 56, height: 56, radius: LwpRadii.pill),
          SizedBox(width: LwpSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LwpSkeletonBone(width: 150, height: 16),
                SizedBox(height: LwpSpacing.sm),
                LwpSkeletonBone(width: double.infinity, height: 12),
                SizedBox(height: LwpSpacing.xs),
                LwpSkeletonBone(width: 120, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum LwpSkeletonCardStyle { media, thumb, text, group }

/// Scrollable list of skeleton cards for list/screen loading states.
class LwpSkeletonList extends StatelessWidget {
  const LwpSkeletonList({
    super.key,
    this.style = LwpSkeletonCardStyle.thumb,
    this.itemCount = 6,
    this.padding = const EdgeInsets.all(LwpSpacing.md),
    this.mediaHeight = 160,
    this.shrinkWrap = false,
  });

  final LwpSkeletonCardStyle style;
  final int itemCount;
  final EdgeInsetsGeometry padding;
  final double mediaHeight;

  /// Use inside another scroll view (e.g. dashboard / visitor page).
  final bool shrinkWrap;

  factory LwpSkeletonList.media({
    Key? key,
    int itemCount = 5,
    double mediaHeight = 160,
    bool shrinkWrap = false,
  }) =>
      LwpSkeletonList(
        key: key,
        style: LwpSkeletonCardStyle.media,
        itemCount: itemCount,
        mediaHeight: mediaHeight,
        shrinkWrap: shrinkWrap,
      );

  factory LwpSkeletonList.thumb({
    Key? key,
    int itemCount = 6,
    bool shrinkWrap = false,
  }) =>
      LwpSkeletonList(
        key: key,
        style: LwpSkeletonCardStyle.thumb,
        itemCount: itemCount,
        shrinkWrap: shrinkWrap,
      );

  factory LwpSkeletonList.text({
    Key? key,
    int itemCount = 6,
    bool shrinkWrap = false,
  }) =>
      LwpSkeletonList(
        key: key,
        style: LwpSkeletonCardStyle.text,
        itemCount: itemCount,
        shrinkWrap: shrinkWrap,
      );

  factory LwpSkeletonList.group({
    Key? key,
    int itemCount = 6,
    bool shrinkWrap = false,
  }) =>
      LwpSkeletonList(
        key: key,
        style: LwpSkeletonCardStyle.group,
        itemCount: itemCount,
        shrinkWrap: shrinkWrap,
      );

  Widget _item() {
    switch (style) {
      case LwpSkeletonCardStyle.media:
        return LwpSkeletonMediaCard(mediaHeight: mediaHeight);
      case LwpSkeletonCardStyle.thumb:
        return const LwpSkeletonThumbCard();
      case LwpSkeletonCardStyle.text:
        return const LwpSkeletonTextCard();
      case LwpSkeletonCardStyle.group:
        return const LwpSkeletonGroupCard();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (shrinkWrap) {
      return Padding(
        padding: padding,
        child: Column(
          children: List.generate(itemCount, (_) => _item()),
        ),
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: padding,
      itemCount: itemCount,
      itemBuilder: (context, index) => _item(),
    );
  }
}
