part of mm_swipeable;

/// Data class representing the details of a swipe action.
///
/// The [MmSwipeableSwipeDetails] class encapsulates information about a swipe action,
/// including the angle and force of the swipe. Instances of this class are immutable
/// and can be used to pass swipe details between components.
class MmSwipeableSwipeDetails {
  /// Constructs a [MmSwipeableSwipeDetails] instance with the given angle and force.
  ///
  /// The [angle] parameter represents the angle of the swipe action, normalized
  /// between -1 and 1, where -1 indicates swiping left and 1 indicates swiping right.
  ///
  /// The [force] parameter represents the force of the swipe action, normalized
  /// between -1 and 1, where -1 indicates a weak swipe and 1 indicates a strong swipe.
  const MmSwipeableSwipeDetails({
    required this.angle,
    required this.force,
  });

  /// Constructs a [MmSwipeableSwipeDetails] instance with zero angle and force.
  factory MmSwipeableSwipeDetails.zero() {
    return const MmSwipeableSwipeDetails(
      angle: 0,
      force: 0,
    );
  }

  /// The angle of the swipe action, normalized between -1 and 1.
  ///
  /// -1 indicates swiping left, 0 indicates no horizontal movement,
  /// and 1 indicates swiping right.
  final double angle;

  /// The force of the swipe action, normalized between -1 and 1.
  ///
  /// -1 indicates a weak swipe, 0 indicates no force,
  /// and 1 indicates a strong swipe.
  final double force;

  /// Indicates whether the swipe action is towards the left direction.
  bool get swipingLeft => angle < 0;

  /// Indicates whether the swipe action is towards the right direction.
  bool get swipingRight => angle > 0;
}

/// Controller for managing the swipe action of the [MmSwipeable] widget.
///
/// The [MmSwipeableController] class provides functionality to interact with and control
/// the behavior of the swipeable widget programmatically. Developers can use an instance
/// of this class to trigger swipe actions and dispose of the controller when it's no longer needed.
class MmSwipeableController extends ValueNotifier<MmSwipeableSwipeDetails> {
  _MmSwipeableState? _swipeableState;

  /// Constructs a [MmSwipeableController] instance with initial swipe details set to zero.
  MmSwipeableController() : super(MmSwipeableSwipeDetails.zero());

  /// Binds the controller to the given [_MmSwipeableState] instance.
  ///
  /// This method should be called to establish a connection between the controller
  /// and the corresponding [MmSwipeable] widget's state.
  void _bind(_MmSwipeableState state) {
    _swipeableState = state;
  }

  /// Swipes the widget to the left programmatically with a swipe animation.
  ///
  /// This method confirms the swipe action by updating the value of the controller
  /// with a swipe detail indicating a left swipe, and then triggers the swipe animation
  /// in the corresponding [MmSwipeable] widget's state.
  void swipeLeft() {
    assert(
      _swipeableState != null,
      'MmSwipeableController.swipeLeft(): Make sure to bind this controller to a MmSwipeable widget '
      'before using it.',
    );
    value = const MmSwipeableSwipeDetails(angle: -1.0, force: 0);
    return _swipeableState!._swipe();
  }

  /// Swipes the widget to the right programmatically with a swipe animation.
  ///
  /// This method confirms the swipe action by updating the value of the controller
  /// with a swipe detail indicating a right swipe, and then triggers the swipe animation
  /// in the corresponding [MmSwipeable] widget's state.
  void swipeRight() {
    assert(
      _swipeableState != null,
      'MmSwipeableController.swipeRight(): Make sure to bind this controller to a MmSwipeable widget '
      'before using it.',
    );
    value = const MmSwipeableSwipeDetails(angle: 1.0, force: 0);
    return _swipeableState!._swipe();
  }
}
