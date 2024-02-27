import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MmSwipeableController {
  _MmSwipeableState? _swipeableState;
  bool _debugDisposed = false;

  void _bind(_MmSwipeableState state) {
    _swipeableState = state;
  }

  bool get canSwipe {
    return _swipeableState?.width != null;
  }

  void dispose() {
    assert(MmSwipeableController._debugAssertNotDisposed(this));
    assert(() {
      _debugDisposed = true;
      return true;
    }());
    _swipeableState = null;
    if (kFlutterMemoryAllocationsEnabled) {
      MemoryAllocations.instance.dispatchObjectDisposed(object: this);
    }
  }

  void swipeLeft() {
    assert(
      _swipeableState != null,
      '_swipeableState is null on controller:$hashCode',
    );
    return _swipeableState?.swipeLeft();
  }

  void swipeRight() {
    assert(
      _swipeableState != null,
      '_swipeableState is null on controller:$hashCode',
    );
    return _swipeableState?.swipeRight();
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

class MmSwipeable extends StatefulWidget {
  final bool Function(double angle, double velocity) confirmDismiss;
  final Function(DismissDirection) onDismissed;
  final Function(DismissDirection)? onDismissCancelled;
  final MmSwipeableController? controller;

  final Widget child;
  const MmSwipeable({
    required this.confirmDismiss,
    required this.child,
    required this.onDismissed,
    this.onDismissCancelled,
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

  void swipeRight() {
    if (!mounted) return;
    setState(() {
      animationDuration = swipeDuration;
      rotate = rotate * 5;
      xPosition = width! * 2;
      yPosition = 0;
    });

    Future.delayed(dismissOffset, () {
      if (!mounted) return;
      final dismiss = widget.confirmDismiss(1, 0);
      if (dismiss) {
        widget.onDismissed(DismissDirection.startToEnd);
      } else {
        setState(() {
          animationDuration = const Duration(seconds: 1);
          rotate = 0;
          xPosition = 0;
          yPosition = 0;
        });
        widget.onDismissCancelled?.call(DismissDirection.startToEnd);
      }
    });
  }

  void swipeLeft() {
    if (!mounted) return;
    setState(() {
      animationDuration = swipeDuration;
      rotate = rotate * 5;
      xPosition = -(width! * 2);
      yPosition = 0;
    });

    Future.delayed(dismissOffset, () {
      if (!mounted) return;
      final dismiss = widget.confirmDismiss(-1, 0);
      if (dismiss) {
        widget.onDismissed(DismissDirection.endToStart);
      } else {
        setState(() {
          animationDuration = const Duration(seconds: 1);
          rotate = 0;
          xPosition = 0;
          yPosition = 0;
        });
        widget.onDismissCancelled?.call(DismissDirection.endToStart);
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
        widget.confirmDismiss(clampDouble((rotate * 90) / 10, -1, 1), 0);
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
        final angleReturn = widget.confirmDismiss(nangle, nvelocity);
        final swipeRight = (angleReturn && xPosition > 0);
        final swipeLeft = (angleReturn && xPosition < 0);

        if (swipeRight) {
          this.swipeRight();
        } else if (swipeLeft) {
          this.swipeLeft();
        } else {
          final cancelDirection = xPosition > 0
              ? DismissDirection.startToEnd
              : DismissDirection.endToStart;
          widget.confirmDismiss(0, 0);
          setState(() {
            animationDuration = const Duration(seconds: 1);
            rotate = 0;
            xPosition = 0;
            yPosition = 0;
          });
          widget.onDismissCancelled?.call(cancelDirection);
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
