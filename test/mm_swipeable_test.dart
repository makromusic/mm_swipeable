import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mm_swipeable/mm_swipeable.dart';

const cardWidth = 400.0;
const cardHeight = 600.0;
const cardKey = Key('card');
const frame = Duration(milliseconds: 8);

class SwipeRecorder {
  int swipedLeft = 0;
  int swipedRight = 0;
  int leftCancelled = 0;
  int rightCancelled = 0;

  int get total => swipedLeft + swipedRight + leftCancelled + rightCancelled;
}

Widget buildCard({
  required MmSwipeableController controller,
  required SwipeRecorder recorder,
  bool? Function()? confirmSwipe,
  Widget? child,
}) {
  return MaterialApp(
    home: Center(
      child: SizedBox(
        width: cardWidth,
        height: cardHeight,
        child: MmSwipeable(
          controller: controller,
          enableHaptics: false,
          confirmSwipe: confirmSwipe ?? () => true,
          onSwipedLeft: () => recorder.swipedLeft++,
          onSwipedRight: () => recorder.swipedRight++,
          onSwipeLeftCancelled: () => recorder.leftCancelled++,
          onSwipeRightCancelled: () => recorder.rightCancelled++,
          child: child ?? Container(key: cardKey, color: Colors.blue),
        ),
      ),
    ),
  );
}

Future<void> pumpUntil(WidgetTester tester, bool Function() condition) async {
  for (var count = 0; count < 300 && !condition(); count++) {
    await tester.pump(frame);
  }
}

Future<void> pumpForTwoSeconds(WidgetTester tester) async {
  for (var count = 0; count < 250; count++) {
    await tester.pump(frame);
  }
}

/// Moves [gesture] by [dx] in [steps] equal moves, [stepDuration] apart,
/// starting after [startTime]. Returns the time stamp of the last move.
Future<Duration> moveInSteps(
  TestGesture gesture, {
  required double dx,
  required int steps,
  required Duration stepDuration,
  required Duration startTime,
}) async {
  var time = startTime;
  for (var step = 0; step < steps; step++) {
    time += stepDuration;
    await gesture.moveBy(Offset(dx / steps, 0), timeStamp: time);
  }
  return time;
}

/// Drags [distance] in 10px moves 100ms apart and releases after a pause,
/// so the release velocity is zero.
Future<void> dragSlowly(WidgetTester tester, double distance) async {
  final gesture = await tester.startGesture(tester.getCenter(find.byKey(cardKey)));
  final lastMove = await moveInSteps(
    gesture,
    dx: distance,
    steps: (distance.abs() / 10).round(),
    stepDuration: const Duration(milliseconds: 100),
    startTime: Duration.zero,
  );
  await gesture.up(timeStamp: lastMove + const Duration(milliseconds: 200));
}

void main() {
  late MmSwipeableController controller;
  late SwipeRecorder recorder;

  setUp(() {
    controller = MmSwipeableController();
    recorder = SwipeRecorder();
  });

  tearDown(() {
    controller.dispose();
  });

  group('release decision', () {
    testWidgets('a quick short flick to the right commits right',
        (tester) async {
      await tester.pumpWidget(
        buildCard(controller: controller, recorder: recorder),
      );

      await tester.flingFrom(
        tester.getCenter(find.byKey(cardKey)),
        const Offset(80, 0),
        1500,
      );
      await pumpUntil(tester, () => recorder.total > 0);

      expect(recorder.swipedRight, 1);
      expect(recorder.total, 1);
    });

    testWidgets('a quick short flick to the left commits left',
        (tester) async {
      await tester.pumpWidget(
        buildCard(controller: controller, recorder: recorder),
      );

      await tester.flingFrom(
        tester.getCenter(find.byKey(cardKey)),
        const Offset(-80, 0),
        1500,
      );
      await pumpUntil(tester, () => recorder.total > 0);

      expect(recorder.swipedLeft, 1);
      expect(recorder.total, 1);
    });

    testWidgets('a slow nudge snaps back without callbacks', (tester) async {
      await tester.pumpWidget(
        buildCard(controller: controller, recorder: recorder),
      );

      await dragSlowly(tester, 60);
      await pumpForTwoSeconds(tester);

      expect(recorder.total, 0);
      expect(controller.value.progress.abs(), lessThan(0.01));
    });

    testWidgets('a slow drag past the threshold commits', (tester) async {
      await tester.pumpWidget(
        buildCard(controller: controller, recorder: recorder),
      );

      await dragSlowly(tester, 150);
      await pumpUntil(tester, () => recorder.total > 0);

      expect(recorder.swipedRight, 1);
      expect(recorder.total, 1);
    });

    testWidgets('dragging right then flicking back left snaps back',
        (tester) async {
      await tester.pumpWidget(
        buildCard(controller: controller, recorder: recorder),
      );

      final gesture =
          await tester.startGesture(tester.getCenter(find.byKey(cardKey)));
      final draggedRight = await moveInSteps(
        gesture,
        dx: 160,
        steps: 16,
        stepDuration: const Duration(milliseconds: 100),
        startTime: Duration.zero,
      );
      final flickedBack = await moveInSteps(
        gesture,
        dx: -40,
        steps: 4,
        stepDuration: const Duration(milliseconds: 10),
        startTime: draggedRight,
      );
      await gesture.up(timeStamp: flickedBack);
      await pumpForTwoSeconds(tester);

      expect(recorder.total, 0);
      expect(controller.value.progress.abs(), lessThan(0.01));
    });
  });

  group('inner vertical scrollable', () {
    late ScrollController scrollController;

    setUp(() {
      scrollController = ScrollController();
    });

    tearDown(() {
      scrollController.dispose();
    });

    Widget scrollableCard() {
      return buildCard(
        controller: controller,
        recorder: recorder,
        child: SingleChildScrollView(
          key: cardKey,
          controller: scrollController,
          child: Container(height: 3000, color: Colors.blue),
        ),
      );
    }

    Offset flickAt(double degrees) {
      final radians = degrees * pi / 180;
      return Offset(cos(radians) * 150, -sin(radians) * 150);
    }

    testWidgets('a 40 degree flick swipes the card', (tester) async {
      await tester.pumpWidget(scrollableCard());

      await tester.flingFrom(
        tester.getCenter(find.byKey(cardKey)),
        flickAt(40),
        1500,
      );
      await pumpUntil(tester, () => recorder.total > 0);

      expect(recorder.swipedRight, 1);
      expect(scrollController.offset, 0);
    });

    testWidgets('a 60 degree flick scrolls instead of swiping',
        (tester) async {
      await tester.pumpWidget(scrollableCard());

      await tester.flingFrom(
        tester.getCenter(find.byKey(cardKey)),
        flickAt(60),
        1500,
      );
      await pumpForTwoSeconds(tester);

      expect(scrollController.offset, greaterThan(0));
      expect(recorder.total, 0);
    });
  });

  group('confirmSwipe', () {
    testWidgets('false on a right flick calls only the right cancelled callback',
        (tester) async {
      await tester.pumpWidget(
        buildCard(
          controller: controller,
          recorder: recorder,
          confirmSwipe: () => false,
        ),
      );

      await tester.flingFrom(
        tester.getCenter(find.byKey(cardKey)),
        const Offset(80, 0),
        1500,
      );
      await pumpForTwoSeconds(tester);

      expect(recorder.rightCancelled, 1);
      expect(recorder.total, 1);
    });

    testWidgets('false on a left flick calls only the left cancelled callback',
        (tester) async {
      await tester.pumpWidget(
        buildCard(
          controller: controller,
          recorder: recorder,
          confirmSwipe: () => false,
        ),
      );

      await tester.flingFrom(
        tester.getCenter(find.byKey(cardKey)),
        const Offset(-80, 0),
        1500,
      );
      await pumpForTwoSeconds(tester);

      expect(recorder.leftCancelled, 1);
      expect(recorder.total, 1);
    });

    testWidgets('null calls no callback', (tester) async {
      await tester.pumpWidget(
        buildCard(
          controller: controller,
          recorder: recorder,
          confirmSwipe: () => null,
        ),
      );

      await tester.flingFrom(
        tester.getCenter(find.byKey(cardKey)),
        const Offset(80, 0),
        1500,
      );
      await pumpForTwoSeconds(tester);

      expect(recorder.total, 0);
      expect(controller.value.progress.abs(), lessThan(0.01));
    });
  });

  group('controller', () {
    testWidgets('swipeRight swipes the card right', (tester) async {
      await tester.pumpWidget(
        buildCard(controller: controller, recorder: recorder),
      );

      controller.swipeRight();
      await pumpUntil(tester, () => recorder.total > 0);

      expect(recorder.swipedRight, 1);
      expect(recorder.total, 1);
    });

    testWidgets('swipeLeft swipes the card left', (tester) async {
      await tester.pumpWidget(
        buildCard(controller: controller, recorder: recorder),
      );

      controller.swipeLeft();
      await pumpUntil(tester, () => recorder.total > 0);

      expect(recorder.swipedLeft, 1);
      expect(recorder.total, 1);
    });

    testWidgets('swipes are no-ops after the swipeable is disposed',
        (tester) async {
      await tester.pumpWidget(
        buildCard(controller: controller, recorder: recorder),
      );
      await tester.pumpWidget(const SizedBox());

      controller.swipeRight();
      controller.swipeLeft();
      await pumpForTwoSeconds(tester);

      expect(recorder.total, 0);
    });
  });

  group('progress', () {
    testWidgets('reaches 1 when a slow drag reaches the threshold',
        (tester) async {
      await tester.pumpWidget(
        buildCard(controller: controller, recorder: recorder),
      );

      final gesture =
          await tester.startGesture(tester.getCenter(find.byKey(cardKey)));
      final belowThreshold = await moveInSteps(
        gesture,
        dx: 130,
        steps: 13,
        stepDuration: const Duration(milliseconds: 100),
        startTime: Duration.zero,
      );
      expect(controller.value.progress, lessThan(1));

      await moveInSteps(
        gesture,
        dx: 10,
        steps: 1,
        stepDuration: const Duration(milliseconds: 100),
        startTime: belowThreshold,
      );
      expect(controller.value.progress, 1);

      await gesture.up();
      await pumpUntil(tester, () => recorder.total > 0);
    });

    testWidgets('never decreases between a committing release and the swipe',
        (tester) async {
      await tester.pumpWidget(
        buildCard(controller: controller, recorder: recorder),
      );

      final gesture =
          await tester.startGesture(tester.getCenter(find.byKey(cardKey)));
      final lastMove = await moveInSteps(
        gesture,
        dx: 80,
        steps: 8,
        stepDuration: const Duration(milliseconds: 6),
        startTime: Duration.zero,
      );
      expect(controller.value.progress, lessThan(1));

      final progressAfterRelease = <double>[];
      void recordProgress() {
        if (recorder.total == 0) {
          progressAfterRelease.add(controller.value.progress);
        }
      }

      controller.addListener(recordProgress);
      await gesture.up(timeStamp: lastMove);
      await pumpUntil(tester, () => recorder.total > 0);
      controller.removeListener(recordProgress);

      expect(recorder.swipedRight, 1);
      expect(progressAfterRelease, isNotEmpty);
      expect(progressAfterRelease.first, 1);
      for (var index = 1; index < progressAfterRelease.length; index++) {
        expect(
          progressAfterRelease[index],
          greaterThanOrEqualTo(progressAfterRelease[index - 1]),
        );
      }
    });
  });
}
