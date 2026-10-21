import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mm_swipeable/mm_swipeable.dart';

void main() {
  runApp(const MyApp());
}

class Cat {
  final int id;
  final String name;
  final String about;
  final String imageUrl;

  const Cat({
    required this.id,
    required this.name,
    required this.about,
    required this.imageUrl,
  });

  factory Cat.random1() {
    return Cat(
      id: Random().nextInt(10000),
      name: 'Fluffy',
      about: 'Cute and adorable',
      imageUrl:
          'https://images.pexels.com/photos/2071882/pexels-photo-2071882.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    );
  }

  factory Cat.random2() {
    return Cat(
      id: Random().nextInt(10000),
      name: 'Whiskers',
      about: 'Loves to play',
      imageUrl:
          'https://images.pexels.com/photos/208984/pexels-photo-208984.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    );
  }

  factory Cat.random3() {
    return Cat(
      id: Random().nextInt(10000),
      name: 'Mittens',
      about: 'Very friendly',
      imageUrl:
          'https://images.pexels.com/photos/1521304/pexels-photo-1521304.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    );
  }
}

class CatProvider extends ChangeNotifier {
  final Map<Cat, MmSwipeableController> catsAndControllers = {};

  void initCats() {
    for (var i = 0; i < 20; i++) {
      catsAndControllers[Cat.random1()] = MmSwipeableController();
      catsAndControllers[Cat.random2()] = MmSwipeableController();
      catsAndControllers[Cat.random3()] = MmSwipeableController();
    }
    notifyListeners();
  }

  void removeCat(Cat cat) {
    catsAndControllers.remove(cat);
    notifyListeners();
  }

  @override
  void dispose() {
    for (final controller in catsAndControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}

final catProvider = CatProvider()..initCats();

final swipeThreshold = ValueNotifier(0.35);
final projectionMs = ValueNotifier(200.0);

final swipeSettings = Listenable.merge([swipeThreshold, projectionMs]);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MmSwipeable Demo',
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Image.asset(
          'assets/makromusic_logo_with_text.png',
          height: 30,
        ),
        leading: IconButton(
          icon: const Icon(Icons.tune),
          onPressed: () => showModalBottomSheet<void>(
            context: context,
            builder: (_) => const TuningSheet(),
          ),
        ),
      ),
      body: ListenableBuilder(
        listenable: catProvider,
        builder: (context, _) {
          final catsAndControllers = catProvider.catsAndControllers;
          if (catsAndControllers.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final length = catsAndControllers.length;
          final bottom = catsAndControllers.entries.elementAt(length - 2);
          final top = catsAndControllers.entries.elementAt(length - 1);

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      StackedCard(
                        key: ValueKey(bottom.key.id),
                        cardAbove: top.value,
                        child: CatCard(
                          controller: bottom.value,
                          cat: bottom.key,
                        ),
                      ),
                      StackedCard(
                        key: ValueKey(top.key.id),
                        cardAbove: null,
                        child: CatCard(
                          controller: top.value,
                          cat: top.key,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          catsAndControllers.values.last.swipeLeft();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(24),
                              bottomLeft: Radius.circular(24),
                              topRight: Radius.circular(6),
                              bottomRight: Radius.circular(6),
                            ),
                            color: Color(0xFF0F141E),
                          ),
                          child: const Text(
                            'Nope',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          catsAndControllers.values.last.swipeRight();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(6),
                              bottomLeft: Radius.circular(6),
                              topRight: Radius.circular(24),
                              bottomRight: Radius.circular(24),
                            ),
                            color: Color(0xFF42C0C6),
                          ),
                          child: const Text(
                            'Like',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

const catBio = [
  (
    'ABOUT',
    'Spends mornings on the windowsill judging pigeons, afternoons asleep in '
        'whichever patch of sun is warmest, and evenings demanding dinner '
        'twenty minutes early.',
  ),
  (
    'MUSIC TASTE',
    'Lo-fi beats for napping, jazz for dramatic stretches, and anything with '
        'a bass line that makes the sofa vibrate.',
  ),
  (
    'TOP ARTISTS',
    'Cat Stevens, The Purrfect Circle, Meowdonna, Snoop Catt, Kitty Perry, '
        'Black Sabbath (for the name alone).',
  ),
  (
    'LOOKING FOR',
    'Someone to share a cardboard box with. Must tolerate 3 a.m. zoomies and '
        'knocking glasses off tables as a form of affection.',
  ),
  (
    'FUN FACT',
    'Has never once used the expensive bed. Prefers the box it came in.',
  ),
];

class CatHeader extends StatelessWidget {
  final Cat cat;

  const CatHeader({super.key, required this.cat});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * .55,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(cat.imageUrl, fit: BoxFit.cover),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Color(0xCC000000), Colors.transparent],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  cat.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${cat.about} · scroll for more',
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StackedCard extends StatelessWidget {
  final MmSwipeableController? cardAbove;
  final Widget child;

  const StackedCard({super.key, required this.cardAbove, required this.child});

  @override
  Widget build(BuildContext context) {
    final cardAbove = this.cardAbove;
    if (cardAbove == null) return child;
    return ValueListenableBuilder<MmSwipeableSwipeDetails>(
      valueListenable: cardAbove,
      builder: (context, value, child) {
        final reveal = value.progress.abs();
        return Transform.scale(scale: 0.94 + 0.06 * reveal, child: child);
      },
      child: child,
    );
  }
}

class TuningSheet extends StatelessWidget {
  const TuningSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ListenableBuilder(
          listenable: swipeSettings,
          builder: (context, _) {
            final threshold = swipeThreshold.value;
            final lookAhead = projectionMs.value;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Swipe tuning',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text('Threshold: ${(threshold * 100).round()}% of card width'),
                Slider(
                  value: threshold,
                  min: 0.15,
                  max: 0.6,
                  divisions: 9,
                  onChanged: (v) => swipeThreshold.value = v,
                ),
                Text('Look-ahead: ${lookAhead.round()} ms'),
                Slider(
                  value: lookAhead,
                  min: 0,
                  max: 400,
                  divisions: 16,
                  onChanged: (v) => projectionMs.value = v,
                ),
                Text(
                  'A ${(2 * lookAhead / 1000 * 100).round()}% head start for '
                  'a flick of 2 card-widths per second.',
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class CatCard extends StatefulWidget {
  final MmSwipeableController controller;
  final Cat cat;

  const CatCard({
    super.key,
    required this.controller,
    required this.cat,
  });

  @override
  State<CatCard> createState() => _CatCardState();
}

class _CatCardState extends State<CatCard> {
  double leftTextOpacity = 0;
  double rightTextOpacity = 0;

  @override
  void initState() {
    widget.controller.addListener(updateOpacity);
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.removeListener(updateOpacity);
    super.dispose();
  }

  void updateOpacity() {
    final progress = widget.controller.value.progress;
    setState(() {
      leftTextOpacity = clampDouble(-progress, 0, 1);
      rightTextOpacity = clampDouble(progress, 0, 1);
    });
  }

  void remove(Cat matchData) {
    catProvider.removeCat(matchData);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([catProvider, swipeSettings]),
      builder: (context, _) {
        return MmSwipeable(
          controller: widget.controller,
          swipeThreshold: swipeThreshold.value,
          projectionTime: Duration(milliseconds: projectionMs.value.round()),
          confirmSwipe: () => true,
          onSwipedRight: () => remove(widget.cat),
          onSwipedLeft: () => remove(widget.cat),
          child: cardContent(context),
        );
      },
    );
  }

  Widget cardContent(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * .8,
            child: ColoredBox(
              color: const Color(0xFF0F141E),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CatHeader(cat: widget.cat),
                    for (final (title, body) in catBio)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                color: Color(0xFF42C0C6),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              body,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 12.0,
            horizontal: 24,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AnimatedOpacity(
                opacity: rightTextOpacity,
                duration: Duration.zero,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: const Color(0xFF42C0C6),
                  ),
                  child: const Text(
                    'Like',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              AnimatedOpacity(
                opacity: leftTextOpacity,
                duration: Duration.zero,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: const Color(0xFF0F141E),
                  ),
                  child: const Text(
                    'Nope',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
