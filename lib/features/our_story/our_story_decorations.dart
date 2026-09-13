import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../utils/extension/context_extension.dart';

/// Five-point star for the footer flourish divider.
class StoryStarPin extends StatelessWidget {
  const StoryStarPin({super.key, this.size = 22});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _StoryStarPinPainter(color: context.goldBrass),
      ),
    );
  }
}

class _StoryStarPinPainter extends CustomPainter {
  _StoryStarPinPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final stroke = Paint()
      ..color = color.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.06;

    final center = Offset(size.width / 2, size.height / 2);
    final outer = size.width * 0.42;
    final inner = size.width * 0.18;
    final path = Path();

    for (var i = 0; i < 10; i++) {
      final radius = i.isEven ? outer : inner;
      final angle = (i * 36 - 90) * math.pi / 180;
      final point = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant _StoryStarPinPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Footer divider with a small star in the centre.
class StoryFooterFlourish extends StatelessWidget {
  const StoryFooterFlourish({super.key});

  @override
  Widget build(BuildContext context) {
    final gold = context.colorScheme.tertiary;

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: gold.withValues(alpha: 0.55),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: StoryStarPin(size: 12),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: gold.withValues(alpha: 0.55),
          ),
        ),
      ],
    );
  }
}
