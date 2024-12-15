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
  late int _currentIndex = _initialIndex;

  late final _initialIndex = 0;

  /// Starting position of drag gesture
  Offset _dragStartPosition = Offset.zero;

  /// Current horizontal drag offset
  double _horizontalDragOffset = 0.0;

  double get _horizontalDragProgress =>
      _horizontalDragOffset / widget.cardWidth;

  late final List<int> _cardIndices =
      List.generate(widget.cardCount, (index) => index);

  @override
  void initState() {
    super.initState();
  }

  /// Handles the start of drag gesture
  void _onPanStart(DragStartDetails details) {
    setState(() {
      _dragStartPosition = details.globalPosition;
    });
  }

  /// Updates card position during drag
  void _onPanUpdate(DragUpdateDetails details, int index) {
    if (index == _currentIndex &&
        index == 0 &&
        details.delta.dx > 0 &&
        _horizontalDragOffset == 0) {
      return;
    }
    if (details.globalPosition.dx > _dragStartPosition.dx) {
      return;
    }
    _horizontalDragOffset = details.globalPosition.dx - _dragStartPosition.dx;
    print('progress: $_horizontalDragProgress');
    if (_horizontalDragProgress.abs() > 0.5 && _reordersLeft > 0) {
      _onSwipeCard(index);
    }
    setState(() {});
  }

  void _onSwipeCard(int index) {
    if (index == _cardIndices.length-1) {
      return;
    }
    _reordersLeft = 0;
    if (widget.onSwipe != null) {
      widget.onSwipe!(index);
    }
    final element = _cardIndices.removeAt(0);
    _cardIndices.insert(widget.cardCount - 1 - index, element);
    print('cards: ${_cardIndices}');
    _currentIndex++;
    _horizontalDragOffset = 0.0;
    print('current index: $_currentIndex');
  }

  /// Handles drag completion and card snapping
  void _onPanEnd(DragEndDetails details, int index) {
    setCanReorder(true);
    setState(() {
      _dragStartPosition = Offset.zero;
      _horizontalDragOffset = 0.0;
    });
    if (_horizontalDragProgress > 0.5) {}
  }

  void setCanReorder(bool canReorder) {
    _reordersLeft = canReorder ? 1 : 0;
  }

  int _reordersLeft = 1;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: _cardIndices.reversed.map((index) {
        final offset = _getOffset(index);
        return AnimatedPositioned(
          duration: const Duration(milliseconds: 100),
          top: offset.dy,
          left: widget.cardWidth * 0.15 + offset.dx,
          child: GestureDetector(
            onPanStart: (det) => _onPanStart(det),
            onPanUpdate: (delta) => _onPanUpdate(delta, index),
            onPanDown: (details) => setCanReorder(true),
            onPanCancel: () => _onPanEnd(DragEndDetails(), index),
            onPanEnd: (det) => _onPanEnd(det, index),
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
        );
      }).toList(),
    );
  }

  Offset _getOffset(int index) {
    double dy = index * 2.0;
    double dx;
    if (index == _currentIndex) {
      dx = _horizontalDragOffset;
    } else {
      dx = (index < _currentIndex ? -1 : 1) * index * widget.stackSpacing;
    }
    return Offset(dx, dy);
  }

  double _getScale(int index) {
    double scaleMultiplier = 1.0;
    if (index == _currentIndex) {
      if (_horizontalDragProgress > 0 && _currentIndex == 0) {
        scaleMultiplier = 1.0;
      } else {
        if (_horizontalDragProgress == 0) {
          scaleMultiplier = 1.0;
        } else {
          scaleMultiplier =
              (1.0 - _horizontalDragProgress.abs()).clamp(0.6, 1.0);
        }
      }
    }
    double baseMultiPlier = 1 - (index * 0.05);
    return baseMultiPlier * scaleMultiplier;
  }

  double _getAngle(int index) {
    if (index == _currentIndex) {
      if (_horizontalDragProgress > 0 && _currentIndex == 0) {
        return 0;
      }
      return _horizontalDragProgress;
    }

    double rotationAngle = index * 0.02;

    int multiPlier = index > _currentIndex ? 1 : -1;

    return rotationAngle * multiPlier;
  }
}

extension ListExt on List<int> {
  // returns hash of the order of the list
  int get orderHash =>
      fold(0, (previousValue, element) => previousValue * 31 + element);
}
