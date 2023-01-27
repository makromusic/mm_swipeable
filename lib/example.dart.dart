import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mm_swipeable/src/mm_swipeable.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List cardList = [
    "https://makronline.com/static/ataberk-83e2822b436da6c6ebd9029e265a946f.png",
    "https://makronline.com/static/atakan-a08126e2344e5c515a7a52706e36b2f1.png",
    "https://makronline.com/static/aybars-74dc4cc06c8d28d0b85aba2d77bd7ebd.jpg",
    "https://makronline.com/static/altan-17f3bac93114f3b72de01badb6c567f6.jpg",
    "https://makronline.com/static/erem-324159ea213143f0b18b471e0c09c488.png",
    "https://makronline.com/static/metehan-8525cc3a41834109482b8821c9352a3b.jpg",
    "https://makronline.com/static/resul-08a9334491899764f9170e7e6c736577.jpg",
    "https://makronline.com/static/aleyna2-a319080c793b6d7f1dc43a035b798a9a.jpg",
    "https://makronline.com/static/zeynep-0d861a3d012dd529e9816e681f9928f6.jpg",
    "https://makronline.com/static/ramazan-0597cdcd3cd4559b0044bc3e203e80b3.jpg",
    "https://makronline.com/static/selim-2a3a55fe31e8f596053a149e1e75ec36.jpg",
    "https://makronline.com/static/ilhan-a9f87234f336f19a511b43078e8b9f34.png",
    "https://makronline.com/static/enes-ali-dfb6a2b54cb5c1416e8a4b1a0e3b21e3.jpg",
    "https://makronline.com/static/hilal2-75af80a1dc341711d10ab1a4935ecae7.jpg",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Swipeable Widget'),
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Stack(
          children: [
            for (String url in cardList) ...{
              MatchCard(
                url: url,
                onSwipe: () {
                  setState(() {
                    cardList.remove(url);
                  });
                },
              )
            },
          ],
        ),
      ),
    );
  }
}

class MatchCard extends StatefulWidget {
  final String url;
  final Function onSwipe;
  const MatchCard({required this.url, required this.onSwipe, super.key});

  @override
  State<MatchCard> createState() => _MatchCardState();
}

class _MatchCardState extends State<MatchCard> {
  double leftTextOpacity = 0;
  double rightTextOpacity = 0;

  @override
  Widget build(BuildContext context) {
    return MmSwipeable(
      confirmDismiss: (angle) {
        setState(() {
          leftTextOpacity = clampDouble(-angle, 0, 1);
          rightTextOpacity = clampDouble(angle, 0, 1);
        });
        if (angle > 0.6) {
          return true;
        } else if (angle < -0.6) {
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
          Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SingleChildScrollView(
                    child: Container(
                      color: Colors.blue,
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              SizedBox(
                                height: MediaQuery.of(context).size.height * .8,
                                child: Image.network(
                                  widget.url,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(100),
                                            child: Image.network(
                                              "https://makronline.com/static/metehan-8525cc3a41834109482b8821c9352a3b.jpg",
                                              height: 32,
                                              width: 32,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Text(
                                            "Metehan Gül",
                                            style: TextStyle(
                                                fontSize: 24,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(60),
                                          color: Colors.purple,
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.star),
                                            const SizedBox(width: 8),
                                            Text(
                                              "Super premium",
                                              style: TextStyle(
                                                  fontSize: 24,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(60),
                                          color: Colors.purple,
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.star),
                                            const SizedBox(width: 8),
                                            Text(
                                              "Super premium",
                                              style: TextStyle(
                                                  fontSize: 24,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(60),
                                              color: Colors.purple,
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(Icons.star),
                                                const SizedBox(width: 8),
                                                Text(
                                                  "Super premium",
                                                  style: TextStyle(
                                                      fontSize: 24,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(60),
                                              color: Colors.purple,
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(Icons.star),
                                                const SizedBox(width: 8),
                                                Text(
                                                  "Super premium",
                                                  style: TextStyle(
                                                      fontSize: 24,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                border: Border.all(
                                                    color: Colors.white,
                                                    width: 2)),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              child: Image.network(
                                                "https://makronline.com/static/metehan-8525cc3a41834109482b8821c9352a3b.jpg",
                                                height: 32,
                                                width: 32,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: const [
                                              Text(
                                                "Aynı anda dinliyorsunuz",
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                "Hep De Yorgun",
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          for (int i = 0; i < 5; i++) ...{
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.25,
                                  width: double.infinity,
                                  child: Image.network(
                                    "https://makronline.com/static/metehan-8525cc3a41834109482b8821c9352a3b.jpg",
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 16),
                                      Text("aksdahdhsakj"),
                                      const SizedBox(height: 8),
                                      Text("alksdkadklsajldas"),
                                    ],
                                  ),
                                )
                              ],
                            )
                          }
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Kabul Et",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.withOpacity(rightTextOpacity)),
                ),
                Text(
                  "Reddet",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.withOpacity(leftTextOpacity)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
