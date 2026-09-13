import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/app/app_page.dart';
import '../../providers/gallery_shuffle_provider.dart';
import '../../providers/page_availability_provider.dart';
import '../../router/app_router.gr.dart';
import '../../utils/extension/context_extension.dart';

@RoutePage()
class SecretPage extends ConsumerWidget {
  const SecretPage({super.key});

  static void push(BuildContext context) {
    context.router.navigate(const SecretRoute());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availability = ref.watch(pageAvailabilityProvider);
    final galleryShuffleEnabled = ref.watch(galleryShuffleProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Gallery',
            textAlign: TextAlign.center,
            style: context.sectionCaps(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Shuffle photo order each time the gallery is opened.',
            textAlign: TextAlign.center,
            style: context.bodySerif(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Shuffle gallery',
              style: context.textTheme.titleSmall?.copyWith(
                letterSpacing: 0.8,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              galleryShuffleEnabled ? 'Random order' : 'CMS order',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            value: galleryShuffleEnabled,
            onChanged: (value) {
              ref.read(galleryShuffleProvider.notifier).setEnabled(value);
            },
          ),
          const SizedBox(height: 32),
          Text(
            'Page availability',
            textAlign: TextAlign.center,
            style: context.sectionCaps(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Toggle whether each page is live or under construction.',
            textAlign: TextAlign.center,
            style: context.bodySerif(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          ...AppPage.values.map(
            (page) {
              final isWorking = isPageWorking(availability, page);

              return SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  page.displayName,
                  style: context.textTheme.titleSmall?.copyWith(
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  isWorking ? 'Working' : 'Under construction',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
                value: isWorking,
                onChanged: (value) {
                  ref
                      .read(pageAvailabilityProvider.notifier)
                      .setWorking(page, value);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
