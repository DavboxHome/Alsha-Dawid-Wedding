
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/extension/context_extension.dart';

class PersistentTapHint extends HookWidget {
  const PersistentTapHint({
    required this.storageKey,
    required this.onTap,
    required this.child,
    this.tapCount = 4,
    this.yOffset = 0,
    super.key,
  });

  final String storageKey;
  final VoidCallback onTap;
  final Widget child;
  final int tapCount;
  final double yOffset;

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 1100),
    );

    final visible = useState(false);
    final ready = useState(false);
    final completedTaps = useRef(0);
    final dismissed = useRef(false);

    Future<void> dismiss() async {
      if (dismissed.value) {
        return;
      }

      dismissed.value = true;
      controller.stop();

      if (context.mounted) {
        visible.value = false;
      }

      final preferences = await SharedPreferences.getInstance();
      await preferences.setBool(storageKey, true);
    }

    useEffect(
      () {
        var disposed = false;

        Future<void> initialise() async {
          final preferences = await SharedPreferences.getInstance();

          if (disposed || !context.mounted || dismissed.value) {
            return;
          }

          if (preferences.getBool(storageKey) == true) {
            dismissed.value = true;
            return;
          }

          ready.value = true;
          visible.value = true;
          controller.forward(from: 0);
        }

        initialise();

        return () {
          disposed = true;
        };
      },
      [storageKey],
    );

    useEffect(
      () {
        void onStatusChanged(AnimationStatus status) {
          if (status != AnimationStatus.completed ||
              dismissed.value ||
              !ready.value) {
            return;
          }

          completedTaps.value++;

          if (completedTaps.value >= tapCount) {
            dismiss();
          } else {
            controller.forward(from: 0);
          }
        }

        controller.addStatusListener(onStatusChanged);

        return () {
          controller.removeStatusListener(onStatusChanged);
        };
      },
      [controller, tapCount],
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        // Opening the image must never wait for storage.
        dismiss();
        onTap();
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          child,
          Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: Transform.translate(
                  offset: Offset(0, yOffset),
                  child: AnimatedOpacity(
                    opacity: visible.value ? 1 : 0,
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutCubic,
                    child: AnimatedBuilder(
                      animation: controller,
                      builder: (context, _) {
                        final progress = controller.value;

                        final press = Curves.easeInOut.transform(
                          ((progress - 0.15) / 0.25).clamp(0.0, 1.0),
                        );

                        final release = Curves.easeInOut.transform(
                          ((progress - 0.48) / 0.25).clamp(0.0, 1.0),
                        );

                        final pressure = press * (1 - release);

                        final opacity = (progress / 0.15).clamp(0.0, 1.0) *
                            (1 -
                                ((progress - 0.80) / 0.20)
                                    .clamp(0.0, 1.0));

                        return Opacity(
                          opacity: opacity,
                          child: Transform.translate(
                            offset: Offset(0, pressure * 9),
                            child: Transform.scale(
                              scale: 1 - pressure * 0.12,
                              child: Icon(
                                Icons.touch_app_rounded,
                                size: 64,
                                color: context.burgundyAccent,
                                shadows: [
                                  Shadow(
                                    color: context.creamBackground,
                                    blurRadius: 12,
                                  ),
                                  Shadow(
                                    color: context.creamBackground,
                                    blurRadius: 20,
                                  ),
                                ],
                              ),
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
