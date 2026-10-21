part of '../mm_swipeable.dart';

/// A widget that can be swiped to the left or right.
///
/// It does not dismiss its child on a swipe; it calls [onSwipedLeft] or
/// [onSwipedRight] once the child has left its bounds and leaves removing the
/// child to the caller.
///
/// The swipe is decided on where the card is heading, not where it is: the
/// release point is projected forward by the finger's velocity
/// (`offset + velocity * projectionTime`), and the swipe commits when that
/// projected point passes `swipeThreshold * width`. A short, quick flick and a
/// long, slow drag therefore both commit, and the direction always follows the
/// motion.
///
/// Only horizontal drags are claimed, so a vertical scrollable inside the card
/// keeps its gestures: whichever axis the finger moves along first wins.
///
/// When the projection passes the threshold, [confirmSwipe] decides the outcome:
/// `true` commits and calls [onSwipedLeft] / [onSwipedRight] once the card has
/// left its bounds, `false` springs back and calls the matching cancelled
/// callback, and `null` springs back silently.
///
/// Example usage:
///
/// ```dart
/// final swipeableController = MmSwipeableController();
///
/// MmSwipeable(
///   controller: swipeableController,
///   confirmSwipe: () => canSwipe ? true : false,
///   onSwipedLeft: () {
///     // Handle swipe left action.
///   },
///   onSwipedRight: () {
///     // Handle swipe right action.
///   },
///   onSwipeLeftCancelled: () {
///     // Handle swipe left cancellation.
///   },
///   onSwipeRightCancelled: () {
///     // Handle swipe right cancellation.
///   },
///   child: Container(
///     height: 600,
///     color: Colors.blue,
///   ),
/// )
/// ```
class MmSwipeable extends StatefulWidget {
  /// Decides the outcome of a swipe whose projection passed the threshold.
  ///
  /// Returns `true` to commit, `false` to spring back and call
  /// [onSwipeLeftCancelled] / [onSwipeRightCancelled], and `null` to spring
  /// back without any callback. It is also called by
  /// [MmSwipeableController.swipeLeft] and [MmSwipeableController.swipeRight].
  ///
  /// The controller's value already holds the release details when it is
  /// called, so `controller.value.swipingRight` tells the direction.
  final bool? Function() confirmSwipe;

  /// Called once a committed left swipe has carried the card out of its bounds.
  final VoidCallback onSwipedLeft;

  /// Called once a committed right swipe has carried the card out of its bounds.
  final VoidCallback onSwipedRight;

  /// Called when [confirmSwipe] returns `false` for a right swipe.
  final VoidCallback? onSwipeRightCancelled;

  /// Called when [confirmSwipe] returns `false` for a left swipe.
  final VoidCallback? onSwipeLeftCancelled;

  /// Publishes the swipe details while the card moves and triggers
  /// programmatic swipes.
  final MmSwipeableController controller;

  /// The widget to be swiped.
  final Widget child;

  /// Fraction of the card's width the projected point must travel to commit.
  final double swipeThreshold;

  /// How far ahead, in time, the release velocity is projected.
  final Duration projectionTime;

  /// Plays a selection click when a drag reaches the commit threshold.
  final bool enableHaptics;

  const MmSwipeable({
    required this.confirmSwipe,
    required this.onSwipedLeft,
    required this.onSwipedRight,
    required this.controller,
    required this.child,
    this.onSwipeRightCancelled,
    this.onSwipeLeftCancelled,
    this.swipeThreshold = 0.35,
    this.projectionTime = const Duration(milliseconds: 200),
    this.enableHaptics = true,
    super.key,
  });

  @override
  State<MmSwipeable> createState() => _MmSwipeableState();
}

class _MmSwipeableState extends State<MmSwipeable>
    with SingleTickerProviderStateMixin {
  static const _maxRotation = 0.21;
  static const _angleScalar = 2.12;
  static const _forceScalar = 0.1;
  static const _minExitSpeed = 1.5;
  static const _exitDistance = 1.6;
  static const _rearmBelow = 0.85;

  static final _returnSpring = SpringDescription.withDampingRatio(
    mass: 1,
    stiffness: 320,
    ratio: 0.72,
  );
  static final _exitSpring = SpringDescription.withDampingRatio(
    mass: 1,
    stiffness: 180,
    ratio: 1,
  );

  late final AnimationController _x = AnimationController.unbounded(vsync: this)
    ..addListener(_onPositionChanged);

  double _width = 0;
  double _grabSign = 1;
  bool _dragging = false;
  bool _pastThreshold = false;
  double? _exitDirection;
  bool _exitNotified = false;

  double get _thresholdDistance => widget.swipeThreshold * _width;

  double get _projectionSeconds =>
      widget.projectionTime.inMicroseconds / Duration.microsecondsPerSecond;

  @override
  void initState() {
    super.initState();
    widget.controller._bind(this);
  }

  @override
  void didUpdateWidget(covariant MmSwipeable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller._unbind(this);
      widget.controller._bind(this);
    }
  }

  @override
  void dispose() {
    widget.controller._unbind(this);
    _x.dispose();
    super.dispose();
  }

  double _progressFor(double velocity) {
    if (_width == 0) return 0;
    final projected = _x.value + velocity * _projectionSeconds;
    return clampDouble(projected / _thresholdDistance, -1, 1);
  }

  void _publish({required double progress, double velocity = 0}) {
    if (_width == 0) return;
    widget.controller.value = MmSwipeableSwipeDetails(
      angle: clampDouble(_x.value / _width * _angleScalar, -1, 1),
      force: clampDouble(velocity / _width * _forceScalar, -1, 1),
      progress: progress,
    );
  }

  void _onPositionChanged() {
    if (!_dragging) _publish(progress: _exitDirection ?? _progressFor(0));
    final direction = _exitDirection;
    if (direction == null || _exitNotified) return;
    if (_x.value.abs() < _width) return;
    _exitNotified = true;
    if (direction > 0) {
      widget.onSwipedRight();
    } else {
      widget.onSwipedLeft();
    }
  }

  void _onDragStart(DragStartDetails details) {
    if (_exitDirection != null) return;
    _x.stop();
    _dragging = true;
    _pastThreshold = false;
    final height = (context.findRenderObject() as RenderBox?)?.size.height ?? 0;
    _grabSign = details.localPosition.dy < height / 2 ? 1 : -1;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (!_dragging) return;
    _x.value += details.delta.dx;

    final progress = _progressFor(0);
    if (!_pastThreshold && progress.abs() >= 1) {
      _pastThreshold = true;
      if (widget.enableHaptics) HapticFeedback.selectionClick();
    } else if (_pastThreshold && progress.abs() < _rearmBelow) {
      _pastThreshold = false;
    }
    _publish(progress: progress);
  }

  void _onDragEnd(DragEndDetails details) {
    if (!_dragging) return;
    _dragging = false;
    _release(details.velocity.pixelsPerSecond.dx);
  }

  void _onDragCancel() {
    if (!_dragging) return;
    _dragging = false;
    _release(0);
  }

  void _release(double velocity) {
    final predicted = _progressFor(velocity);
    if (predicted.abs() < 1) {
      _publish(progress: _progressFor(0), velocity: velocity);
      return _springBack(velocity);
    }
    _publish(progress: predicted, velocity: velocity);

    final direction = predicted.sign;
    final confirm = widget.confirmSwipe();
    if (!mounted) return;
    if (confirm == true) return _flyOut(direction, velocity);
    _springBack(velocity);
    if (confirm == null) return;
    if (direction > 0) {
      widget.onSwipeRightCancelled?.call();
    } else {
      widget.onSwipeLeftCancelled?.call();
    }
  }

  void _springBack(double velocity) {
    _x.animateWith(SpringSimulation(_returnSpring, _x.value, 0, velocity));
  }

  void _flyOut(double direction, double velocity) {
    _exitDirection = direction;
    final speed = max(velocity * direction, _minExitSpeed * _width);
    _x.animateWith(
      SpringSimulation(
        _exitSpring,
        _x.value,
        direction * _exitDistance * _width,
        direction * speed,
      ),
    );
  }

  void _swipeProgrammatically(double direction) {
    if (!mounted || _dragging || _exitDirection != null || _width == 0) return;
    widget.controller.value = MmSwipeableSwipeDetails(
      angle: direction,
      force: 0,
      progress: direction,
    );
    final confirm = widget.confirmSwipe();
    if (!mounted) return;
    _grabSign = 1;
    if (confirm == true) return _flyOut(direction, 0);
    _springBack(direction * _minExitSpeed * _width);
    if (confirm == null) return;
    if (direction > 0) {
      widget.onSwipeRightCancelled?.call();
    } else {
      widget.onSwipeLeftCancelled?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _width = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        return GestureDetector(
          dragStartBehavior: DragStartBehavior.down,
          onHorizontalDragStart: _onDragStart,
          onHorizontalDragUpdate: _onDragUpdate,
          onHorizontalDragEnd: _onDragEnd,
          onHorizontalDragCancel: _onDragCancel,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: _x,
                builder: (context, child) {
                  final rotation = _width == 0
                      ? 0.0
                      : _x.value / _width * _maxRotation * _grabSign;
                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.translationValues(_x.value, 0, 0)
                      ..rotateZ(rotation),
                    child: child,
                  );
                },
                child: widget.child,
              ),
            ],
          ),
        );
      },
    );
  }
}
