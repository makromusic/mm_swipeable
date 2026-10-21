part of '../mm_swipeable.dart';

/// The state of a swipe, published by [MmSwipeableController] while the card
/// moves.
class MmSwipeableSwipeDetails {
  /// Constructs a [MmSwipeableSwipeDetails] with the given values.
  const MmSwipeableSwipeDetails({
    required this.angle,
    required this.force,
    this.progress = 0,
  });

  /// Constructs a [MmSwipeableSwipeDetails] for a card at rest.
  factory MmSwipeableSwipeDetails.zero() {
    return const MmSwipeableSwipeDetails(angle: 0, force: 0);
  }

  /// The card's tilt from its horizontal offset, normalized between -1 and 1.
  ///
  /// -1 is tilted to the left, 1 to the right.
  final double angle;

  /// The horizontal release velocity, normalized between -1 and 1.
  ///
  /// Zero while dragging; set when the finger is released.
  final double force;

  /// How far the card is towards the commit threshold, between -1 and 1.
  ///
  /// While dragging it is the card's offset divided by
  /// `swipeThreshold * width`, so it only grows as the card moves further; a
  /// slow release at -1 or 1 commits. A quick flick can commit earlier: then
  /// it jumps to -1 or 1 on release and stays there while the card flies out.
  /// While the card springs back it follows the card's offset to 0.
  final double progress;

  /// Whether the swipe is heading left.
  ///
  /// Reads [progress], or [angle] when [progress] is 0.
  bool get swipingLeft => (progress != 0 ? progress : angle) < 0;

  /// Whether the swipe is heading right.
  ///
  /// Reads [progress], or [angle] when [progress] is 0.
  bool get swipingRight => (progress != 0 ? progress : angle) > 0;
}

/// Controller for managing the swipe action of an [MmSwipeable] widget.
///
/// Listen to it to follow [MmSwipeableSwipeDetails] while the card moves, and
/// call [swipeLeft] / [swipeRight] to swipe the card programmatically.
class MmSwipeableController extends ValueNotifier<MmSwipeableSwipeDetails> {
  _MmSwipeableState? _swipeableState;

  /// Constructs a [MmSwipeableController] for a card at rest.
  MmSwipeableController() : super(MmSwipeableSwipeDetails.zero());

  void _bind(_MmSwipeableState state) {
    _swipeableState = state;
  }

  void _unbind(_MmSwipeableState state) {
    if (_swipeableState == state) _swipeableState = null;
  }

  /// Swipes the card to the left.
  ///
  /// Asks [MmSwipeable.confirmSwipe] first: `true` flies the card out and
  /// calls [MmSwipeable.onSwipedLeft], `false` nudges it back and calls
  /// [MmSwipeable.onSwipeLeftCancelled], `null` nudges it back silently.
  ///
  /// Does nothing while no [MmSwipeable] is bound, e.g. after it was disposed,
  /// or while the card is being dragged or is already flying out.
  void swipeLeft() => _swipeableState?._swipeProgrammatically(-1);

  /// Swipes the card to the right.
  ///
  /// Asks [MmSwipeable.confirmSwipe] first: `true` flies the card out and
  /// calls [MmSwipeable.onSwipedRight], `false` nudges it back and calls
  /// [MmSwipeable.onSwipeRightCancelled], `null` nudges it back silently.
  ///
  /// Does nothing while no [MmSwipeable] is bound, e.g. after it was disposed,
  /// or while the card is being dragged or is already flying out.
  void swipeRight() => _swipeableState?._swipeProgrammatically(1);
}
