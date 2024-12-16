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
    (
        'initState: _currentIndex=$_currentIndex, _cardIndices=$_cardIndices');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
    ('dispose');
  }

  /// Handles the start of drag gesture
  void _onPanStart(DragStartDetails details) {
    setState(() {
      _dragStartPosition = details.globalPosition;
    });
    ('onPanStart: _dragStartPosition=$_dragStartPosition');
  }

  /// Updates card position during drag
  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _horizontalDragOffset = details.globalPosition.dx - _dragStartPosition.dx;
    });
    ('onPanUpdate: _horizontalDragOffset=$_horizontalDragOffset');
  }

  /// Handles drag completion and card snapping
  void _onPanEnd(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond.dx;
    final threshold = widget.cardWidth / 2;

    (
        'onPanEnd: velocity=$velocity, threshold=$threshold, _horizontalDragOffset=$_horizontalDragOffset');

    if (_horizontalDragOffset.abs() > threshold || velocity.abs() > 1000) {
      final direction = _horizontalDragOffset.isNegative ? -1 : 1;
      ('onPanEnd: Swiping card in direction=$direction');
      _swipeCard(direction, _cardIndices.first);
    } else {
      ('onPanEnd: Resetting card');
      _resetCard();
    }
  }

  void _swipeCard(int direction, int? firstIndex) {
    _swipeAnimation = Tween<double>(
      begin: _horizontalDragOffset,
      end: direction * widget.cardWidth,
    ).animate(_controller)
      ..addListener(() {
        setState(() {
          _horizontalDragOffset = _swipeAnimation!.value;
        });
        ('swipeCard: _horizontalDragOffset=$_horizontalDragOffset');
      });

    _controller.forward(from: 0).whenComplete(() {
      setState(() {
        // _currentIndex = (_currentIndex + direction) % widget.cardCount;
        _currentIndex =
            firstIndex! == widget.cardCount - 1 ? 0 : firstIndex + 1;
        if (_currentIndex < 0) {
          _currentIndex += widget.cardCount;
        }
        _horizontalDragOffset = 0.0;
        if (direction > 0) {
          final lastIndex = _cardIndices.removeLast();
          _cardIndices.insert(0, lastIndex);
        } else {
          final firstIndex = _cardIndices.removeAt(0);
          _cardIndices.add(firstIndex);
        }
        (
            'swipeCard complete: _currentIndex=$_currentIndex, _cardIndices=$_cardIndices');
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
        ('resetCard: _horizontalDragOffset=$_horizontalDragOffset');
      });

    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    ('build: _currentIndex=$_currentIndex, _cardIndices=$_cardIndices');
    return Stack(
      clipBehavior: Clip.none,
      children: _cardIndices.reversed.map((index) {
        final offset = _getOffset(index);
        final isBehind = index < _currentIndex;
        ('build: index=$index, offset=$offset, isBehind=$isBehind');
        return AnimatedPositioned(
          duration: const Duration(milliseconds: 100),
          top: offset.dy,
          left: widget.cardWidth * 0.15 + offset.dx,
          child: GestureDetector(
            onPanStart: _onPanStart,
            onPanUpdate: _onPanUpdate,
            onPanEnd: _onPanEnd,
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
