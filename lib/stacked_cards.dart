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
  late final Animation<Offset> _swipeAnimation;
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
    _swipeAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(1.5, 0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  void _onPanStart(DragStartDetails details) {
    _dragStart = details.globalPosition;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final dx = details.globalPosition.dx - _dragStart.dx;
    if (dx.abs() > (details.globalPosition.dy - _dragStart.dy).abs()) {
      setState(() {
        _dragPosition = dx.clamp(-widget.cardWidth, widget.cardWidth);
      });
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (_dragPosition.abs() > widget.cardWidth / 3) {
      final direction = _dragPosition > 0 ? 1 : -1;
      _controller.forward().then((value) {
        setState(() {
          _currentIndex++;
          _dragPosition = 0;
        });
        _controller.reset();
        if (widget.onSwipe != null) {
          widget.onSwipe!(_currentIndex);
        }
      });
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
        children: List.generate(
          math.min(widget.visibleCards, _currentIndex + 1),
          (index) {
            final isTopCard = index == 0;
            final cardIndex = _currentIndex - index;

            // Calculate transform values
            final double scale = 1.0 - (index * 0.05);
            final double rotation = index * 0.025;
            final double translateX = index * widget.stackSpacing;
            final double opacity = 1.0 - (index * 0.3);

            return Positioned(
              top: 0,
              left: 0,
              child: Transform.translate(
                offset: Offset(isTopCard ? _dragPosition : translateX, 0),
                child: Transform.rotate(
                  angle: (isTopCard
                      ? (_dragPosition / widget.cardWidth) * 0.4
                      : rotation),
                  child: Transform.scale(
                    scale: scale,
                    child: Opacity(
                      opacity: opacity,
                      child: CustomPaint(
                        foregroundPainter: CardShadowPainter(
                          elevation: (widget.visibleCards - index) * 2.0,
                        ),
                        child: SizedBox(
                          height: widget.cardHeight,
                          width: widget.cardWidth,
                          child: widget.onGenerate(cardIndex),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class CardShadowPainter extends CustomPainter {
  final double elevation;

  CardShadowPainter({this.elevation = 4.0});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, elevation);

    final Path shadowPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(8),
      ));

    canvas.drawPath(shadowPath, shadowPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
