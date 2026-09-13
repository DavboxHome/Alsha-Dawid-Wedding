import 'dart:async';
import 'dart:ui' as ui;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../hooks/use_auto_route_aware.dart';
import '../models/home/invite_card_shape.dart';
import '../utils/extension/context_extension.dart';

class WeddingHeroInviteCard extends HookWidget {
  const WeddingHeroInviteCard({
    this.imageAssetPath,
    required this.child,
    super.key,
    this.maxWidth = 382,
    this.animateOnMount = true,
    this.onImageTap,
  });

  final String? imageAssetPath;
  final Widget child;
  final double maxWidth;
  final bool animateOnMount;
  final VoidCallback? onImageTap;

  static const _shape = InviteCardShape(
    archWidth: 270,
    archHeight: 90,
  );

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 760),
    );
    final animationToken = useRef(0);

    final hasImage = imageAssetPath != null && imageAssetPath!.isNotEmpty;

    final playAnimationRef = useRef<Future<void> Function()>(() async {});

    playAnimationRef.value = () async {
      if (!context.mounted) {
        return;
      }

      animationToken.value++;
      final currentToken = animationToken.value;

      if (!animateOnMount) {
        controller.value = 1;
        return;
      }

      controller
        ..stop()
        ..value = 0;

      if (hasImage) {
        try {
          await precacheImage(
            AssetImage(imageAssetPath!),
            context,
          );
        } catch (_) {
          // Still run the animation if the image fails to precache.
        }
      }

      if (!context.mounted || currentToken != animationToken.value) {
        return;
      }

      await controller.forward(from: 0);
    };

    void scheduleAnimation() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(playAnimationRef.value());
      });
    }

    final replayAnimation = useCallback(
      scheduleAnimation,
      const [],
    );

    useEffect(
      () {
        scheduleAnimation();

        return () => animationToken.value++;
      },
      const [],
    );

    useEffect(
      () {
        scheduleAnimation();

        return null;
      },
      [imageAssetPath, animateOnMount],
    );

    final routeAware = useMemoized(
      () => _ReplayAnimationRouteAware(onActivate: replayAnimation),
      [replayAnimation],
    );

    useAutoRouteAware(routeAware);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final card = Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: ClipPath(
                      clipper: _InviteCardClipper(
                        shape: _shape,
                        withArch: hasImage,
                      ),
                      child: BackdropFilter(
                        filter: ui.ImageFilter.blur(sigmaX: 1.2, sigmaY: 1.2),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _InviteCardPainter(
                        shape: _shape,
                        withArch: hasImage,
                        paperFill:
                            context.colorScheme.surface.withValues(alpha: 0.86),
                        outerFrame:
                            context.colorScheme.outline.withValues(alpha: 0.95),
                        innerFrame: context.colorScheme.outlineVariant
                            .withValues(alpha: 0.7),
                        cardShadow:
                            context.colorScheme.shadow.withValues(alpha: 0.16),
                      ),
                    ),
                  ),
                  if (hasImage)
                    Positioned(
                      top: 6,
                      left: 0,
                      right: 0,
                      height: 100,
                      child: GestureDetector(
                        onTap: onImageTap,
                        behavior: HitTestBehavior.opaque,
                        child: Image.asset(
                          imageAssetPath!,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      36,
                      hasImage ? 70 : 36,
                      36,
                      28,
                    ),
                    child: hasImage
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 24),
                              child,
                            ],
                          )
                        : child,
                  ),
                ],
              ),
            ),
          ),
        );

        if (!animateOnMount || controller.isCompleted) {
          return card;
        }

        final animationValue = controller.value;

        final opacityProgress = (animationValue / 0.45).clamp(0.0, 1.0);
        final opacity = Curves.easeOut.transform(opacityProgress);

        final scale = TweenSequence<double>(
          [
            TweenSequenceItem(
              tween: Tween<double>(
                begin: 0.96,
                end: 1.018,
              ).chain(
                CurveTween(curve: Curves.easeOutCubic),
              ),
              weight: 70,
            ),
            TweenSequenceItem(
              tween: Tween<double>(
                begin: 1.018,
                end: 1,
              ).chain(
                CurveTween(curve: Curves.easeOut),
              ),
              weight: 30,
            ),
          ],
        ).transform(animationValue);

        final slideY = Tween<double>(
          begin: 8,
          end: 0,
        ).transform(
          Curves.easeOutCubic.transform(animationValue),
        );

        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, slideY),
            child: Transform.scale(
              scale: scale,
              alignment: Alignment.center,
              filterQuality: FilterQuality.low,
              child: card,
            ),
          ),
        );
      },
    );
  }
}

class _ReplayAnimationRouteAware with AutoRouteAware {
  _ReplayAnimationRouteAware({required this.onActivate});

  final VoidCallback onActivate;

  @override
  void didPush() => onActivate();

  @override
  void didPopNext() => onActivate();

  @override
  void didInitTabRoute(TabPageRoute? previousRoute) => onActivate();

  @override
  void didChangeTabRoute(TabPageRoute previousRoute) => onActivate();
}

class _InviteCardPainter extends CustomPainter {
  const _InviteCardPainter({
    required this.shape,
    required this.withArch,
    required this.paperFill,
    required this.outerFrame,
    required this.innerFrame,
    required this.cardShadow,
  });

  final InviteCardShape shape;
  final bool withArch;
  final Color paperFill;
  final Color outerFrame;
  final Color innerFrame;
  final Color cardShadow;

  @override
  void paint(Canvas canvas, Size size) {
    final outerPath = _buildCardPath(size, shape, withArch: withArch);

    const innerInset = 3.2;
    final innerPath = withArch
        ? _buildCardPath(
            Size(size.width - innerInset * 2, size.height - innerInset * 2),
            shape.inset(innerInset),
            withArch: true,
          ).shift(const Offset(innerInset, innerInset))
        : _buildRectPath(
            Size(size.width - innerInset * 2, size.height - innerInset * 2),
            shape.cornerRadius - innerInset,
          ).shift(const Offset(innerInset, innerInset));

    canvas.drawShadow(
      outerPath,
      cardShadow,
      13,
      false,
    );

    canvas.drawPath(
      outerPath,
      Paint()
        ..color = paperFill
        ..style = PaintingStyle.fill
        ..isAntiAlias = true,
    );

    canvas.drawPath(
      outerPath,
      Paint()
        ..color = outerFrame
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..isAntiAlias = true,
    );

    canvas.drawPath(
      innerPath,
      Paint()
        ..color = innerFrame
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.75
        ..isAntiAlias = true,
    );
  }

  @override
  bool shouldRepaint(covariant _InviteCardPainter oldDelegate) {
    return oldDelegate.shape != shape ||
        oldDelegate.withArch != withArch ||
        oldDelegate.paperFill != paperFill ||
        oldDelegate.outerFrame != outerFrame ||
        oldDelegate.innerFrame != innerFrame ||
        oldDelegate.cardShadow != cardShadow;
  }
}

class _InviteCardClipper extends CustomClipper<Path> {
  const _InviteCardClipper({
    required this.shape,
    required this.withArch,
  });

  final InviteCardShape shape;
  final bool withArch;

  @override
  Path getClip(Size size) {
    return _buildCardPath(size, shape, withArch: withArch);
  }

  @override
  bool shouldReclip(covariant _InviteCardClipper oldClipper) {
    return oldClipper.shape != shape || oldClipper.withArch != withArch;
  }
}

Path _buildCardPath(
  Size size,
  InviteCardShape shape, {
  required bool withArch,
}) {
  if (!withArch) {
    return _buildRectPath(size, shape.cornerRadius);
  }

  return _buildArchPath(size, shape);
}

Path _buildRectPath(Size size, double cornerRadius) {
  final w = size.width;
  final h = size.height;
  final r = cornerRadius.clamp(0.0, w / 2).toDouble();

  return Path()
    ..moveTo(r, 0)
    ..lineTo(w - r, 0)
    ..quadraticBezierTo(w, 0, w, r)
    ..lineTo(w, h - r)
    ..quadraticBezierTo(w, h, w - r, h)
    ..lineTo(r, h)
    ..quadraticBezierTo(0, h, 0, h - r)
    ..lineTo(0, r)
    ..quadraticBezierTo(0, 0, r, 0)
    ..close();
}

Path _buildArchPath(Size size, InviteCardShape shape) {
  final w = size.width;
  final h = size.height;
  final r = shape.cornerRadius;
  final sy = shape.shoulderY;
  final cx = w / 2;
  final archHalfWidth = shape.archWidth / 2;
  final archTopY = sy - shape.archHeight;

  final leftArchJoin = cx - archHalfWidth;
  final rightArchJoin = cx + archHalfWidth;

  return Path()
    ..moveTo(r, sy)
    ..lineTo(leftArchJoin, sy)
    ..cubicTo(
      cx - archHalfWidth * 0.55,
      archTopY,
      cx + archHalfWidth * 0.55,
      archTopY,
      rightArchJoin,
      sy,
    )
    ..lineTo(w - r, sy)
    ..quadraticBezierTo(w, sy, w, sy + r)
    ..lineTo(w, h - r)
    ..quadraticBezierTo(w, h, w - r, h)
    ..lineTo(r, h)
    ..quadraticBezierTo(0, h, 0, h - r)
    ..lineTo(0, sy + r)
    ..quadraticBezierTo(0, sy, r, sy)
    ..close();
}
