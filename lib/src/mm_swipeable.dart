import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MmSwipeable extends StatefulWidget {
  final bool Function(double) confirmDismiss;
  final Function(DismissDirection) onDismissed;
  final Widget child;
  const MmSwipeable({
    required this.confirmDismiss,
    required this.child,
    required this.onDismissed,
    super.key,
  });

  @override
  State<MmSwipeable> createState() => _MmSwipeableState();
}

class _MmSwipeableState extends State<MmSwipeable> {
  double _rotate = 0;
  double _xPosition = 0;
  double _yPosition = 0;

  Duration animationDuration = Duration.zero;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onPanUpdate: (details) {
        widget.confirmDismiss(clampDouble((_rotate * 90) / 10, -1, 1));
        setState(() {
          animationDuration = Duration.zero;
          _rotate = _xPosition / (width * (pi * 1.5));
          _xPosition += details.delta.dx;
          _yPosition += 0;
        });
      },
      onPanEnd: (details) {
        final isFast = (details.velocity.pixelsPerSecond.dx / width) > 8 ||
            (details.velocity.pixelsPerSecond.dx / width) < -8;
        final angleReturn =
            widget.confirmDismiss(clampDouble((_rotate * 90) / 10, -1, 1));
        final swipeRight =
            (angleReturn && _xPosition > 0) || (isFast && _xPosition > 0);
        final swipeLeft =
            (angleReturn && _xPosition < 0) || (isFast && _xPosition < 0);
        if (swipeRight) {
          setState(() {
            animationDuration = const Duration(milliseconds: 3500);
            _rotate = _rotate * 5;
            _xPosition = width * 2;
            _yPosition = 0;
          });
          Future.delayed(const Duration(milliseconds: 100), () {
            widget.onDismissed(DismissDirection.endToStart);
            setState(() {
              animationDuration = Duration.zero;
              _rotate = 0;
              _xPosition = 0;
              _yPosition = 0;
            });
          });
        } else if (swipeLeft) {
          setState(() {
            animationDuration = const Duration(milliseconds: 3500);
            _rotate = _rotate * 5;
            _xPosition = -(width * 2);
            _yPosition = 0;
          });
          Future.delayed(const Duration(milliseconds: 100), () {
            widget.onDismissed(DismissDirection.startToEnd);
            setState(() {
              animationDuration = Duration.zero;
              _rotate = 0;
              _xPosition = 0;
              _yPosition = 0;
            });
          });
        } else {
          setState(() {
            animationDuration = const Duration(seconds: 1);
            _rotate = 0;
            _xPosition = 0;
            _yPosition = 0;
          });
        }
        widget.confirmDismiss(0);
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
