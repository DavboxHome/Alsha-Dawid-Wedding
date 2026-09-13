import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/content/content.dart';
import '../content/repositories/wedding_content_repository.dart';
import '../models/shell/footer_nav_action.dart';
import '../features/wedding_details/wedding_details_page.dart';
import '../router/app_router.gr.dart';
import 'hard_edge_color.dart';
import 'line_icon.dart';
import '../utils/extension/context_extension.dart';

/// Fixed footer with quick links — pinned to the bottom of every shell page.
class WeddingFooter extends ConsumerWidget {
  const WeddingFooter({
    required this.routerContext,
    this.onNavigate,
    super.key,
  });

  final BuildContext routerContext;
  final void Function(String routeName)? onNavigate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(weddingContentRepositoryProvider).requireValue;
    final activeRoute = routerContext.router.current.name;
    final compact = MediaQuery.sizeOf(context).width < 360;
    final contactHorizontalPadding = compact ? 16.0 : 40.0;

    return HardEdgeColor(
      color: context.burgundyAccent,
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  for (final (i, action) in FooterNavAction.values.indexed) ...[
                    if (i > 0)
                      VerticalDivider(
                        width: 1,
                        thickness: 1,
                        indent: 8,
                        endIndent: 8,
                        color: context.goldBrass.withValues(alpha: 0.35),
                      ),
                    Expanded(
                      child: _FooterNavButton(
                        action: action,
                        selected: action == FooterNavAction.schedule &&
                            activeRoute == WeddingDetailsRoute.name,
                        onTap: () => _onNavTap(
                          context: context,
                          action: action,
                          content: content,
                          activeRoute: activeRoute,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: EdgeInsets.fromLTRB(
                contactHorizontalPadding,
                0,
                contactHorizontalPadding,
                16,
              ),
              child: _FooterContactInfo(content: content),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _onNavTap({
    required BuildContext context,
    required FooterNavAction action,
    required WeddingContent content,
    required String activeRoute,
  }) async {
    switch (action) {
      case FooterNavAction.venueMap:
        await context.openVenueMap(content.links.venueMapQuery);
        return;
      case FooterNavAction.liveUpdates:
        final opened = await context.openExternalUrl(
          Uri.parse(content.links.liveUpdatesUrl),
        );
        if (!opened && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open live updates.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      case FooterNavAction.schedule:
        final routeName = WeddingDetailsRoute.name;
        if (activeRoute == routeName) {
          onNavigate?.call(routeName);
          return;
        }
        WeddingDetailsPage.push(routerContext);
    }
  }
}

class _FooterContactInfo extends StatelessWidget {
  const _FooterContactInfo({required this.content});

  final WeddingContent content;

  @override
  Widget build(BuildContext context) {
    final lineStyle = context.contactLine().copyWith(
          fontSize: 12,
          color: Colors.white.withValues(alpha: 0.85),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        _FooterContactLine(
          icon: LineIconVariant.email,
          label: content.contact.email,
          style: lineStyle,
          onTap: () async {
            final opened =
                await context.openContactEmail(content.contact.email);
            if (!opened && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Could not open email for ${content.contact.email}.',
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
        ),
        const SizedBox(height: 6),
      ],
    );
  }
}

class _FooterContactLine extends StatelessWidget {
  const _FooterContactLine({
    required this.icon,
    required this.label,
    required this.style,
    this.onTap,
  });

  final LineIconVariant icon;
  final String label;
  final TextStyle style;
  final VoidCallback? onTap;

  static const _iconSize = 16.0;

  @override
  Widget build(BuildContext context) {
    final row = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        LineIcon(
          variant: icon,
          size: _iconSize,
          color: context.goldBrass,
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            label,
            textAlign: TextAlign.left,
            style: style,
          ),
        ),
      ],
    );

    if (onTap == null) {
      return row;
    }

    return InkWell(
      onTap: onTap,
      child: row,
    );
  }
}

class _FooterNavButton extends StatelessWidget {
  const _FooterNavButton({
    required this.action,
    required this.selected,
    required this.onTap,
  });

  final FooterNavAction action;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final labelColor =
        selected ? context.goldBrass : Colors.white.withValues(alpha: 0.92);

    return Material(
      color:
          selected ? Colors.white.withValues(alpha: 0.08) : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LineIcon(
                variant: action.icon,
                size: 28,
                color: context.goldBrass,
              ),
              const SizedBox(height: 6),
              Text(
                action.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.navCardTitle(
                  color: labelColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
