import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../utils/extension/context_extension.dart';

class SwipeScrollHint extends HookWidget {
  const SwipeScrollHint({
    required this.visible,
    super.key,
  });

  final bool visible;

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 1800),
    );

    useEffect(
      () {
        if (visible) {
          controller
            ..value = 0
            ..repeat();
        } else {
          // Freeze the gesture where it currently is.
          // AnimatedOpacity will fade the whole thing out.
          controller.stop();
        }

        return null;
      },
      [visible],
    );

    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        onEnd: () {
          // Once it is completely invisible, reset it ready
          // for the next time this page is opened.
          if (!visible) {
            controller.value = 0;
          }
        },
        child: SizedBox(
          width: 100,
          height: 110,
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              final t = controller.value;

              final gestureProgress = Curves.easeInOutCubic.transform(
                ((t - 0.08) / 0.62).clamp(0.0, 1.0),
              );

              final fadeIn = Curves.easeOut.transform(
                (t / 0.12).clamp(0.0, 1.0),
              );

              final fadeOut = 1 -
                  Curves.easeIn.transform(
                    ((t - 0.80) / 0.20).clamp(0.0, 1.0),
                  );

              final opacity = (fadeIn * fadeOut).clamp(0.0, 1.0);

              return Opacity(
                opacity: opacity,
                child: _SwipeGesture(
                  progress: gestureProgress,
                  color: context.burgundyAccent,
                  backgroundColor: context.creamBackground,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SwipeGesture extends StatelessWidget {
  const _SwipeGesture({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  final double progress;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(
          constraints.maxWidth,
          constraints.maxHeight,
        );

        final path = _SwipeSwishPainter.createPath(size);
        final metrics = path.computeMetrics().toList();

        if (metrics.isEmpty) {
          return const SizedBox.shrink();
        }

        final metric = metrics.first;
        final distance = metric.length * progress;

        final tangent = metric.getTangentForOffset(
          distance.clamp(
            0.0,
            metric.length,
          ),
        );

        if (tangent == null) {
          return const SizedBox.shrink();
        }

        final fingerTip = tangent.position;

        const handSize = 44.0;
        const fingerTipOffsetFromCentre = Offset(
          0,
          -14,
        );

        final handRotation = ((tangent.angle + math.pi / 2) * 0.22).clamp(
          -0.18,
          0.18,
        );

        final rotatedFingerOffset = Offset(
          fingerTipOffsetFromCentre.dx * math.cos(handRotation) -
              fingerTipOffsetFromCentre.dy * math.sin(handRotation),
          fingerTipOffsetFromCentre.dx * math.sin(handRotation) +
              fingerTipOffsetFromCentre.dy * math.cos(handRotation),
        );

        final handCentre = fingerTip - rotatedFingerOffset;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _SwipeSwishPainter(
                  progress: progress,
                  color: color,
                  backgroundColor: backgroundColor,
                ),
              ),
            ),
            Positioned(
              left: handCentre.dx - handSize / 2,
              top: handCentre.dy - handSize / 2,
              width: handSize,
              height: handSize,
              child: Transform.rotate(
                angle: handRotation,
                child: Icon(
                  Icons.touch_app_rounded,
                  size: handSize,
                  color: color,
                  shadows: [
                    Shadow(
                      color: backgroundColor,
                      blurRadius: 10,
                    ),
                    Shadow(
                      color: backgroundColor,
                      blurRadius: 15,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SwipeSwishPainter extends CustomPainter {
  const _SwipeSwishPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  final double progress;
  final Color color;
  final Color backgroundColor;

  static Path createPath(Size size) {
    return Path()
      ..moveTo(
        size.width * 0.27,
        size.height * 0.88,
      )
      ..cubicTo(
        size.width * 0.38,
        size.height * 0.75,
        size.width * 0.45,
        size.height * 0.62,
        size.width * 0.50,
        size.height * 0.51,
      )
      ..cubicTo(
        size.width * 0.56,
        size.height * 0.38,
        size.width * 0.62,
        size.height * 0.27,
        size.width * 0.67,
        size.height * 0.19,
      );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = createPath(size);
    final metrics = path.computeMetrics().toList();

    if (metrics.isEmpty || progress <= 0) {
      return;
    }

    final metric = metrics.first;

    final endDistance = math.max(
      0,
      metric.length * progress - 2,
    );

    final visiblePath = metric.extractPath(
      0,
      endDistance.toDouble(),
    );

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final swishPaint = Paint()
      ..color = color.withValues(alpha: 0.92)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(
      visiblePath,
      backgroundPaint,
    );

    canvas.drawPath(
      visiblePath,
      swishPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _SwipeSwishPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
