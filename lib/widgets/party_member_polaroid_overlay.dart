import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../models/content/content.dart';
import '../utils/extension/context_extension.dart';
import '../utils/extension/string_extension.dart';

void showPartyMemberPolaroid(
  BuildContext context, {
  required WeddingPartyMember member,
}) {
  showGeneralDialog<void>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return _PartyMemberPolaroidOverlay(
        member: member,
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) => child,
  );
}

class _PartyMemberPolaroidOverlay extends StatelessWidget {
  const _PartyMemberPolaroidOverlay({
    required this.member,
  });

  final WeddingPartyMember member;

  @override
  Widget build(BuildContext context) {
    final routeAnimation =
        ModalRoute.of(context)?.animation ?? kAlwaysCompleteAnimation;
    final polaroidAnimation = CurvedAnimation(
      parent: routeAnimation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    final width = (MediaQuery.sizeOf(context).width * 0.78).clamp(240.0, 300.0);
    final imageHeight = width * 0.92;
    final photoUrl = member.fullPhotoUrl;
    final caption = member.hasBio ? member.bio!.trim() : '';

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedBuilder(
            animation: routeAnimation,
            builder: (context, _) {
              final t = Curves.easeOut.transform(routeAnimation.value);

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(context).pop(),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(
                    sigmaX: 12 * t,
                    sigmaY: 12 * t,
                  ),
                  child: ColoredBox(
                    color: context.textCharcoal.withValues(alpha: 0.32 * t),
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
              ).animate(polaroidAnimation),
              child: SafeArea(
                child: Center(
                  child: GestureDetector(
                    onTap: () {},
                    child: AnimatedBuilder(
                      animation: routeAnimation,
                      builder: (context, _) {
                        final t =
                            Curves.easeOut.transform(routeAnimation.value);

                        return Transform.rotate(
                          angle: -0.025,
                          child: Container(
                            width: width,
                            decoration: BoxDecoration(
                              color: context.polaroidWhite,
                              boxShadow: [
                                BoxShadow(
                                  color: context.textCharcoal
                                      .withValues(alpha: 0.2 * t),
                                  blurRadius: 24,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            padding: EdgeInsets.fromLTRB(
                              12,
                              12,
                              12,
                              width * 0.14,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(2),
                                  child: SizedBox(
                                    width: width - 24,
                                    height: imageHeight,
                                    child: photoUrl == null
                                        ? const _PolaroidImagePlaceholder()
                                        : Image.network(
                                            photoUrl,
                                            width: width - 24,
                                            height: imageHeight,
                                            fit: BoxFit.cover,
                                            loadingBuilder:
                                                (context, child, progress) {
                                              if (progress == null) {
                                                return child;
                                              }

                                              return const _PolaroidImagePlaceholder(
                                                loading: true,
                                              );
                                            },
                                            errorBuilder: (context, error,
                                                    stackTrace) =>
                                                const _PolaroidImagePlaceholder(),
                                          ),
                                  ),
                                ),
                                if (member.hasName) ...[
                                  SizedBox(height: width * 0.07),
                                  Text(
                                    member.displayName,
                                    textAlign: TextAlign.center,
                                    style: context.scriptHero(
                                      fontSize: 26,
                                      height: 1.15,
                                    ),
                                  ),
                                ],
                                if (caption.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text.rich(
                                    TextSpan(
                                      style: context.timelineBody().copyWith(
                                            fontSize: 13,
                                            height: 1.45,
                                            color: context.textCharcoal
                                                .withValues(alpha: 0.78),
                                          ),
                                      children: caption.toInlineMarkdownSpans(),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ],
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

class _PolaroidImagePlaceholder extends StatelessWidget {
  const _PolaroidImagePlaceholder({
    this.loading = false,
  });

  final bool loading;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.creamBackground,
      child: Center(
        child: loading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: context.colorScheme.tertiary.withValues(alpha: 0.7),
                ),
              )
            : Icon(
                Icons.image_outlined,
                size: 36,
                color: context.colorScheme.primary.withValues(alpha: 0.4),
              ),
      ),
    );
  }
}
