import 'package:flutter/material.dart';
import 'package:stacked_cards/stacked_cards.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
  const StackedCardsExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stacked Cards Example')),
      body: Center(
        child: SizedBox(
          height: 400,
          child: StackedCards(
            onGenerate: (index) => Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: NetworkImage('https://picsum.photos/200/300?random=$index'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            cardWidth: 300,
            cardHeight: 400,
            stackSpacing: 10.0,
            swipeDuration: const Duration(milliseconds: 300),
            onSwipe: (index) {
              print('Swiped card index: $index');
            },
          ),
        ),
      ),
    );
  }
}
