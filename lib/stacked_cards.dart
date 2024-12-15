library stacked_cards;

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
/// * [cardCount]: Number of cards visible in the stack (default: 3)

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
  final int cardCount;

  const StackedCards({
    super.key,
    required this.cardBuilder,
    this.cardWidth = 300,
    this.cardHeight = 400,
    this.stackSpacing = 20.0,
    this.swipeDuration = const Duration(milliseconds: 300),
    this.onSwipe,
    this.cardCount = 3,
  });

  @override
  State<StackedCards> createState() => _StackedCardsState();
}

class _StackedCardsState extends State<StackedCards>
    with SingleTickerProviderStateMixin {
  late int _currentIndex;
  late final _initialIndex = 0;

  /// Starting position of drag gesture
  Offset _dragStartPosition = Offset.zero;

  /// Current horizontal drag offset
  double _horizontalDragOffset = 0.0;

  double get _horizontalDragProgress =>
      _horizontalDragOffset / widget.cardWidth;

  late final List<int> _cardIndices =
      List.generate(widget.cardCount, (index) => index);

  late AnimationController _controller;
  Animation<double>? _swipeAnimation;

  @override
  void initState() {
    super.initState();
    _currentIndex = _initialIndex;
    _controller = AnimationController(
      vsync: this,
      duration: widget.swipeDuration,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Handles the start of drag gesture
  void _onPanStart(DragStartDetails details) {
    setState(() {
      _dragStartPosition = details.globalPosition;
    });
  }

  /// Updates card position during drag
  void _onPanUpdate(DragUpdateDetails details, int index) {
    if (index != _currentIndex) return;

    setState(() {
      _horizontalDragOffset = details.globalPosition.dx - _dragStartPosition.dx;
    });
  }

  /// Handles drag completion and card snapping
  void _onPanEnd(DragEndDetails details, int index) {
    if (index != _currentIndex) return;

    final velocity = details.velocity.pixelsPerSecond.dx;
    final threshold = widget.cardWidth / 2;

    if (_horizontalDragOffset.abs() > threshold || velocity.abs() > 1000) {
      final direction = _horizontalDragOffset.isNegative ? -1 : 1;
      if ((_currentIndex == 0 && direction == 1) ||
          (_currentIndex == widget.cardCount - 1 && direction == -1)) {
        _resetCard();
      } else {
        _swipeCard(direction);
      }
    } else {
      _resetCard();
    }
  }

  void _swipeCard(int direction) {
    _swipeAnimation = Tween<double>(
      begin: _horizontalDragOffset,
      end: direction * widget.cardWidth * 1.5,
    ).animate(_controller)
      ..addListener(() {
        setState(() {
          _horizontalDragOffset = _swipeAnimation!.value;
        });
      });

    _controller.forward(from: 0).whenComplete(() {
      setState(() {
        _currentIndex += direction;
        _horizontalDragOffset = 0.0;
        if (widget.onSwipe != null) {
          widget.onSwipe!(_currentIndex);
        }
      });
    });
  }

  void _resetCard() {
    _swipeAnimation = Tween<double>(
      begin: _horizontalDragOffset,
      end: 0.0,
    ).animate(_controller)
      ..addListener(() {
        setState(() {
          _horizontalDragOffset = _swipeAnimation!.value;
        });
      });

    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: _cardIndices.reversed.map((index) {
        final offset = _getOffset(index);
        final isBehind = index < _currentIndex;
        return AnimatedPositioned(
          duration: const Duration(milliseconds: 100),
          top: offset.dy,
          left: widget.cardWidth * 0.15 + offset.dx,
          child: GestureDetector(
            onPanStart: _onPanStart,
            onPanUpdate: (details) => _onPanUpdate(details, index),
            onPanEnd: (details) => _onPanEnd(details, index),
            child: Opacity(
              opacity: isBehind ? 0.5 : 1.0,
              child: Transform.rotate(
                angle: _getAngle(index),
                child: Transform.scale(
                  scale: _getScale(index),
                  child: SizedBox(
                    height: widget.cardHeight,
                    width: widget.cardWidth,
                    child: widget.cardBuilder(index),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Offset _getOffset(int index) {
    if (index == _currentIndex) {
      return Offset(_horizontalDragOffset, index * 2.0);
    }
    final offsetMultiplier = index - _currentIndex;
    return Offset(
        widget.stackSpacing * offsetMultiplier, offsetMultiplier * 10.0);
  }

  double _getScale(int index) {
    const scaleDifference = 0.05;
    return 1.0 - ((index - _currentIndex) * scaleDifference).clamp(0.0, 0.5);
  }

  double _getAngle(int index) {
    if (index == _currentIndex) {
      return _horizontalDragProgress * 0.2;
    }
    return 0.0;
  }
}
