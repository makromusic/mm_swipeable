## 2.1.0

- With `enableHaptics`, a released drag that `confirmSwipe` confirms now also plays a light impact. Programmatic swipes and cancelled swipes play none.

## 2.0.0

- **Breaking:** removed `swipeAnimationDuration`, `resetAnimationDuration` and `actionOffsetDuration`. The card now moves with springs that keep the release velocity.
- The swipe is decided from where the card is heading: the release point is projected forward by the finger's velocity (`projectionTime`, default 200 ms) and commits once it passes `swipeThreshold` (default 35%) of the card's width. Quick short flicks now commit, and the direction follows the motion.
- Only horizontal drags are claimed, so a vertical scrollable inside the card keeps diagonal gestures steeper than 45°.
- The card's rotation follows the grab point (top or bottom half).
- `onSwipedLeft` / `onSwipedRight` fire once the card has left its bounds.
- Added `MmSwipeableSwipeDetails.progress` (-1..1): how far the card is towards the threshold. `swipingLeft` / `swipingRight` read it.
- Added `enableHaptics` (default `true`): a selection click when a drag reaches the threshold.
- Added widget tests.

## 1.0.0+1

- Initial release 🚀.
