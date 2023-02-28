import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MmSwipeableController {
  _MmSwipeableState? _swipeableState;

  void _bind(_MmSwipeableState state) {
    _swipeableState = state;
  }

  bool get canSwipe {
    return _swipeableState?.width != null;
  }

  void _dispose() {
    _swipeableState = null;
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
}

class MmSwipeable extends StatefulWidget {
  final bool Function(double angle, double velocity) confirmDismiss;
  final Function(DismissDirection) onDismissed;
  final MmSwipeableController? controller;

  final Widget child;
  const MmSwipeable({
    required this.confirmDismiss,
    required this.child,
    required this.onDismissed,
    this.controller,
    super.key,
  });

  @override
  State<MmSwipeable> createState() {
    return _MmSwipeableState();
  }
}

class _MmSwipeableState extends State<MmSwipeable> {
  double _rotate = 0;
  double _xPosition = 0;
  double _yPosition = 0;
  double? width;

  static const Duration _swipeDuration = Duration(milliseconds: 2000);
  static const Duration _dismissOffset = Duration(milliseconds: 500);

  Duration animationDuration = Duration.zero;

  @override
  void initState() {
    if (widget.controller != null) widget.controller?._bind(this);

    super.initState();
  }

  @override
  void dispose() {
    widget.controller?._dispose();

    super.dispose();
  }

  void swipeRight() {
    setState(() {
      animationDuration = _swipeDuration;
      _rotate = _rotate * 5;
      _xPosition = width! * 2;
      _yPosition = 0;
    });
    Future.delayed(_dismissOffset, () {
      widget.onDismissed(DismissDirection.startToEnd);
      setState(() {
        animationDuration = Duration.zero;
        _rotate = 0;
        _xPosition = 0;
        _yPosition = 0;
      });
      widget.confirmDismiss(0, 0);
    });
  }

  void swipeLeft() {
    setState(() {
      animationDuration = _swipeDuration;
      _rotate = _rotate * 5;
      _xPosition = -(width! * 2);
      _yPosition = 0;
    });
    Future.delayed(_dismissOffset, () {
      widget.onDismissed(DismissDirection.endToStart);
      setState(() {
        animationDuration = Duration.zero;
        _rotate = 0;
        _xPosition = 0;
        _yPosition = 0;
      });
      widget.confirmDismiss(0, 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;

    return GestureDetector(
      onPanUpdate: (details) {
        widget.confirmDismiss(clampDouble((_rotate * 90) / 10, -1, 1), 0);
        setState(() {
          animationDuration = Duration.zero;
          _rotate = _xPosition / (width! * (pi * 1.5));
          _xPosition += details.delta.dx;
          _yPosition += 0;
        });
      },
      onPanEnd: (details) {
        const speedTreshold = 8;
        final velocity = clampDouble(
            (details.velocity.pixelsPerSecond.dx / width!) / speedTreshold,
            -1,
            1);
        final angleReturn = widget.confirmDismiss(
            clampDouble((_rotate * 90) / 10, -1, 1), velocity);
        final swipeRight = (angleReturn && _xPosition > 0);
        final swipeLeft = (angleReturn && _xPosition < 0);
        if (swipeRight) {
          this.swipeRight();
        } else if (swipeLeft) {
          this.swipeLeft();
        } else {
          setState(() {
            animationDuration = const Duration(seconds: 1);
            _rotate = 0;
            _xPosition = 0;
            _yPosition = 0;
          });
          widget.confirmDismiss(0, 0);
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          AnimatedContainer(
            duration: animationDuration,
            curve: Curves.elasticOut,
            transform: Matrix4.identity()
              ..translate(_xPosition, _yPosition)
              ..rotateZ(_rotate),
            transformAlignment: Alignment.center,
            child: widget.child,
          ),
        ],
      ),
    );
  }
}
