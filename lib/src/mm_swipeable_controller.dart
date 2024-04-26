part of mm_swipeable;

/// Controller for managing the swipe action of the [MmSwipeable] widget.
///
/// The [MmSwipeableController] class provides functionality to interact with and control
/// the behavior of the swipeable widget programmatically. Developers can use an instance
/// of this class to trigger swipe actions, check the swipeability state of the widget, and
/// dispose of the controller when it's no longer needed.
///
/// Example usage:
/// ```dart
/// final swipeController = MmSwipeableController();
///
/// MmSwipeable(
///   controller: swipeController,
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
/// );
/// ```
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
