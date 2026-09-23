import 'dart:ui' as ui;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../content/repositories/wedding_content_repository.dart';
import '../../models/app/app_page.dart';
import '../../models/content/cms_image.dart';
import '../../providers/gallery_shuffle_provider.dart';
import '../../router/app_router.gr.dart';
import '../../utils/extension/context_extension.dart';
import '../../widgets/lazy_cms_image.dart';
import '../../widgets/page_availability_gate.dart';

@RoutePage()
class GalleryPage extends ConsumerWidget {
  const GalleryPage({super.key});

  static void push(BuildContext context) {
    context.router.navigate(const GalleryRoute());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(weddingContentRepositoryProvider).requireValue;
    final shuffleEnabled = ref.watch(galleryShuffleProvider);
    final gallery = shuffleEnabled ? content.shuffledGallery : content.gallery;

    return PageAvailabilityGate(
      page: AppPage.gallery,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          20,
          8,
          20,
          40,
        ),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 1100,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _GalleryHeader(),
                const SizedBox(height: 42),
                if (gallery.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 48,
                    ),
                    child: Text(
                      'Photos coming soon.',
                      textAlign: TextAlign.center,
                      style: context.bodySerif(),
                    ),
                  )
                else
                  _ScatteredPolaroidGallery(
                    gallery: gallery,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GalleryHeader extends StatelessWidget {
  const _GalleryHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Gallery',
          textAlign: TextAlign.center,
          style: context.scriptHero(
            fontSize: 46,
            height: 1.08,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'A FEW OF OUR FAVOURITE MOMENTS',
          textAlign: TextAlign.center,
          style: context.capsLabel(
            color: context.sageGreen,
          ),
        ),
      ],
    );
  }
}

class _ScatteredPolaroidGallery extends StatelessWidget {
  const _ScatteredPolaroidGallery({
    required this.gallery,
  });

  final List<CmsImage> gallery;

  @override
  Widget build(BuildContext context) {
    const spacing = 8.0;

    const rotations = [
      -0.055,
      0.035,
      -0.025,
      0.06,
      -0.04,
      0.02,
      0.05,
      -0.035,
      0.015,
      -0.06,
    ];

    const xOffsets = [
      -5.0,
      6.0,
      3.0,
      -7.0,
      8.0,
      -2.0,
      -6.0,
      5.0,
      1.0,
      -4.0,
    ];

    const yOffsets = [
      4.0,
      -8.0,
      10.0,
      -3.0,
      7.0,
      -5.0,
      1.0,
      9.0,
      -7.0,
      5.0,
    ];

    const scales = [
      0.92,
      0.82,
      0.88,
      0.96,
      0.84,
      0.9,
      0.8,
      0.94,
      0.86,
      0.91,
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = switch (constraints.maxWidth) {
          >= 900 => 4,
          >= 620 => 3,
          _ => 2,
        };

        final cellWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        final cellHeight = cellWidth * 1.25;

        return Wrap(
          spacing: spacing,
          runSpacing: 14,
          children: [
            for (var i = 0; i < gallery.length; i++)
              SizedBox(
                key: ValueKey(gallery[i].url),
                width: cellWidth,
                height: cellHeight,
                child: Transform.translate(
                  offset: Offset(
                    xOffsets[i % xOffsets.length],
                    yOffsets[i % yOffsets.length],
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Transform.rotate(
                      angle: rotations[i % rotations.length],
                      child: _GalleryPolaroid(
                        image: gallery[i],
                        width: cellWidth * scales[i % scales.length],
                        rotation: rotations[i % rotations.length],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _GalleryPolaroid extends StatelessWidget {
  const _GalleryPolaroid({
    required this.image,
    required this.width,
    required this.rotation,
  });

  final CmsImage image;
  final double width;
  final double rotation;

  @override
  Widget build(BuildContext context) {
    final imageHeight = width * 0.92;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          showGeneralDialog<void>(
            context: context,
            useRootNavigator: true,
            barrierDismissible: true,
            barrierLabel:
                MaterialLocalizations.of(context).modalBarrierDismissLabel,
            barrierColor: Colors.transparent,
            transitionDuration: const Duration(
              milliseconds: 300,
            ),
            pageBuilder: (
              context,
              animation,
              secondaryAnimation,
            ) {
              return _GalleryPolaroidOverlay(
                imageUrl: image.absoluteUrl,
                rotation: rotation,
              );
            },
            transitionBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) =>
                child,
          );
        },
        child: Container(
          width: width,
          decoration: BoxDecoration(
            color: context.polaroidWhite,
            boxShadow: [
              BoxShadow(
                color: context.textCharcoal.withValues(
                  alpha: 0.15,
                ),
                blurRadius: 14,
                offset: const Offset(
                  0,
                  6,
                ),
              ),
            ],
          ),
          padding: EdgeInsets.fromLTRB(
            8,
            8,
            8,
            width * 0.16,
          ),
          child: LazyCmsImage(
            imageUrl: image.previewUrl,
            width: width - 16,
            height: imageHeight,
            placeholderBuilder: (
              context, {
              required loading,
            }) {
              return _GalleryImagePlaceholder(
                width: width - 16,
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

class _GalleryPolaroidOverlay extends StatelessWidget {
  const _GalleryPolaroidOverlay({
    required this.imageUrl,
    required this.rotation,
  });

  final String imageUrl;
  final double rotation;

  @override
  Widget build(BuildContext context) {
    final routeAnimation =
        ModalRoute.of(context)?.animation ?? kAlwaysCompleteAnimation;

    final polaroidAnimation = CurvedAnimation(
      parent: routeAnimation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    final screenSize = MediaQuery.sizeOf(context);

    final widthFromScreen = screenSize.width * 0.84;
    final widthFromHeight = screenSize.height * 0.72;

    final width =
        (widthFromScreen < widthFromHeight ? widthFromScreen : widthFromHeight)
            .clamp(
              250.0,
              520.0,
            )
            .toDouble();

    final imageHeight = width * 0.92;

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedBuilder(
            animation: routeAnimation,
            builder: (context, _) {
              final t = Curves.easeOut.transform(
                routeAnimation.value,
              );

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(
                    sigmaX: 12 * t,
                    sigmaY: 12 * t,
                  ),
                  child: ColoredBox(
                    color: context.textCharcoal.withValues(
                      alpha: 0.32 * t,
                    ),
                  ),
                ),
              );
            },
          ),
          FadeTransition(
            opacity: polaroidAnimation,
            child: ScaleTransition(
              scale: Tween<double>(
                begin: 0.86,
                end: 1,
              ).animate(
                polaroidAnimation,
              ),
              child: SafeArea(
                child: Center(
                  child: GestureDetector(
                    onTap: () {},
                    child: AnimatedBuilder(
                      animation: routeAnimation,
                      builder: (context, _) {
                        final t = Curves.easeOut.transform(
                          routeAnimation.value,
                        );

                        return Transform.rotate(
                          angle: rotation * 0.45,
                          child: Container(
                            width: width,
                            decoration: BoxDecoration(
                              color: context.polaroidWhite,
                              boxShadow: [
                                BoxShadow(
                                  color: context.textCharcoal.withValues(
                                    alpha: 0.2 * t,
                                  ),
                                  blurRadius: 24,
                                  offset: const Offset(
                                    0,
                                    10,
                                  ),
                                ),
                              ],
                            ),
                            padding: EdgeInsets.fromLTRB(
                              12,
                              12,
                              12,
                              width * 0.14,
                            ),
                            child: Image.network(
                              imageUrl,
                              width: width - 24,
                              height: imageHeight,
                              fit: BoxFit.cover,
                              loadingBuilder: (
                                context,
                                child,
                                loadingProgress,
                              ) {
                                if (loadingProgress == null) {
                                  return child;
                                }

                                return _GalleryImagePlaceholder(
                                  width: width - 24,
                                  height: imageHeight,
                                  loading: true,
                                );
                              },
                              errorBuilder: (
                                context,
                                error,
                                stackTrace,
                              ) {
                                return _GalleryImagePlaceholder(
                                  width: width - 24,
                                  height: imageHeight,
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GalleryImagePlaceholder extends StatelessWidget {
  const _GalleryImagePlaceholder({
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
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: context.colorScheme.tertiary.withValues(
                  alpha: 0.7,
                ),
              ),
            )
          : Icon(
              Icons.image_outlined,
              size: 32,
              color: context.colorScheme.primary.withValues(
                alpha: 0.4,
              ),
            ),
    );
  }
}
