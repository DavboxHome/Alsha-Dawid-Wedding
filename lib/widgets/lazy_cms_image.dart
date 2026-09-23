import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Loads a CMS network image only once it is near the viewport.
class LazyCmsImage extends HookWidget {
  const LazyCmsImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.preloadDistance = 600,
    required this.placeholderBuilder,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double preloadDistance;
  final Widget Function(BuildContext context, {required bool loading})
      placeholderBuilder;

  @override
  Widget build(BuildContext context) {
    final shouldLoad = useState(false);
    final scrollPosition = Scrollable.maybeOf(context)?.position;

    useEffect(
      () {
        if (shouldLoad.value) {
          return null;
        }

        void checkVisibility() {
          if (!context.mounted || shouldLoad.value) {
            return;
          }

          final renderObject = context.findRenderObject();
          if (renderObject is! RenderBox || !renderObject.hasSize) {
            return;
          }

          final imageTop = renderObject.localToGlobal(Offset.zero).dy;
          final imageBottom = imageTop + renderObject.size.height;
          final viewportHeight = MediaQuery.sizeOf(context).height;

          if (imageBottom >= -preloadDistance &&
              imageTop <= viewportHeight + preloadDistance) {
            shouldLoad.value = true;
          }
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          checkVisibility();
        });

        scrollPosition?.addListener(checkVisibility);

        return () {
          scrollPosition?.removeListener(checkVisibility);
        };
      },
      [scrollPosition, shouldLoad.value, preloadDistance],
    );

    if (!shouldLoad.value) {
      return placeholderBuilder(context, loading: false);
    }

    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (
        context,
        child,
        loadingProgress,
      ) {
        if (loadingProgress == null) {
          return child;
        }

        return placeholderBuilder(context, loading: true);
      },
      errorBuilder: (
        context,
        error,
        stackTrace,
      ) {
        return placeholderBuilder(context, loading: false);
      },
    );
  }
}
