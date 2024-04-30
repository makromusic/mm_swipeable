part of mm_swipeable;

class MmSwipeableSwipeDetails {
  const MmSwipeableSwipeDetails({
    required this.angle,
    required this.force,
  });

  factory MmSwipeableSwipeDetails.zero() {
    return const MmSwipeableSwipeDetails(
      angle: 0,
      force: 0,
    );
  }

  final double angle;
  final double force;

  bool get swipingLeft => angle < 0;
  bool get swipingRight => angle > 0;
}

/// Controller for managing the swipe action of the [MmSwipeable] widget.
///
/// The [MmSwipeableController] class provides functionality to interact with and control
/// the behavior of the swipeable widget programmatically. Developers can use an instance
/// of this class to trigger swipe actions and dispose of the controller when it's no longer needed.
class MmSwipeableController extends ValueNotifier<MmSwipeableSwipeDetails> {
  _MmSwipeableState? _swipeableState;
  MmSwipeableController() : super(MmSwipeableSwipeDetails.zero());

  void _bind(_MmSwipeableState state) {
    _swipeableState = state;
  }

  /// Swipes the widget to the left programmatically with a swipe animation.
  ///
  /// This method confirms the swipe action by calling the [confirmSwipe] callback
  /// provided in the corresponding [MmSwipeable] widget. If the condition specified
  /// in the [confirmSwipe] callback is met, indicating that the swipe action should be
  /// confirmed, it automatically triggers the [onSwipedLeft] callback of the [MmSwipeable]
  /// widget, indicating that the widget has been swiped to the left.
  void swipeLeft() {
    assert(
      _swipeableState != null,
      '_swipeableState is null on controller:$hashCode',
    );
    value = const MmSwipeableSwipeDetails(angle: -1.0, force: 0);
    return _swipeableState!._swipe();
  }

  /// Swipes the widget to the right programmatically with a swipe animation.
  ///
  /// This method confirms the swipe action by calling the [confirmSwipe] callback
  /// provided in the corresponding [MmSwipeable] widget. If the condition specified
  /// in the [confirmSwipe] callback is met, indicating that the swipe action should be
  /// confirmed, it automatically triggers the [onSwipedRight] callback of the [MmSwipeable]
  /// widget, indicating that the widget has been swiped to the right.
  void swipeRight() {
    assert(
      _swipeableState != null,
      '_swipeableState is null on controller:$hashCode',
    );
    value = const MmSwipeableSwipeDetails(angle: 1.0, force: 0);
    return _swipeableState!._swipe();
  }
}
