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
                      CatCard(
                        key: ValueKey(bottom.key.id),
                        controller: bottom.value,
                        cat: bottom.key,
                      ),
                      CatCard(
                        key: ValueKey(top.key.id),
                        controller: top.value,
                        cat: top.key,
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
    final angle = widget.controller.value.angle;
    setState(() {
      leftTextOpacity = clampDouble(-angle, 0, 1);
      rightTextOpacity = clampDouble(angle, 0, 1);
    });
  }

  void remove(Cat matchData) {
    catProvider.removeCat(matchData);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: catProvider,
      builder: (context, _) {
        return MmSwipeable(
          controller: widget.controller,
          actionOffsetDuration: const Duration(milliseconds: 250),
          swipeAnimationDuration: const Duration(milliseconds: 2000),
          resetAnimationDuration: const Duration(milliseconds: 1200),
          confirmSwipe: () {
            final value = widget.controller.value;
            final angle = value.angle.abs();
            final force = value.force.abs();
            if (angle <= 0.7 && force <= 0.3) {
              return null;
            }
            return true;
          },
          onSwipedRight: () {
            remove(widget.cat);
            // Do anything you want here
          },
          onSwipedLeft: () {
            remove(widget.cat);
            // Do anything you want here
          },
          onSwipeLeftCancelled: () {
            // Do anything you want here
          },
          onSwipeRightCancelled: () {
            // Do anything you want here
          },
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * .8,
                  child: Image.network(
                    widget.cat.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: SizedBox(
                                height: 50,
                                width: 50,
                                child: Image.network(
                                  widget.cat.imageUrl,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              widget.cat.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.cat.about,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
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
          ),
        );
      },
    );
  }
}
