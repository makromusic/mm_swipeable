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
  final Map<MatchData, MmSwipeableController> matchCards = {
    const MatchData(
      id: 1,
      name: 'John Doe',
      bio: 'I am a software engineer',
      imageUrl:
          'https://images.pexels.com/photos/4123018/pexels-photo-4123018.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
    ): MmSwipeableController(),
    const MatchData(
      id: 2,
      name: 'Jane Doe',
      bio: 'I am a content creator',
      imageUrl:
          'https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
    ): MmSwipeableController(),
    const MatchData(
      id: 3,
      name: 'John Doe',
      bio: 'I am a software engineer',
      imageUrl:
          'https://images.pexels.com/photos/1239291/pexels-photo-1239291.jpeg?auto=compress&cs=tinysrgb&w=1200',
    ): MmSwipeableController(),
    const MatchData(
      id: 4,
      name: 'Jane Doe',
      bio: 'I am a software engineer',
      imageUrl:
          'https://images.pexels.com/photos/1043471/pexels-photo-1043471.jpeg?auto=compress&cs=tinysrgb&w=1200',
    ): MmSwipeableController(),
  };

  void removeMatchCard(MatchData matchData) {
    setState(() {
      matchCards.remove(matchData);
    });
  }

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
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  for (int i = 0; i < matchCards.length; i++) ...{
                    MatchCard(
                      controller: matchCards.values.toList()[i],
                      matchData: matchCards.keys.toList()[i],
                      onSwipeRight: () {
                        final matchData = matchCards.keys.toList()[i];
                        removeMatchCard(matchData);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('You accepted ${matchData.name}'),
                        ));
                      },
                      onSwipeLeft: () {
                        final matchData = matchCards.keys.toList()[i];
                        removeMatchCard(matchData);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('You rejected ${matchData.name}'),
                        ));
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
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      matchCards.values.last.swipeLeft();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
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
                        'Reject',
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
                      matchCards.values.last.swipeRight();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
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
                        'Accept',
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
      ),
    );
  }
}

class MatchCard extends StatefulWidget {
  final MmSwipeableController controller;
  final MatchData matchData;
  final Function onSwipeLeft;
  final Function onSwipeRight;

  const MatchCard({
    super.key,
    required this.onSwipeLeft,
    required this.onSwipeRight,
    required this.controller,
    required this.matchData,
  });

  @override
  State<MatchCard> createState() => _MatchCardState();
}

class _MatchCardState extends State<MatchCard> {
  double leftTextOpacity = 0;
  double rightTextOpacity = 0;

  void resetTextOpacity() {
    setState(() {
      leftTextOpacity = 0;
      rightTextOpacity = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MmSwipeable(
      controller: widget.controller,
      confirmSwipe: (angle, velocity) {
        setState(() {
          leftTextOpacity = clampDouble(-angle, 0, 1);
          rightTextOpacity = clampDouble(angle, 0, 1);
        });
        final aangle = angle.abs();
        final avelocity = velocity.abs();
        return aangle > 0.7 || avelocity > 0.7;
      },
      onSwipedRight: () {
        widget.onSwipeRight();
        resetTextOpacity();
      },
      onSwipedLeft: () {
        widget.onSwipeLeft();
        resetTextOpacity();
      },
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * .8,
              child: Image.network(
                widget.matchData.imageUrl,
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
                              widget.matchData.imageUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          widget.matchData.name,
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
                      widget.matchData.bio,
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
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24),
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
                      'Accept',
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
                      'Reject',
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
  }
}

class MatchData {
  final int id;
  final String name;
  final String bio;
  final String imageUrl;

  const MatchData({
    required this.id,
    required this.name,
    required this.bio,
    required this.imageUrl,
  });
}
