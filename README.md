# MmSwipeable

MmSwipeable is a Flutter widget that allows swipe gestures on a child widget, providing dismissible behavior.

## Features

- Supports swipe gestures for dismissing a widget.
- Configurable swipe directions and dismissal actions.
- Provides a customizable UI for smooth and animated swipe transitions.

## Usage

To use MmSwipeable, wrap the desired child widget with it:

```dart
MmSwipeable(
  confirmDismiss: (angle, velocity) {
    // Implement your custom logic to confirm the dismiss action
    // Return true to confirm dismiss, false otherwise
  },
  onDismissed: (direction) {
    // Handle the dismiss action based on the given direction
  },
  onDismissCancelled: () {
    // Optional: Handle the case when the dismiss action is cancelled
  },
  child: YourChildWidget(),
);
```
In the `confirmDismiss` callback, you can implement your custom logic to determine whether the dismiss action should be confirmed. Return `true` to confirm the dismiss, or `false` to cancel it.

The `onDismissed` callback is triggered when the dismiss action is confirmed. You can handle the dismiss action based on the provided direction parameter, which indicates the swipe direction (e.g., `DismissDirection.startToEnd`, `DismissDirection.endToStart`).

Optionally, you can provide an `onDismissCancelled` callback to handle the case when the dismiss action is cancelled. This can happen when the swipe gesture is not strong enough or when the user cancels the swipe before reaching the threshold.

## Getting Started
To use this package, add mm_swipeable as a dependency in your pubspec.yaml file.

## License
This package is released under the MIT License. See the LICENSE file for more details.
