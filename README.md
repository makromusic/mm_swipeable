# MmSwipeable

![Screenshot](assets/screenshot.jpg)

MmSwipeable is a Flutter package that provides a widget for enabling swipe actions in both left and right directions.

## Features

- Allows users to swipe a child widget either to the left or right.
- Does not automatically dismiss the child widget upon swipe; instead, triggers callback functions to handle the swipe actions.
- Enables customization of swipe action confirmation conditions.
- Supports programmatically controlling swipe actions through a dedicated controller.

## Installation

To use this package, add `mm_swipeable` as a dependency in your `pubspec.yaml` file:

```yaml
dependencies:
  mm_swipeable: ^1.0.0
```

Then import the package in your Dart code:

```dart
import 'package:mm_swipeable/mm_swipeable.dart';
```

## Usage
Wrap the widget that you want to make swipeable with the `MmSwipeable` widget and provide the necessary callback functions to handle swipe actions:

```dart
MmSwipeable(
  confirmSwipe: (angle, force) {
    return angle.abs() > 0.5 || force.abs() > 0.5;
  },
  onSwipedLeft: () {
    print('Swiped Left');
  },
  onSwipedRight: () {
    print('Swiped Right');
  },
  child: Container(
    width: 200,
    height: 200,
    color: Colors.blue,
  ),
)
```

You can also use a `MmSwipeableController` to programmatically control the behavior of the swipeable widget:

```dart
// Create a controller
final swipeController = MmSwipeableController();
...

// Use the controller with the MmSwipeable widget
MmSwipeable(
  controller: swipeController,
  confirmSwipe: (angle, force) {
    return angle.abs() > 0.5 || force.abs() > 0.5;
  },
  onSwipedLeft: () {
    print('Swiped Left');
  },
  onSwipedRight: () {
    print('Swiped Right');
  },
  child: Container(
    width: 200,
    height: 200,
    color: Colors.blue,
  ),
)

...

// Programmatically trigger a swipe right action
swipeController.swipeRight();

// Programmatically trigger a swipe left action
swipeController.swipeLeft();

```

For more details and examples, check out the [example](example) directory.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
