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

class StackedCardsExample extends StatelessWidget {
  const StackedCardsExample({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> imageUrls = [
      'https://picsum.photos/1080/1920?random=1',
      'https://picsum.photos/1080/1920?random=2',
      'https://picsum.photos/1080/1920?random=3',
      'https://picsum.photos/1080/1920?random=4',
      'https://picsum.photos/1080/1920?random=5',
    ];

    return Scaffold(
      body: Padding(
        padding:
            EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.25),
        child: Center(
          child: StackedCards(
            cardBuilder: (index) {
              if (index >= imageUrls.length) return Container();
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
                            image: NetworkImage(imageUrls[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const Text(
                      'Nights & Weekends',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      '2:22 AM, SF, CA',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Streak No. 678',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.orange,
                          ),
                        ),
                        SizedBox(width: 5),
                        Icon(
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
            visibleCards: imageUrls.length,
          ),
        ),
      ),
    );
  }
}
