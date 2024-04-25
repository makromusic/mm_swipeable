import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MmSwipeableController {
  _MmSwipeableState? _swipeableState;
  bool _debugDisposed = false;

  void _bind(_MmSwipeableState state) {
    _swipeableState = state;
  }

  /// Returns [true] if the widget can be swiped.
  bool get canSwipe {
    return _swipeableState?.width != null;
  }

  /// Disposes the controller and releases the resources used by it.
  ///
  /// After calling this method, the controller is not usable anymore.
  void dispose() {
    assert(MmSwipeableController._debugAssertNotDisposed(this));
    assert(() {
      _debugDisposed = true;
      return true;
    }());
    _swipeableState = null;
    if (kFlutterMemoryAllocationsEnabled) {
      FlutterMemoryAllocations.instance.dispatchObjectDisposed(object: this);
    }
  }

  /// Swipes the widget to the left automatically.
  void swipeLeft() {
    assert(
      _swipeableState != null,
      '_swipeableState is null on controller:$hashCode',
    );
    return _swipeableState?._swipeLeft();
  }

  /// Swipes the widget to the right automatically.
  void swipeRight() {
    assert(
      _swipeableState != null,
      '_swipeableState is null on controller:$hashCode',
    );
    return _swipeableState?._swipeRight();
  }

  static bool _debugAssertNotDisposed(MmSwipeableController controller) {
    assert(() {
      if (controller._debugDisposed) {
        throw FlutterError(
          'A ${controller.runtimeType} was used after being disposed.\n'
          'Once you have called dispose() on a ${controller.runtimeType}, it '
          'can no longer be used.',
        );
      }
      return true;
    }());
    return true;
  }
}

/// [MmSwipeable] is a widget that can be swiped to the left or right.
///
/// It doesn't automatically dismiss the widget when it is swiped.
///
/// It's up to the user to confirm the swipe action and dismiss the widget.
///
/// ```dart
/// MmSwipeable(
///   confirmSwipe: (angle, velocity) {
///     return angle.abs() > 0.7 || velocity.abs() > 0.7;
///   },
///   onSwipedLeft: () {
///     print('Swiped Left');
///   },
///   onSwipedRight: () {
///     print('Swiped Right');
///   },
///   child: Container(
///     width: 200,
///     height: 200,
///     color: Colors.blue,
///   ),
/// )
/// ```
class MmSwipeable extends StatefulWidget {
  /// [confirmSwipe] is a callback function that returns a boolean value
  /// to confirm the dismissal of the widget.
  ///
  /// The [angle] parameter is the last angle of the swipe action when
  /// the swipe action is completed. It is a value between -1 and 1.
  ///
  /// The [velocity] parameter is the last velocity of the swipe action
  /// when the swipe action is completed. It is a value between -1 and 1.
  ///
  /// The sign of the [angle] and [velocity] values indicates the direction of the swipe action.
  /// If the value is positive, the swipe action is from left to right. Otherwise, it is from right to left.
  ///
  /// The intensity of the swipe action is determined by the absolute value of the [angle] and [velocity] values.
  ///
  /// [confirmSwipe] must return true if the [onSwipedLeft] or [onSwipedRight]
  /// callback should be triggered. It must return false if the [onSwipeCancelled]
  /// callback should be triggered.
  ///
  /// It is also possible to use custom conditions to determine
  /// whether the swipe action should be confirmed or not.
  ///
  ///
  /// ```dart
  /// confirmSwipe: (angle, velocity) {
  ///   return angle.abs() > 0.7 || velocity.abs() > 0.7;
  /// }
  /// ```
  final bool Function(double angle, double velocity) confirmSwipe;

  /// Called when the widget is swiped to the left and the swipe action is confirmed.
  ///
  /// ```dart
  /// onSwipedLeft: () {
  ///   print('Swiped Left');
  /// },
  /// ```
  final Function() onSwipedLeft;

  /// Called when the widget is swiped to the right and the swipe action is confirmed.
  ///
  /// ```dart
  /// onSwipedRight: () {
  ///   print('Swiped Right');
  /// },
  /// ```
  final Function() onSwipedRight;

  /// Called when the widget is swiped and the swipe action is cancelled.
  ///
  /// ```dart
  /// onSwipeRightCancelled: () {
  ///   print('Swiping Right Cancelled');
  /// },
  final Function()? onSwipeRightCancelled;

  /// Called when the widget is swiped and the swipe action is cancelled.
  ///
  /// ```dart
  /// onSwipeLeftCancelled: () {
  ///   print('Swiping Left Cancelled');
  /// },
  final Function()? onSwipeLeftCancelled;

  /// Controller for handling the swipe action of the widget
  ///
  /// Provides functionality to interact with and control the behavior of the swipeable widget.
  final MmSwipeableController? controller;

  final Widget child;
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
  double rotate = 0;
  double xPosition = 0;
  double yPosition = 0;
  double? width;

  static const Duration swipeDuration = Duration(milliseconds: 2000);
  static const Duration dismissOffset = Duration(milliseconds: 200);

  Duration animationDuration = Duration.zero;

  @override
  void initState() {
    if (widget.controller != null) widget.controller?._bind(this);

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
