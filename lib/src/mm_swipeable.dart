import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MmSwipeableWidget extends StatefulWidget {
  final bool Function(double) confirmDismiss;
  final Function(DismissDirection) onDismissed;
  final Widget child;
  const MmSwipeableWidget({
    required this.confirmDismiss,
    required this.child,
    required this.onDismissed,
    super.key,
  });

  @override
  State<MmSwipeableWidget> createState() => _MmSwipeableWidgetState();
}

class _MmSwipeableWidgetState extends State<MmSwipeableWidget> {
  double _rotate = 0;
  double _xPosition = 0;
  double _yPosition = 0;

  Duration animationDuration = Duration.zero;
  bool isDismissed = false;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Stack(
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
        GestureDetector(
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
            final angleReturn =
                widget.confirmDismiss(clampDouble((_rotate * 90) / 10, -1, 1));
            final swipeRight = angleReturn && _xPosition > 0;
            final swipeLeft = angleReturn && _xPosition < 0;
            if (swipeRight) {
              setState(() {
                animationDuration = const Duration(seconds: 2);
                _rotate = width / 500;
                _xPosition = width * 2;
                _yPosition = 0;
                isDismissed = true;
              });
              widget.onDismissed(DismissDirection.endToStart);
            } else if (swipeLeft) {
              setState(() {
                animationDuration = const Duration(seconds: 2);
                _rotate = -(width / 500);
                _xPosition = -width * 2;
                _yPosition = 0;
                isDismissed = true;
              });
              widget.onDismissed(DismissDirection.startToEnd);
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
        ),
      ],
    );
  }
}
