import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Soft-rise list entrance: fade + 8px rise (~200ms), staggered when several
/// rows appear in the same frame. Plays once per [id] until [bump].
class LwpListEntranceController extends ChangeNotifier {
  static const Duration duration = Duration(milliseconds: 380);
  static const Duration staggerStep = Duration(milliseconds: 55);
  static const double risePixels = 14;

  int _generation = 0;
  final Set<Object> _animatedIds = <Object>{};

  int get generation => _generation;

  /// Clear memory of animated rows so the next build plays entrances again
  /// (pull-to-refresh / full reload).
  void bump() {
    _generation += 1;
    _animatedIds.clear();
    _frameStamp = null;
    _slot = 0;
    notifyListeners();
  }

  bool hasAnimated(Object id) => _animatedIds.contains(id);

  void markAnimated(Object id) {
    _animatedIds.add(id);
  }

  Duration? _frameStamp;
  int _slot = 0;

  /// Stagger delay for rows that start animating in the same frame.
  Duration takeStagger() {
    final stamp = SchedulerBinding.instance.currentFrameTimeStamp;
    if (_frameStamp != stamp) {
      _frameStamp = stamp;
      _slot = 0;
    }
    final delay = staggerStep * _slot;
    _slot += 1;
    return delay;
  }
}

class LwpListEntranceScope extends InheritedNotifier<LwpListEntranceController> {
  const LwpListEntranceScope({
    super.key,
    required LwpListEntranceController controller,
    required super.child,
  }) : super(notifier: controller);

  static LwpListEntranceController of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<LwpListEntranceScope>();
    assert(
      scope != null,
      'LwpListEntrance requires a LwpListEntranceScope ancestor.',
    );
    return scope!.notifier!;
  }

  static LwpListEntranceController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<LwpListEntranceScope>()
        ?.notifier;
  }
}

/// Hosts a [LwpListEntranceController] for a list subtree.
class LwpListEntranceHost extends StatefulWidget {
  const LwpListEntranceHost({
    super.key,
    required this.builder,
  });

  final Widget Function(
    BuildContext context,
    LwpListEntranceController controller,
  ) builder;

  @override
  State<LwpListEntranceHost> createState() => _LwpListEntranceHostState();
}

class _LwpListEntranceHostState extends State<LwpListEntranceHost> {
  final LwpListEntranceController controller = LwpListEntranceController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LwpListEntranceScope(
      controller: controller,
      child: widget.builder(context, controller),
    );
  }
}

/// Wraps a list row. Animates on first appearance; skips if already played
/// for this controller generation.
class LwpListEntrance extends StatefulWidget {
  const LwpListEntrance({
    super.key,
    required this.id,
    required this.child,
  });

  final Object id;
  final Widget child;

  @override
  State<LwpListEntrance> createState() => _LwpListEntranceState();
}

class _LwpListEntranceState extends State<LwpListEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  LwpListEntranceController? _listController;
  int _seenGeneration = -1;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: LwpListEntranceController.duration,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final next = LwpListEntranceScope.maybeOf(context);
    if (!identical(next, _listController)) {
      _listController?.removeListener(_onListControllerChanged);
      _listController = next;
      _listController?.addListener(_onListControllerChanged);
    }
    _syncEntrance();
  }

  @override
  void didUpdateWidget(covariant LwpListEntrance oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id) {
      _started = false;
      _seenGeneration = -1;
      _syncEntrance();
    }
  }

  void _onListControllerChanged() {
    _syncEntrance();
  }

  void _syncEntrance() {
    final list = _listController;
    if (list == null) {
      _controller.value = 1;
      return;
    }

    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
      list.markAnimated(widget.id);
      _seenGeneration = list.generation;
      _started = true;
      return;
    }

    if (list.hasAnimated(widget.id)) {
      _controller.value = 1;
      _seenGeneration = list.generation;
      _started = true;
      return;
    }

    if (_seenGeneration == list.generation && _started) {
      return;
    }

    _seenGeneration = list.generation;
    _started = true;
    _controller.value = 0;
    final delay = list.takeStagger();

    Future<void>.delayed(delay, () {
      if (!mounted) return;
      final current = _listController;
      if (current == null) return;
      if (current.generation != _seenGeneration) return;
      if (current.hasAnimated(widget.id)) {
        _controller.value = 1;
        return;
      }
      _controller.forward().whenComplete(() {
        if (!mounted) return;
        _listController?.markAnimated(widget.id);
      });
    });
  }

  @override
  void dispose() {
    _listController?.removeListener(_onListControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final t = Curves.easeOutCubic.transform(_controller.value);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(
              0,
              LwpListEntranceController.risePixels * (1 - t),
            ),
            child: child,
          ),
        );
      },
    );
  }
}
