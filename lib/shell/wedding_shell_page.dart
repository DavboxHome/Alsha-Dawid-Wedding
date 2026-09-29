import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../features/home/home_page.dart';
import '../router/app_router.gr.dart';
import '../utils/extension/context_extension.dart';
import '../utils/website_refresh.dart';
import '../widgets/hard_edge_color.dart';
import '../widgets/swipe_scroll_hint.dart';
import '../widgets/wedding_app_bar.dart';
import '../widgets/wedding_drawer.dart';
import '../widgets/wedding_footer.dart';

const _footerTopSpacing = 40.0;

@RoutePage()
class WeddingShellPage extends StatelessWidget {
  const WeddingShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoRouter(
      builder: (routerContext, child) {
        return _WeddingShellScaffold(
          routerContext: routerContext,
          child: child,
        );
      },
    );
  }
}

class _WeddingShellScaffold extends HookConsumerWidget {
  const _WeddingShellScaffold({
    required this.routerContext,
    required this.child,
  });

  final BuildContext routerContext;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = useScrollController();
    final activeRouteName = routerContext.router.current.name;
    final previousRouteName = useRef(activeRouteName);

    final isOurStory = activeRouteName == OurStoryRoute.name;
    final showStoryScrollHint = useState(false);

    void scrollToTop() {
      if (scrollController.hasClients) {
        scrollController.jumpTo(0);
      }
    }

    void scrollToTopAfterFrame() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollToTop();
      });
    }

    useEffect(
      () {
        if (previousRouteName.value != activeRouteName) {
          previousRouteName.value = activeRouteName;
          scrollToTopAfterFrame();
        }

        return null;
      },
      [activeRouteName],
    );

    useEffect(
      () {
        showStoryScrollHint.value = false;

        if (!isOurStory) {
          return null;
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted || !scrollController.hasClients) {
            return;
          }

          final position = scrollController.position;

          showStoryScrollHint.value =
              position.maxScrollExtent > 0 && position.pixels <= 0;
        });

        return null;
      },
      [activeRouteName],
    );

    void goHome() {
      final isAlreadyHome = activeRouteName == HomeRoute.name;

      HomePage.push(routerContext);

      if (isAlreadyHome) {
        scrollToTopAfterFrame();
      }
    }

    void onNavigate(String routeName) {
      if (activeRouteName == routeName) {
        scrollToTopAfterFrame();
      }
    }

    return Scaffold(
      backgroundColor: context.creamBackground,
      drawer: WeddingDrawer(
        routerContext: routerContext,
        onNavigate: onNavigate,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    NotificationListener<UserScrollNotification>(
                      onNotification: (notification) {
                        if (isOurStory &&
                            showStoryScrollHint.value &&
                            notification.direction != ScrollDirection.idle) {
                          showStoryScrollHint.value = false;
                        }

                        return false;
                      },
                      child: CustomScrollView(
                        controller: scrollController,
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        slivers: [
                          WeddingAppBar(onHomeTap: goHome),
                          CupertinoSliverRefreshControl(
                            onRefresh: () => ref
                                .read(websiteRefreshProvider.notifier)
                                .refresh(),
                            builder: (
                              context,
                              refreshState,
                              pulledExtent,
                              refreshTriggerPullDistance,
                              refreshIndicatorExtent,
                            ) {
                              final progress =
                                  (pulledExtent / refreshTriggerPullDistance)
                                      .clamp(0.0, 1.0);

                              final isRefreshing = refreshState ==
                                      RefreshIndicatorMode.refresh ||
                                  refreshState == RefreshIndicatorMode.done;

                              return SizedBox(
                                height: pulledExtent,
                                child: Center(
                                  child: isRefreshing
                                      ? CircularProgressIndicator(
                                          color: context.colorScheme.primary,
                                        )
                                      : Opacity(
                                          opacity: progress,
                                          child: CircularProgressIndicator(
                                            value: progress == 1.0
                                                ? null
                                                : progress,
                                            color: context.colorScheme.primary,
                                          ),
                                        ),
                                ),
                              );
                            },
                          ),
                          SliverToBoxAdapter(
                            child: HardEdgeColor(
                              color: context.creamBackground,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _WeddingSectionTransition(
                                    routeName: activeRouteName,
                                    child: child,
                                  ),
                                  const SizedBox(
                                    height: _footerTopSpacing,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isOurStory)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 18,
                        child: Center(
                          child: SwipeScrollHint(
                            visible: showStoryScrollHint.value,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              WeddingFooter(
                routerContext: routerContext,
                onNavigate: onNavigate,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeddingSectionTransition extends HookWidget {
  const _WeddingSectionTransition({
    required this.routeName,
    required this.child,
  });

  final String routeName;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 220),
      initialValue: 1,
    );

    final previousRouteName = useRef(routeName);

    final fadeAnimation = useMemoized(
      () => controller.drive(
        CurveTween(curve: Curves.easeOutCubic),
      ),
      [controller],
    );

    useEffect(
      () {
        if (previousRouteName.value != routeName) {
          previousRouteName.value = routeName;
          controller.forward(from: 0);
        }

        return null;
      },
      [routeName],
    );

    return FadeTransition(
      opacity: fadeAnimation,
      child: child,
    );
  }
}
