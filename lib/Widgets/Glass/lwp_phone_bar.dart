import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lw_app/Themes/custom_theme.dart';
import 'package:lw_app/Themes/lwp_icons.dart';
import 'package:lw_app/Widgets/Glass/lwp_glass.dart';
import 'package:url_launcher/url_launcher.dart';

class LwpNavTab {
  const LwpNavTab({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

/// Floating glass dock + WhatsApp orb (Nexus PhoneBar pattern).
class LwpPhoneBar extends StatelessWidget {
  const LwpPhoneBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
    this.showWhatsappOrb = true,
  });

  final List<LwpNavTab> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final bool showWhatsappOrb;

  static const double dockHeight = 62;
  static const double side = 14;
  static const double gap = 10;

  static double dockBottom(MediaQueryData mq) =>
      math.max(mq.padding.bottom - 10, 12);

  static const _whatsappUrl = 'https://wa.me/+27727238406';

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final bottom = dockBottom(mq);
    final ink = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : LightColors.primary;

    return Padding(
      padding: EdgeInsets.fromLTRB(side, 0, side, bottom),
      child: SizedBox(
        height: dockHeight,
        child: Row(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return LwpGlass(
                    child: _TabDock(
                      tabs: tabs,
                      selectedIndex: selectedIndex,
                      onTabSelected: onTabSelected,
                      fullWidth: constraints.maxWidth,
                    ),
                  );
                },
              ),
            ),
            if (showWhatsappOrb) ...[
              const SizedBox(width: gap),
              SizedBox(
                width: dockHeight,
                height: dockHeight,
                child: LwpGlass(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      launchUrl(
                        Uri.parse(_whatsappUrl),
                        mode: LaunchMode.externalApplication,
                      );
                    },
                    child: Center(
                      child: FaIcon(LwpIcons.whatsapp, size: 22, color: ink),
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

/// Nexus `_TabBar` port: spring-driven lens, tap selects, drag scrubs.
class _TabDock extends StatefulWidget {
  const _TabDock({
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.fullWidth,
  });

  final List<LwpNavTab> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final double fullWidth;

  @override
  State<_TabDock> createState() => _TabDockState();
}

class _TabDockState extends State<_TabDock> with TickerProviderStateMixin {
  static const _pad = 4.0;
  static const _follow = SpringDescription(mass: 1, stiffness: 900, damping: 51);
  static const _settle = SpringDescription(mass: 1, stiffness: 520, damping: 28);

  late final _lift = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 120),
    reverseDuration: const Duration(milliseconds: 220),
  );
  late final _ticker = createTicker(_tick);
  late final _x = ValueNotifier(_leftFor(widget.selectedIndex));
  late final _lensListenable = Listenable.merge([_x, _lift]);

  double _velocity = 0;
  late double _target = _x.value;
  SpringDescription _spring = _settle;
  Duration _lastTick = Duration.zero;
  double _grab = 0;
  int? _hover;

  double get _tabWidth => (widget.fullWidth - _pad * 2) / widget.tabs.length;
  double _leftFor(int i) => _pad + i * _tabWidth;
  int _indexAt(double left) => ((left - _pad + _tabWidth / 2) / _tabWidth)
      .floor()
      .clamp(0, widget.tabs.length - 1);

  @override
  void didUpdateWidget(covariant _TabDock old) {
    super.didUpdateWidget(old);
    if (_hover != null) return;
    final target = _leftFor(widget.selectedIndex);
    if (old.fullWidth != widget.fullWidth) {
      _jumpTo(target);
    } else if (old.selectedIndex != widget.selectedIndex) {
      _springTo(target, _settle);
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _x.dispose();
    _lift.dispose();
    super.dispose();
  }

  void _jumpTo(double target) {
    _ticker.stop();
    _target = target;
    _velocity = 0;
    _x.value = target;
  }

  void _springTo(double target, SpringDescription spring) {
    _target = target;
    _spring = spring;
    if (!_ticker.isActive) {
      _lastTick = Duration.zero;
      _ticker.start();
    }
  }

  void _tick(Duration elapsed) {
    final dt = math.min((elapsed - _lastTick).inMicroseconds / 1e6, 1 / 30);
    _lastTick = elapsed;
    if (dt <= 0) return;
    var x = _x.value;
    const steps = 4;
    final h = dt / steps;
    for (var i = 0; i < steps; i++) {
      final accel =
          (_spring.stiffness * (_target - x) - _spring.damping * _velocity) /
              _spring.mass;
      _velocity += accel * h;
      x += _velocity * h;
    }
    if ((x - _target).abs() < 0.05 && _velocity.abs() < 2) {
      _ticker.stop();
      x = _target;
      _velocity = 0;
    }
    _x.value = x;
  }

  void _tapTab(int index) {
    // Start settle from the current lens position before parent rebuilds
    // (same spring as Nexus release / route change).
    _springTo(_leftFor(index), _settle);
    if (index == widget.selectedIndex) return;
    HapticFeedback.selectionClick();
    widget.onTabSelected(index);
  }

  void _dragStart(DragStartDetails d) {
    final x = d.localPosition.dx;
    final onLens = x >= _x.value && x <= _x.value + _tabWidth;
    _grab = onLens ? x - _x.value : _tabWidth / 2;
    _lift.forward();
    HapticFeedback.mediumImpact();
    setState(() => _hover = _indexAt(x - _grab));
    _dragTo(x);
  }

  void _dragTo(double x) {
    final min = _leftFor(0);
    final max = _leftFor(widget.tabs.length - 1);
    var left = x - _grab;
    if (left < min) left = min - math.min((min - left) * 0.3, 14);
    if (left > max) left = max + math.min((left - max) * 0.3, 14);
    _springTo(left, _follow);
    final i = _indexAt(left);
    if (i != _hover) {
      unawaited(HapticFeedback.selectionClick());
      setState(() => _hover = i);
    }
  }

  void _dragEnd(double velocity) {
    if (_hover == null) return;
    final projected = (_target + velocity * 0.08)
        .clamp(_leftFor(0), _leftFor(widget.tabs.length - 1))
        .toDouble();
    final index = _indexAt(projected);
    _lift.reverse();
    setState(() => _hover = null);
    _velocity = velocity;
    _springTo(_leftFor(index), _settle);
    if (index != widget.selectedIndex) {
      HapticFeedback.lightImpact();
      widget.onTabSelected(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ink = isDark ? Colors.white : LightColors.primary;
    final muted = isDark ? Colors.white70 : ink.withValues(alpha: 0.55);
    final highlight = _hover ?? widget.selectedIndex;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragStart: _dragStart,
      onHorizontalDragUpdate: (d) => _dragTo(d.localPosition.dx),
      onHorizontalDragEnd: (d) => _dragEnd(d.velocity.pixelsPerSecond.dx),
      onHorizontalDragCancel: () => _dragEnd(0),
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedBuilder(
            animation: _lensListenable,
            builder: (context, _) {
              final lift = _lift.value;
              final speed = _velocity.abs();
              return Positioned(
                top: _pad,
                bottom: _pad,
                left: _x.value,
                width: _tabWidth,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.diagonal3Values(
                    1 + math.min(speed / 2400, 0.4) + lift * 0.1,
                    1 - math.min(speed / 5000, 0.14) + lift * 0.12,
                    1,
                  ),
                  child: LwpGlassLens(lift: lift),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: _pad),
            child: Row(
              children: [
                for (var i = 0; i < widget.tabs.length; i++)
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _tapTab(i),
                      child: SizedBox(
                        height: double.infinity,
                        child: Icon(
                          widget.tabs[i].icon,
                          size: 22,
                          color: i == highlight ? ink : muted,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
