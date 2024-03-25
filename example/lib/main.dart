import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mm_swipeable/mm_swipeable.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List cardList = [];

  List<MmSwipeableController> controllers = [];

  @override
  void initState() {
    cardList = List.generate(10,
        (index) => 'https://picsum.photos/id/${index * index * 10}/200/300');

    controllers = List<MmSwipeableController>.generate(
      cardList.length,
      (index) => MmSwipeableController(),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Swipeable Widget'),
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  for (int i = 0; i < cardList.length; i++) ...{
                    MatchCard(
                      controller: controllers[i],
                      url: cardList[i],
                      onSwipe: () {
                        setState(() {
                          cardList.remove(cardList[i]);
                          controllers.remove(controllers[i]);
                        });
                      },
                    )
                  },
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    controllers.last.swipeLeft();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                  ),
                  child: const Text('Swipe Left'),
                ),
                ElevatedButton(
                  onPressed: () {
                    controllers.last.swipeRight();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                  ),
                  child: const Text('Swipe Right'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class MatchCard extends StatefulWidget {
  final MmSwipeableController controller;
  final String url;
  final Function onSwipe;

  const MatchCard(
      {required this.url,
      required this.onSwipe,
      super.key,
      required this.controller});

  @override
  State<MatchCard> createState() => _MatchCardState();
}

class _MatchCardState extends State<MatchCard> {
  double leftTextOpacity = 0;
  double rightTextOpacity = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MmSwipeable(
      controller: widget.controller,
      confirmDismiss: (angle, velocity) {
        setState(() {
          leftTextOpacity = clampDouble(-angle, 0, 1);
          rightTextOpacity = clampDouble(angle, 0, 1);
        });
        if (angle > 0.7 || velocity > 0.7) {
          return true;
        } else if (angle < -0.7 || velocity < -0.7) {
          return true;
        }
        return false;
      },
      onDismissed: (direction) {
        setState(() {
          leftTextOpacity = 0;
          rightTextOpacity = 0;
        });
        if (direction == DismissDirection.endToStart) {
          widget.onSwipe();
        } else if (direction == DismissDirection.startToEnd) {
          widget.onSwipe();
        }
      },
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * .8,
              child: Image.network(
                widget.url,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AnimatedOpacity(
                  opacity: rightTextOpacity,
                  duration: Duration.zero,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: const Text(
                      "Accept",
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green),
                    ),
                  ),
                ),
                AnimatedOpacity(
                    opacity: leftTextOpacity,
                    duration: Duration.zero,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: const Text(
                        "Reject",
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.red),
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
