# MmSwipeable

![Screenshot](assets/screenshot.jpg)

MmSwipeable is a Flutter package that provides a widget for enabling swipe actions in both left and right directions.

## Features

- Allows users to swipe a child widget either to the left or right.
- Does not automatically dismiss the child widget upon swipe; instead, triggers callback functions to handle the swipe actions.
- Enables customization of swipe action confirmation conditions.
- Supports programmatically controlling swipe actions through a dedicated controller.

## Usage

Wrap the widget that you want to make swipeable with the `MmSwipeable` widget and provide the necessary callback functions to handle swipe actions:

```dart
final swipeableController = MmSwipeableController();

MmSwipeable(
  controller: swipeableController,
  swipeAnimationDuration: const Duration(milliseconds: 2000),
  resetAnimationDuration: const Duration(milliseconds: 1000),
  actionOffsetDuration: const Duration(milliseconds: 200),
  confirmSwipe: () {
    // Read the current angle and force values from the controller.
    final angle = swipeableController.value.angle.abs();
    final force = swipeableController.value.force.abs();///
    // Check if the swipe action meets certain conditions.
    if (angle <= 0.5 && force <= 0.5) {
      // Swipe action is not strong enough to trigger
      // the callbacks. Just return `null` to ignore this action.
      return null;
    } else {
     // Swipe action meets the conditions to be confirmed or cancelled.
     // Perform further checks or logic here...
   }
 },
 onSwipedLeft: () {
   // Handle swipe left action.
 },
 onSwipedRight: () {
   // Handle swipe right action.
 },
 onSwipeLeftCancelled: () {
   // Handle swipe left cancellation.
 },
 onSwipeRightCancelled: () {
   // Handle swipe right cancellation.
 },
 child: Container(
   height: 600,
   color: Colors.blue,
 ),
)
```

You can also use a `MmSwipeableController` to programmatically control the behavior of the swipeable widget:

```dart
// Programmatically trigger a swipe right action
swipeController.swipeRight();

// Programmatically trigger a swipe left action
swipeController.swipeLeft();
```

For more details and examples, check out the [example](example) directory.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
