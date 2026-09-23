import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../content/repositories/wedding_content_repository.dart';
import '../../models/app/app_page.dart';
import '../../models/content/our_story_photo.dart';
import '../../router/app_router.gr.dart';
import '../../utils/extension/context_extension.dart';
import '../../widgets/heart_divider.dart';
import '../../widgets/lazy_cms_image.dart';
import '../../widgets/page_availability_gate.dart';
import 'our_story_decorations.dart';

@RoutePage()
class OurStoryPage extends ConsumerWidget {
  const OurStoryPage({super.key});

  static void push(BuildContext context) {
    context.router.navigate(const OurStoryRoute());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries =
        ref.watch(weddingContentRepositoryProvider).requireValue.ourStoryPhotos;

    return PageAvailabilityGate(
      page: AppPage.ourStory,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 680,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _StoryHeader(),
                const SizedBox(height: 42),
                for (var i = 0; i < entries.length; i++) ...[
                  _StoryEntry(
                    entry: entries[i],
                    index: i,
                  ),
                  if (i < entries.length - 1) const _StoryConnector(),
                ],
                const SizedBox(height: 48),
                const _StoryFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StoryHeader extends StatelessWidget {
  const _StoryHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Our Story',
          textAlign: TextAlign.center,
          style: context.scriptHero(
            fontSize: 40,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 10),
        const HeartAccent(),
        const SizedBox(height: 10),
        Text(
          'A LITTLE BIT OF OUR JOURNEY',
          textAlign: TextAlign.center,
          style: context.capsLabel(),
        ),
      ],
    );
  }
}

class _StoryEntry extends StatelessWidget {
  const _StoryEntry({
    required this.entry,
    required this.index,
  });

  final OurStoryPhoto entry;
  final int index;

  @override
  Widget build(BuildContext context) {
    final title = entry.title?.trim() ?? '';
    final description = entry.description?.trim() ?? '';
    final imageUrl = entry.imageUrl;

    final rotation = switch (index % 4) {
      0 => -0.035,
      1 => 0.025,
      2 => -0.02,
      _ => 0.035,
    };

    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final width = (constraints.maxWidth * 0.86)
                .clamp(
                  250.0,
                  430.0,
                )
                .toDouble();

            return _PolaroidPhoto(
              imageUrl: imageUrl,
              width: width,
              rotation: rotation,
            );
          },
        ),
        if (title.isNotEmpty) ...[
          const SizedBox(height: 28),
          Text(
            title,
            textAlign: TextAlign.center,
            style: context.timelineTitle(),
          ),
        ],
        if (description.isNotEmpty) ...[
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 560,
            ),
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: context.timelineBody().copyWith(
                    height: 1.6,
                  ),
            ),
          ),
        ],
      ],
    );
  }
}

class _PolaroidPhoto extends StatelessWidget {
  const _PolaroidPhoto({
    required this.imageUrl,
    required this.width,
    required this.rotation,
  });

  final String? imageUrl;
  final double width;
  final double rotation;

  @override
  Widget build(BuildContext context) {
    final imageHeight = width * 0.92;

    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: context.polaroidWhite,
          boxShadow: [
            BoxShadow(
              color: context.textCharcoal.withValues(
                alpha: 0.14,
              ),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: EdgeInsets.fromLTRB(
          12,
          12,
          12,
          width * 0.17,
        ),
        child: SizedBox(
          width: width - 24,
          height: imageHeight,
          child: imageUrl == null
              ? _StoryImagePlaceholder(
                  width: width - 24,
                  height: imageHeight,
                )
              : LazyCmsImage(
                  imageUrl: imageUrl!,
                  width: width - 24,
                  height: imageHeight,
                  placeholderBuilder: (
                    context, {
                    required loading,
                  }) {
                    return _StoryImagePlaceholder(
                      width: width - 24,
                      height: imageHeight,
                      loading: loading,
                    );
                  },
                ),
        ),
      ),
    );
  }
}

class _StoryImagePlaceholder extends StatelessWidget {
  const _StoryImagePlaceholder({
    required this.width,
    required this.height,
    this.loading = false,
  });

  final double width;
  final double height;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: context.creamBackground,
      alignment: Alignment.center,
      child: loading
          ? SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: context.colorScheme.tertiary.withValues(
                  alpha: 0.7,
                ),
              ),
            )
          : Icon(
              Icons.image_outlined,
              size: 34,
              color: context.colorScheme.primary.withValues(
                alpha: 0.4,
              ),
            ),
    );
  }
}

class _StoryConnector extends StatelessWidget {
  const _StoryConnector();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 30,
      ),
      child: Column(
        children: [
          const HeartAccent(),
          const SizedBox(height: 10),
          SizedBox(
            width: 12,
            height: 76,
            child: CustomPaint(
              painter: _DashedStoryLinePainter(
                color: context.colorScheme.tertiary.withValues(
                  alpha: 0.55,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedStoryLinePainter extends CustomPainter {
  const _DashedStoryLinePainter({
    required this.color,
  });

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    const dashHeight = 5.0;
    const gapHeight = 6.0;

    var y = 0.0;

    while (y < size.height) {
      final end = (y + dashHeight).clamp(
        0.0,
        size.height,
      );

      canvas.drawLine(
        Offset(
          size.width / 2,
          y,
        ),
        Offset(
          size.width / 2,
          end,
        ),
        paint,
      );

      y += dashHeight + gapHeight;
    }
  }

  @override
  bool shouldRepaint(
    covariant _DashedStoryLinePainter oldDelegate,
  ) {
    return oldDelegate.color != color;
  }
}

class _StoryFooter extends StatelessWidget {
  const _StoryFooter();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const StoryFooterFlourish(),
        const SizedBox(height: 22),
        ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 560,
          ),
          child: Text(
            'From the moment we met, we knew our story was worth writing.',
            textAlign: TextAlign.center,
            style: context.scriptHero(
              fontSize: 30,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}
