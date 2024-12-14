library stacked_cards;

import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A widget that displays a stack of cards with swipe functionality.
///
/// The [StackedCards] widget creates a stack of cards that can be swiped left or right.
/// Each card is generated using the [cardBuilder] callback function and can be customized
/// with different dimensions and animations.
///
/// Example:
/// ```dart
/// StackedCards(
///   cardBuilder: (index) => Card(
///     child: Center(
///       child: Text('Card $index'),
///     ),
///   ),
///   cardWidth: 300,
///   cardHeight: 400,
///   visibleCards: 3,
/// )
/// ```
///
/// ## Key Features
/// * Swipeable cards with smooth animations
/// * Customizable card dimensions and spacing
/// * Configurable number of visible cards
/// * Callback function for swipe events
/// * Scale and rotation effects for stacked appearance
///
/// ## Parameters
/// * [cardBuilder]: Required callback that builds each card widget
/// * [cardWidth]: Width of each card (default: 300)
/// * [cardHeight]: Height of each card (default: 400)
/// * [stackSpacing]: Horizontal spacing between stacked cards (default: 15.0)
/// * [swipeDuration]: Duration of the swipe animation (default: 300ms)
/// * [onSwipe]: Callback triggered when a card is swiped, provides the new index
/// * [visibleCards]: Number of cards visible in the stack (default: 3)
class StackedCards extends StatefulWidget {
  /// Callback function to build each card widget
  final Widget Function(int index) cardBuilder;
  
  /// Width of each card
  final double cardWidth;
  
  /// Height of each card
  final double cardHeight;
  
  /// Horizontal spacing between stacked cards
  final double stackSpacing;
  
  /// Duration of the swipe animation
  final Duration swipeDuration;
  
  /// Callback triggered when a card is swiped
  final ValueChanged<int>? onSwipe;
  
  /// Number of cards visible in the stack
  final int visibleCards;

  const StackedCards({
    super.key,
    required this.cardBuilder,
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
  /// Animation controller for card animations
  late final AnimationController _animationController;
  
  /// Index of the current top card
  int _topCardIndex = 0;
  
  /// Starting position of drag gesture
  Offset _dragStartPosition = Offset.zero;
  
  /// Current horizontal drag offset
  double _horizontalDragOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.swipeDuration,
    );
  }

  /// Handles the start of drag gesture
  void _onPanStart(DragStartDetails details) {
    _dragStartPosition = details.globalPosition;
  }

  /// Updates card position during drag
  void _onPanUpdate(DragUpdateDetails details) {
    final horizontalDelta = details.globalPosition.dx - _dragStartPosition.dx;
    setState(() {
      _horizontalDragOffset = horizontalDelta;
    });
  }

  /// Handles drag completion and card snapping
  void _onPanEnd(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond.dx;
    final shouldSwipe = _horizontalDragOffset.abs() > widget.cardWidth / 4 || 
                       velocity.abs() > 300;

    if (shouldSwipe) {
      setState(() {
        if (_horizontalDragOffset > 0) {
          _topCardIndex = (_topCardIndex - 1 + widget.visibleCards) % widget.visibleCards;
        } else {
          _topCardIndex = (_topCardIndex + 1) % widget.visibleCards;
        }
        _horizontalDragOffset = 0;
      });
      widget.onSwipe?.call(_topCardIndex);
    } else {
      setState(() {
        _horizontalDragOffset = 0;
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
          final cardIndex = (_topCardIndex + index) % widget.visibleCards;

          final double scaleOffset = 1.0 - (index * 0.05);
          final double rotationAngle = index * 0.025;
          final double horizontalOffset = index * widget.stackSpacing;

          return Positioned(
            top: index * 2.0,
            left: 0,
            child: Transform.translate(
              offset: Offset(isTopCard ? _horizontalDragOffset : horizontalOffset, 0),
              child: Transform.rotate(
                angle: isTopCard
                    ? (_horizontalDragOffset / widget.cardWidth) * 0.4
                    : rotationAngle,
                child: Transform.scale(
                  scale: scaleOffset,
                  child: SizedBox(
                    height: widget.cardHeight,
                    width: widget.cardWidth,
                    child: widget.cardBuilder(cardIndex),
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
    _animationController.dispose();
    super.dispose();
  }
}
