part of mm_swipeable;

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
///  confirmSwipe: (angle, velocity) {
///    return angle.abs() > 0.7 || velocity.abs() > 0.7;
///  },
///  onSwipedLeft: () {
///    print('Swiped Left');
///  },
///  onSwipedRight: () {
///    print('Swiped Right');
///  },
///  child: Container(
///    width: 200,
///    height: 200,
///    color: Colors.blue,
///  ),
///)
///```
class MmSwipeable extends StatefulWidget {
  /// A callback function that returns a boolean value to confirm the dismissal of the widget.
  ///
  /// The [angle] parameter is the last angle of the swipe action when
  /// the swipe action is completed. It is a value between -1 and 1.
  ///
  /// The [velocity] parameter is the last velocity of the swipe action
  /// when the swipe action is completed. It is a value between -1 and 1.
  ///
  /// [confirmSwipe] must return `true` if the [onSwipedLeft] or [onSwipedRight]
  /// callback should be triggered. It must return `false` if the swipe action should be cancelled.
  ///
  /// If the swipe action is cancelled, the [onSwipeRightCancelled] or [onSwipeLeftCancelled]
  /// callback, corresponding to the direction of the cancelled swipe, will be triggered.
  ///
  /// For example, if the swipe action is cancelled after swiping to the right, the
  /// [onSwipeRightCancelled] callback will be triggered. Similarly, if the swipe action
  /// is cancelled after swiping to the left, the [onSwipeLeftCancelled] callback will be triggered.
  final bool Function(double angle, double velocity) confirmSwipe;

  /// Called when the widget is swiped to the left and the swipe action is confirmed.
  /// This callback is triggered only if the [confirmSwipe] method returns `true`.
  final Function() onSwipedLeft;

  /// Called when the widget is swiped to the right and the swipe action is confirmed.
  /// This callback is triggered only if the [confirmSwipe] method returns `true`.
  final Function() onSwipedRight;

  /// Called when the widget is swiped to the right and the swipe action is cancelled.
  /// This callback is triggered when the swipe action is cancelled after swiping to the right,
  /// and the [confirmSwipe] method returns `false`.
  final Function()? onSwipeRightCancelled;

  /// Called when the widget is swiped to the left and the swipe action is cancelled.
  /// This callback is triggered when the swipe action is cancelled after swiping to the left,
  /// and the [confirmSwipe] method returns `false`.
  final Function()? onSwipeLeftCancelled;

  /// Controller for handling the swipe action of the widget.
  ///
  /// The [controller] parameter allows developers to provide a custom [MmSwipeableController]
  /// to interact with and control the behavior of the swipeable widget programmatically.
  /// By using a controller, developers can programmatically trigger swipe actions, check
  /// the swipeability state of the widget, and dispose of the controller when it's no longer needed.
  final MmSwipeableController? controller;

  /// The child widget that can be swiped.
  final Widget child;

  /// Creates a swipeable widget.
  ///
  /// The [confirmSwipe] callback determines whether the swipe action should be confirmed.
  ///
  /// The [onSwipedLeft] and [onSwipedRight] callbacks are triggered when the widget is swiped
  /// to the left or right and the swipe action is confirmed.
  ///
  /// The [onSwipeLeftCancelled] and [onSwipeRightCancelled] callbacks are triggered when
  /// the swipe action is cancelled after swiping to the left or right, respectively.
  ///
  /// The [controller] parameter allows providing a custom [MmSwipeableController]
  /// to interact with and control the behavior of the swipeable widget.
  ///
  /// The [child] parameter specifies the child widget to be swiped.
  const MmSwipeable({
    required this.confirmSwipe,
    required this.onSwipedLeft,
    required this.onSwipedRight,
    required this.child,
    this.onSwipeRightCancelled,
    this.onSwipeLeftCancelled,
    this.controller,
    super.key,
  });

  @override
  State<MmSwipeable> createState() {
    return _MmSwipeableState();
  }
}

class _MmSwipeableState extends State<MmSwipeable> {
  static const swipeDuration = Duration(milliseconds: 2000);
  static const dismissOffset = Duration(milliseconds: 200);

  Duration animationDuration = Duration.zero;
  double rotate = 0;
  double xPosition = 0;
  double yPosition = 0;
  double? width;

  @override
  void initState() {
    if (widget.controller != null) {
      widget.controller?._bind(this);
    }
    super.initState();
  }

  void _swipeRight() {
    if (!mounted) return;

    setState(() {
      animationDuration = swipeDuration;
      rotate = rotate * 5;
      xPosition = width! * 2;
      yPosition = 0;
    });

    Future.delayed(dismissOffset, () {
      if (!mounted) return;
      final dismiss = widget.confirmSwipe(1, 0);
      if (dismiss) {
        widget.onSwipedRight();
      } else {
        setState(() {
          animationDuration = const Duration(seconds: 1);
          rotate = 0;
          xPosition = 0;
          yPosition = 0;
        });
        widget.onSwipeRightCancelled?.call();
      }
    });
  }

  void _swipeLeft() {
    if (!mounted) return;

    setState(() {
      animationDuration = swipeDuration;
      rotate = rotate * 5;
      xPosition = -(width! * 2);
      yPosition = 0;
    });

    Future.delayed(dismissOffset, () {
      if (!mounted) return;
      final dismiss = widget.confirmSwipe(-1, 0);
      if (dismiss) {
        widget.onSwipedLeft();
      } else {
        setState(() {
          animationDuration = const Duration(seconds: 1);
          rotate = 0;
          xPosition = 0;
          yPosition = 0;
        });
        widget.onSwipeLeftCancelled?.call();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    final childWidget = widget.child;

    return GestureDetector(
      onPanUpdate: (details) {
        if (!mounted) return;
        widget.confirmSwipe(clampDouble((rotate * 90) / 10, -1, 1), 0);
        setState(() {
          animationDuration = Duration.zero;
          rotate = xPosition / (width! * (pi * 1.5));
          xPosition += details.delta.dx;
          yPosition += 0;
        });
      },
      onPanEnd: (details) {
        if (!mounted) return;
        const speedTreshold = 8;
        final dx = details.velocity.pixelsPerSecond.dx;
        final velocity = (dx / width!) / speedTreshold;
        final nvelocity = clampDouble(velocity, -1, 1);
        final nangle = clampDouble((rotate * 90) / 10, -1, 1);
        final angleReturn = widget.confirmSwipe(nangle, nvelocity);
        final swipeRight = (angleReturn && xPosition > 0);
        final swipeLeft = (angleReturn && xPosition < 0);

        if (swipeRight) {
          _swipeRight();
        } else if (swipeLeft) {
          _swipeLeft();
        } else {
          widget.confirmSwipe(0, 0);
          setState(() {
            animationDuration = const Duration(seconds: 1);
            rotate = 0;
            xPosition = 0;
            yPosition = 0;
          });
          if (xPosition > 0) {
            widget.onSwipeRightCancelled?.call();
          } else {
            widget.onSwipeLeftCancelled?.call();
          }
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          AnimatedContainer(
            duration: animationDuration,
            curve: Curves.elasticOut,
            transform: Matrix4.identity()
              ..translate(xPosition, yPosition)
              ..rotateZ(rotate),
            transformAlignment: Alignment.center,
            child: childWidget,
          ),
        ],
      ),
    );
  }
}
