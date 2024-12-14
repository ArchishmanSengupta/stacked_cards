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
      'https://picsum.photos/200/300?random=1',
      'https://picsum.photos/200/300?random=2',
      'https://picsum.photos/200/300?random=3',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Stacked Cards Example')),
      body: Center(
        child: StackedCards(
          cardBuilder: (index) {
            if (index >= imageUrls.length) return Container();
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: NetworkImage(imageUrls[index]),
                  fit: BoxFit.cover,
                ),
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
          visibleCards: 3,
        ),
      ),
    );
  }
}
