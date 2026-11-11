import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lw_app/Themes/custom_theme.dart';
import 'package:lw_app/Themes/lwp_tokens.dart';

/// Frosted glass for floating chrome (Nexus-inspired).
/// Must sit under a [BackdropGroup] and use [BackdropFilter.grouped].
class LwpGlass extends StatelessWidget {
  const LwpGlass({
    super.key,
    required this.child,
    this.radius,
    this.thick = false,
  });

  final Widget child;
  final double? radius;
  final bool thick;

  static final _filter = ImageFilter.compose(
    outer: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
    inner: const ColorFilter.matrix(_saturate),
  );

  static final _thickFilter = ImageFilter.compose(
    outer: ImageFilter.blur(sigmaX: 34, sigmaY: 34),
    inner: const ColorFilter.matrix(_saturate),
  );

  /// Saturation 1.6 (Rec. 709) — same matrix as Nexus `NxGlass`.
  static const _saturate = <double>[
    1.47244, -0.42912, -0.04332, 0, 0, //
    -0.12756, 1.17088, -0.04332, 0, 0, //
    -0.12756, -0.42912, 1.55668, 0, 0, //
    0, 0, 0, 1, 0,
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final amb = isDark ? DarkColors.background : LightColors.background;
    final ink = isDark ? Colors.white : LightColors.primary;
    final r = radius ?? LwpRadii.pill;

    // Thinner than stock Nexus fills so blur + content read through more.
    final Color topFill;
    final Color bottomFill;
    if (isDark) {
      topFill = Color.lerp(amb, Colors.white, thick ? 0.08 : 0.12)!
          .withValues(alpha: thick ? 0.48 : 0.28);
      bottomFill = amb.withValues(alpha: thick ? 0.40 : 0.18);
    } else {
      topFill = Colors.white.withValues(alpha: thick ? 0.32 : 0.14);
      bottomFill = Colors.white.withValues(alpha: thick ? 0.20 : 0.06);
    }

    final filter = thick ? _thickFilter : _filter;
    final frosted = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: thick ? const [0, 0.2] : const [0, 0.45],
          colors: [topFill, bottomFill],
        ),
      ),
      child: child,
    );

    return CustomPaint(
      painter: _GlassShadow(r, soft: !isDark),
      foregroundPainter: _GlassRim(r, ink.withValues(alpha: isDark ? 0.13 : 0.08)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(r),
        child: BackdropGroup.of(context) != null
            ? BackdropFilter.grouped(filter: filter, child: frosted)
            : BackdropFilter(filter: filter, child: frosted),
      ),
    );
  }
}

/// Raised selection pill inside [LwpGlass] (tab lens).
/// Light mode uses a white raised capsule — black ink tint reads as a muddy
/// grey blob on frost (Nexus ink is light-on-dark).
class LwpGlassLens extends StatelessWidget {
  const LwpGlassLens({super.key, this.lift = 0});

  final double lift;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isDark) {
      final ink = Colors.white;
      return DecoratedBox(
        decoration: ShapeDecoration(
          color: ink.withValues(alpha: 0.13 + 0.07 * lift),
          shadows: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.40 + 0.15 * lift),
              blurRadius: 14 + 8 * lift,
              offset: Offset(0, 4 + 3 * lift),
              spreadRadius: -6,
            ),
          ],
          shape: _RaisedGlassBorder(
            highlight: 0.32 + 0.2 * lift,
            edge: 0.10 + 0.08 * lift,
            ink: ink,
          ),
        ),
      );
    }

    // Light: crisp white capsule with a tight soft shadow — no grey wash.
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: Colors.white.withValues(alpha: 0.72 + 0.12 * lift),
        shadows: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10 + 0.06 * lift),
            blurRadius: 10 + 4 * lift,
            offset: Offset(0, 3 + 2 * lift),
            spreadRadius: -4,
          ),
        ],
        shape: _RaisedGlassBorder(
          highlight: 0.55 + 0.15 * lift,
          edge: 0.06 + 0.04 * lift,
          ink: LightColors.primary,
        ),
      ),
    );
  }
}

/// Specular stadium rim (Nexus `NxGlassBorder.raised`).
class _RaisedGlassBorder extends ShapeBorder {
  const _RaisedGlassBorder({
    required this.highlight,
    required this.edge,
    required this.ink,
  });

  final double highlight;
  final double edge;
  final Color ink;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  ShapeBorder scale(double t) => this;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      getOuterPath(rect);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()..addRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(rect.shortestSide / 2)),
    );
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(0.5),
      Radius.circular(rect.shortestSide / 2),
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: const [0, 0.3, 0.7, 1],
        colors: [
          Colors.white.withValues(alpha: highlight),
          ink.withValues(alpha: edge),
          ink.withValues(alpha: edge),
          Colors.black.withValues(alpha: 0.18),
        ],
      ).createShader(rect);
    canvas.drawRRect(rrect, paint);
  }
}

class _GlassRim extends CustomPainter {
  _GlassRim(this.radius, this.edge);

  final double radius;
  final Color edge;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: const [0, 0.3, 0.7, 1],
        colors: [
          Colors.white.withValues(alpha: 0.40),
          edge,
          edge,
          Colors.black.withValues(alpha: 0.18),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRRect(_shape(size, radius, 0.5), paint);
  }

  @override
  bool shouldRepaint(_GlassRim old) => old.radius != radius || old.edge != edge;
}

class _GlassShadow extends CustomPainter {
  _GlassShadow(this.radius, {this.soft = false});

  final double radius;
  final bool soft;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final shape = _shape(size, radius);
    canvas
      ..save()
      ..clipPath(
        Path.combine(
          PathOperation.difference,
          Path()..addRect((Offset.zero & size).inflate(48)),
          Path()..addRRect(shape),
        ),
      )
      ..drawRRect(
        shape.shift(Offset(0, soft ? 8 : 12)).deflate(soft ? 4 : 6),
        Paint()
          ..color = Colors.black.withValues(alpha: soft ? 0.14 : 0.40)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, soft ? 10 : 14),
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_GlassShadow old) =>
      old.radius != radius || old.soft != soft;
}

RRect _shape(Size size, double radius, [double inset = 0]) {
  final r = math.min(radius, size.shortestSide / 2);
  return RRect.fromRectAndRadius(
    (Offset.zero & size).deflate(inset),
    Radius.circular(r),
  );
}
