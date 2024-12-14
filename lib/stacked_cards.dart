library stacked_cards;

import 'dart:math' as math;

import 'package:flutter/material.dart';

class StackedCards extends StatefulWidget {
  final Widget Function(int index) onGenerate;
  final double cardWidth;
  final double cardHeight;
  final double stackSpacing;
  final Duration swipeDuration;
  final ValueChanged<int>? onSwipe;
  final int visibleCards;

  const StackedCards({
    super.key,
    required this.onGenerate,
    this.cardWidth = 300,
    this.cardHeight = 400,
    this.stackSpacing = 15.0,
    this.swipeDuration = const Duration(milliseconds: 300),
    this.onSwipe,
    this.visibleCards = 3,
  });

  @override
  State<StackedCards> createState() => _StackedCardsState();
}

class _StackedCardsState extends State<StackedCards>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  int _currentIndex = 0;
  Offset _dragStart = Offset.zero;
  double _dragPosition = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.swipeDuration,
    );
  }

  void _onPanStart(DragStartDetails details) {
    _dragStart = details.globalPosition;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final dx = details.globalPosition.dx - _dragStart.dx;
    setState(() {
      _dragPosition = dx;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond.dx;
    if (_dragPosition.abs() > widget.cardWidth / 4 || velocity.abs() > 300) {
      setState(() {
        if (_dragPosition > 0) {
          _currentIndex =
              (_currentIndex - 1 + widget.visibleCards) % widget.visibleCards;
        } else {
          _currentIndex = (_currentIndex + 1) % widget.visibleCards;
        }
        _dragPosition = 0;
      });
      if (widget.onSwipe != null) {
        widget.onSwipe!(_currentIndex);
      }
    } else {
      setState(() {
        _dragPosition = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Stack(
        clipBehavior: Clip.none,
        children: List.generate(widget.visibleCards, (index) {
          final isTopCard = index == 0;
          final cardIndex =
              (_currentIndex + index) % widget.visibleCards;

          final double scale = 1.0 - (index * 0.05);
          final double rotation = index * 0.025;
          final double translateX = index * widget.stackSpacing;

          return Positioned(
            top: index * 2.0,
            left: 0,
            child: Transform.translate(
              offset: Offset(isTopCard ? _dragPosition : translateX, 0),
              child: Transform.rotate(
                angle: isTopCard
                    ? (_dragPosition / widget.cardWidth) * 0.4
                    : rotation,
                child: Transform.scale(
                  scale: scale,
                  child: SizedBox(
                    height: widget.cardHeight,
                    width: widget.cardWidth,
                    child: widget.onGenerate(cardIndex),
                  ),
                ),
              ),
            ),
          );
        }).toList().reversed.toList(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
