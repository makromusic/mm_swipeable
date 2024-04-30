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
///
/// Example usage:
///
/// ```dart
///MmSwipeable(
///  confirmSwipe: (angle, force) {
///    // Check if the swipe action should be confirmed or cancelled.
///    // You can use the angle and force parameters to determine the
///    // sensitivity of the swipe action.
///    // You can also use custom conditions to confirm or cancel the swipe action.
///    return angle.abs() > 0.5 || force.abs() > 0.5;
///  },
///  onSwipedLeft: () {
///    // Handle swipe left action.
///  },
///  onSwipedRight: () {
///    // Handle swipe right action.
///  },
///  onSwipeLeftCancelled: () {
///    // Handle swipe left cancellation.
///  },
///  onSwipeRightCancelled: () {
///    // Handle swipe right cancellation.
///  },
///  child: Container(
///    width: 200,
///    height: 200,
///    color: Colors.blue,
///  ),
///)
///```
/// {@endtemplate}
class MmSwipeable extends StatefulWidget {
  /// A callback function that returns a boolean value to confirm the dismissal of the widget.
  ///
  /// The [angle] parameter is the last angle of the swipe action when
  /// the swipe action is completed. It is a value between -1 and 1.
  ///
  /// The [force] parameter is how strong the swipe action was performed
  /// when the swipe action is completed. It is a value between -1 and 1.
  ///
  /// It must return `true` if the [onSwipedLeft] or [onSwipedRight]
  /// callback should be triggered. It must return `false` if the [onSwipeLeftCancelled]
  /// or [onSwipeRightCancelled] callback should be triggered.
  ///
  /// If the swipe action is confirmed, the [onSwipedLeft] or [onSwipedRight] callback,
  /// corresponding to the direction of the swipe, will be triggered.
  ///
  /// If the swipe action is cancelled, the [onSwipeRightCancelled] or [onSwipeLeftCancelled]
  /// callback, corresponding to the direction of the cancelled swipe, will be triggered.
  ///
  /// Example usage:
  ///
  /// ```dart
  ///  confirmSwipe: (angle, force) {
  ///    return angle.abs() > 0.5 || force.abs() > 0.5;
  ///  },
  /// ```
  final bool? Function() confirmSwipe;

  /// Called when the widget is swiped to the left and the swipe action is confirmed.
  /// This callback is triggered only if the [confirmSwipe] method returns `true`.
  final VoidCallback onSwipedLeft;

  /// Called when the widget is swiped to the right and the swipe action is confirmed.
  /// This callback is triggered only if the [confirmSwipe] method returns `true`.
  final VoidCallback onSwipedRight;

  /// Called when the widget is swiped to the right and the swipe action is cancelled.
  /// This callback is triggered when the swipe action is cancelled after swiping to the right,
  /// and the [confirmSwipe] method returns `false`.
  final VoidCallback? onSwipeRightCancelled;

  /// Called when the widget is swiped to the left and the swipe action is cancelled.
  /// This callback is triggered when the swipe action is cancelled after swiping to the left,
  /// and the [confirmSwipe] method returns `false`.
  final VoidCallback? onSwipeLeftCancelled;

  /// Controller for handling the swipe action of the widget.
  ///
  /// The [controller] parameter allows developers to provide a custom [MmSwipeableController]
  /// to interact with and control the behavior of the swipeable widget programmatically.
  /// By using a controller, developers can programmatically trigger swipe actions and dispose
  /// the controller when it's no longer needed.
  final MmSwipeableController controller;

  /// The child widget to be swiped.
  final Widget child;

  /// {@macro mm_swipeable}
  const MmSwipeable({
    required this.confirmSwipe,
    required this.onSwipedLeft,
    required this.onSwipedRight,
    required this.controller,
    required this.child,
    this.onSwipeRightCancelled,
    this.onSwipeLeftCancelled,
    super.key,
  });

  @override
  State<MmSwipeable> createState() {
    return _MmSwipeableState();
  }
}

class _MmSwipeableState extends State<MmSwipeable> {
  static const _swipeDuration = Duration(milliseconds: 2000);
  static const _resetDuration = Duration(milliseconds: 1000);
  static const _offsetDuration = Duration(milliseconds: 100);
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
        animDuration = _resetDuration;
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
      animDuration = _swipeDuration;
      xposition = screenWidth * (swipedRight ? 1 : -1);
    });

    Future.delayed(_offsetDuration, () {
      if (!mounted) return;

      if (confirm) {
        if (swipedRight) {
          widget.onSwipedRight();
        } else if (swipedLeft) {
          widget.onSwipedLeft();
        }
      } else {
        reset();
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
