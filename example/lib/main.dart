import 'package:flutter/material.dart';
import 'package:stacked_cards/stacked_cards.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stacked Cards',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const StackedCardsExample(),
    );
  }
}

class CardModel {
  final String imageUrl;
  final String title;
  final String timeAndLoc;
  final String streak;

  const CardModel({
    required this.imageUrl,
    required this.title,
    required this.timeAndLoc,
    required this.streak,
  });
}

class StackedCardsExample extends StatelessWidget {
  const StackedCardsExample({super.key});

  static const List<CardModel> cards = [
    CardModel(
      title: 'Nights & Weekends',
      timeAndLoc: '2:22 AM, SF, CA',
      streak: 'Streak No. 678',
      imageUrl: 'https://picsum.photos/712/400?random=1',
    ),
    CardModel(
      title: 'Gym Workout',
      timeAndLoc: '1:20 AM, SF, CA',
      streak: 'Streak No. 212',
      imageUrl: 'https://picsum.photos/712/400?random=2',
    ),
    CardModel(
      title: 'Morning Run',
      timeAndLoc: '6:00 AM, SF, CA',
      streak: 'Streak No. 123',
      imageUrl: 'https://picsum.photos/712/400?random=3',
    ),
    CardModel(
      title: 'Evening Walk',
      timeAndLoc: '7:00 PM, SF, CA',
      streak: 'Streak No. 456',
      imageUrl: 'https://picsum.photos/712/400?random=4',
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding:
            EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.25),
        child: Center(
          child: StackedCards(
            cardBuilder: (index) {
              if (index >= cards.length) return Container();
              return Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(16)),
                          image: DecorationImage(
                            image: NetworkImage(cards[index].imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      cards[index].title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      cards[index].timeAndLoc,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          cards[index].streak,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Icon(
                          Icons.local_fire_department,
                          color: Colors.orange,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
            cardWidth: 300,
            cardHeight: 400,
            stackSpacing: 10.0,
            swipeDuration: const Duration(milliseconds: 300),
            onSwipe: (index) {
              print('Swiped card index: $index');
            },
            visibleCards: cards.length,
          ),
        ),
      ),
    );
  }
}
