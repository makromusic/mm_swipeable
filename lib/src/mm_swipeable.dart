part of mm_swipeable;

/// {@template mm_swipeable}
/// A widget that enables swipe actions in both left and right directions.
///
/// This widget allows users to swipe a child widget either to the left or right.
/// It does not automatically dismiss the child widget upon swipe; instead, it triggers
/// callback functions to handle the swipe actions.
///
/// The swipe action can be confirmed or cancelled based on a user-defined condition
/// specified by the [confirmSwipe] callback. If the condition is met, the respective
/// [onSwipedLeft] or [onSwipedRight] callback is triggered, indicating that the swipe
/// action has been successfully confirmed. Otherwise, if the condition is not met,
/// the corresponding [onSwipeLeftCancelled] or [onSwipeRightCancelled] callback is
/// triggered to indicate that the swipe action has been cancelled.
///
/// Developers can provide a custom [MmSwipeableController] via the [controller] parameter
/// to interact with and control the behavior of the swipeable widget programmatically.
/// {@endtemplate}
///
/// {@template mm_swipeable_example}
///
/// Example usage:
///
/// ```dart
/// final swipeableController = MmSwipeableController();
///
/// MmSwipeable(
///   controller: swipeableController,
///   confirmSwipe: () {
///     // Read the current angle and force values from the controller.
///     final angle = swipeableController.value.angle.abs();
///     final force = swipeableController.value.force.abs();///
///     // Check if the swipe action meets certain conditions.
///     if (angle <= 0.5 && force <= 0.5) {
///       // Swipe action is not strong enough to trigger
///       // the callbacks. Just return `null` to ignore this action.
///       return null;
///     } else {
///       // Swipe action meets the conditions to be confirmed or cancelled.
///       // Perform further checks or logic here...
///     }
///   },
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
///```
/// {@endtemplate}
class MmSwipeable extends StatefulWidget {
  /// A callback function that determines the outcome of the swipe action.
  ///
  /// The [confirmSwipe] method is called when the swipe action is ended and returns
  /// a nullable boolean (`bool?`) value to indicate whether the swipe action should be
  /// confirmed, cancelled, or no action should be taken.
  ///
  /// If the method returns `true`, indicating that the swipe action should be confirmed,
  /// the [onSwipedLeft] or [onSwipedRight] callback will be triggered, depending on the
  /// direction of the swipe.
  ///
  /// If the method returns `false`, indicating that the swipe action should be cancelled,
  /// the [onSwipeLeftCancelled] or [onSwipeRightCancelled] callback will be triggered, and
  /// the widget will animate back to its original position and rotation.
  ///
  /// If the method returns `null`, no callback will be triggered, and the widget will
  /// animate back to its original position and rotation without any further action.
  ///
  /// If developers need to access the angle and force values of the swipe action
  /// in the `confirmSwipe` method, they can retrieve them from the controller
  /// after the swipe action ends. The controller provides the real-time values
  /// of the angle and force as soon as the swipe ends.
  ///
  /// {@macro mm_swipeable_example}
  final bool? Function() confirmSwipe;

  /// Called when the widget is swiped to the left and the swipe action is confirmed.
  /// This callback is triggered only if the [confirmSwipe] method returns `true`.
  ///
  /// {@macro mm_swipeable_example}
  final VoidCallback onSwipedLeft;

  /// Called when the widget is swiped to the right and the swipe action is confirmed.
  /// This callback is triggered only if the [confirmSwipe] method returns `true`.
  ///
  /// {@macro mm_swipeable_example}
  final VoidCallback onSwipedRight;

  /// Called when the widget is swiped to the right and the swipe action is cancelled.
  /// This callback is triggered when the swipe action is cancelled after swiping to the right,
  /// and the [confirmSwipe] method returns `false`.
  ///
  /// {@macro mm_swipeable_example}
  final VoidCallback? onSwipeRightCancelled;

  /// Called when the widget is swiped to the left and the swipe action is cancelled.
  /// This callback is triggered when the swipe action is cancelled after swiping to the left,
  /// and the [confirmSwipe] method returns `false`.
  ///
  /// {@macro mm_swipeable_example}
  final VoidCallback? onSwipeLeftCancelled;

  /// Controller for handling the swipe action of the widget.
  ///
  /// The [controller] parameter allows developers to provide a custom [MmSwipeableController]
  /// to interact with and control the behavior of the swipeable widget programmatically.
  /// By using a controller, developers can programmatically trigger swipe actions, retrieve
  /// real-time values of the angle and force of the swipe action, and listen to changes
  /// in the swipeable widget's state.
  ///
  /// {@macro mm_swipeable_example}
  final MmSwipeableController controller;

  /// The child widget to be swiped.
  final Widget child;

  /// The duration of the swipe animation.
  ///
  /// The [swipeAnimationDuration] parameter specifies the duration of the swipe animation
  /// when the widget is swiped to the left or right. The default value is 2000 milliseconds.
  final Duration swipeAnimationDuration;

  /// The duration of the reset animation.
  ///
  /// The [resetAnimationDuration] parameter specifies the duration of the reset animation
  /// when the widget is animated back to its original position and rotation. The default
  /// value is 1000 milliseconds.
  final Duration resetAnimationDuration;

  /// The duration of the offset animation.
  ///
  /// The [actionOffsetDuration] parameter specifies the duration of the offset
  /// before triggering the swipe callbacks. The default value is 200 milliseconds.
  final Duration actionOffsetDuration;

  /// {@macro mm_swipeable}
  /// {@macro mm_swipeable_example}
  const MmSwipeable({
    required this.confirmSwipe,
    required this.onSwipedLeft,
    required this.onSwipedRight,
    required this.controller,
    required this.child,
    this.onSwipeRightCancelled,
    this.onSwipeLeftCancelled,
    this.swipeAnimationDuration = const Duration(milliseconds: 2000),
    this.resetAnimationDuration = const Duration(milliseconds: 1000),
    this.actionOffsetDuration = const Duration(milliseconds: 200),
    super.key,
  });

  @override
  State<MmSwipeable> createState() {
    return _MmSwipeableState();
  }
}

class _MmSwipeableState extends State<MmSwipeable> {
  static const _rotationScalar = 10;
  static const _forceScalar = 1 / 10;

  Duration animDuration = Duration.zero;
  double xposition = 0;
  double screenWidth = 0;

  @override
  void initState() {
    widget.controller._bind(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final size = context.size;
      if (size != null) {
        setState(() {
          screenWidth = size.width;
        });
      }
    });
    super.initState();
  }

  double _getRotation() {
    if (screenWidth == 0) return 0;
    return xposition / (screenWidth * (pi * 1.5));
  }

  double _getAngle() {
    final rotation = _getRotation();
    return rotation * _rotationScalar;
  }

  void _updateController(double angle, double force) {
    final nAngle = clampDouble(angle, -1, 1);
    final nForce = clampDouble(force, -1, 1);
    widget.controller.value = MmSwipeableSwipeDetails(
      angle: nAngle,
      force: nForce,
    );
  }

  void _swipe() {
    if (!mounted) return;

    void reset() {
      setState(() {
        xposition = 0;
        _updateController(0, 0);
        animDuration = widget.resetAnimationDuration;
      });
    }

    final confirm = widget.confirmSwipe();
    final angle = widget.controller.value.angle;
    final swipedRight = angle > 0;
    final swipedLeft = angle < 0;

    if (confirm == null) {
      reset();
      return;
    }
    setState(() {
      animDuration = widget.swipeAnimationDuration;
      xposition = screenWidth * (swipedRight ? 1 : -1);
    });

    Future.delayed(widget.actionOffsetDuration, () {
      if (!mounted) return;
      reset();

      if (confirm) {
        if (swipedRight) {
          widget.onSwipedRight();
        } else if (swipedLeft) {
          widget.onSwipedLeft();
        }
      } else {
        if (swipedRight) {
          widget.onSwipeRightCancelled?.call();
        } else if (swipedLeft) {
          widget.onSwipeLeftCancelled?.call();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final childWidget = widget.child;
    final width = screenWidth;

    return GestureDetector(
      onPanUpdate: (details) {
        if (!mounted) return;
        setState(() {
          animDuration = Duration.zero;
          xposition += details.delta.dx;
          _updateController(_getAngle(), 0);
        });
      },
      onPanEnd: (details) {
        if (!mounted) return;
        final velx = details.velocity.pixelsPerSecond.dx;
        final force = (velx / width) * _forceScalar;
        final angle = _getAngle();
        _updateController(angle, force);
        _swipe();
      },
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          AnimatedContainer(
            duration: animDuration,
            curve: Curves.elasticOut,
            transform: Matrix4.identity()
              ..translate(xposition, 0)
              ..rotateZ(_getRotation()),
            transformAlignment: Alignment.center,
            child: childWidget,
          ),
        ],
      ),
    );
  }
}
