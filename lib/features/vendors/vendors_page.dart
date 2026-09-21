import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../content/repositories/vendors_repository.dart';
import '../../models/app/app_page.dart';
import '../../models/vendors/vendor_item.dart';
import '../../router/app_router.gr.dart';
import '../../widgets/heart_divider.dart';
import '../../widgets/page_availability_gate.dart';
import '../../utils/extension/context_extension.dart';

@RoutePage()
class VendorsPage extends ConsumerWidget {
  const VendorsPage({super.key});

  static void push(BuildContext context) {
    context.router.navigate(const VendorsRoute());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vendorsAsync = ref.watch(vendorsRepositoryProvider);

    return PageAvailabilityGate(
      page: AppPage.vendors,
      child: vendorsAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.symmetric(vertical: 48),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (error, _) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: Text(
            'Could not load vendors.\n$error',
            textAlign: TextAlign.center,
            style: context.bodySerif(fontSize: 14.5),
          ),
        ),
        data: (vendors) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _VendorsHeader(),
              const SizedBox(height: 22),
              const HeartDivider(),
              const SizedBox(height: 22),
              Text(
                'The wonderful people helping us bring our day to life. '
                'Tap a link to visit them online.',
                textAlign: TextAlign.center,
                style: context.bodySerif(fontSize: 14.5),
              ),
              const SizedBox(height: 28),
              for (final (i, category) in VendorCategory.values.indexed) ...[
                _VendorCategorySection(
                  category: category,
                  vendors: vendors,
                ),
                if (i < VendorCategory.values.length - 1)
                  const SizedBox(height: 28),
              ],
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _VendorsHeader extends StatelessWidget {
  const _VendorsHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Our Vendors',
          textAlign: TextAlign.center,
          style: context.scriptHero(fontSize: 48, height: 1.08),
        ),
        const SizedBox(height: 10),
        Text(
          'THE TEAM BEHIND THE DAY',
          textAlign: TextAlign.center,
          style: context.capsLabel(
            color: context.sageGreen,
          ),
        ),
      ],
    );
  }
}

class _VendorCategorySection extends StatelessWidget {
  const _VendorCategorySection({
    required this.category,
    required this.vendors,
  });

  final VendorCategory category;
  final List<VendorItem> vendors;

  @override
  Widget build(BuildContext context) {
    final vendors = this.vendors.where((v) => v.category == category).toList();

    if (vendors.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          category.title,
          textAlign: TextAlign.center,
          style: context.cardTitleCaps(
            fontSize: 14,
            letterSpacing: 2.4,
            color: context.sageGreen,
          ),
        ),
        const SizedBox(height: 14),
        for (var i = 0; i < vendors.length; i++) ...[
          _VendorTile(item: vendors[i]),
          if (i < vendors.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _VendorTile extends StatelessWidget {
  const _VendorTile({required this.item});

  final VendorItem item;

  @override
  Widget build(BuildContext context) {
    final links = item.links.entries;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.creamBackground.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.goldBrass.withValues(alpha: 0.22),
        ),
        boxShadow: [
          BoxShadow(
            color: context.textCharcoal.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Row(
          children: [
            _VendorIconBadge(
              icon: item.icon,
              logoUrl: item.logoUrl,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: context.faqQuestion(),
                  ),
                  if (links.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final link in links)
                          _VendorLinkChip(
                            icon: link.icon,
                            label: link.label,
                            uri: link.uri,
                            vendorName: item.name,
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VendorLinkChip extends StatelessWidget {
  const _VendorLinkChip({
    required this.icon,
    required this.label,
    required this.uri,
    required this.vendorName,
  });

  final IconData icon;
  final String label;
  final Uri uri;
  final String vendorName;

  Future<void> _open(BuildContext context) async {
    final opened = await context.openExternalUrl(uri);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open link for $vendorName.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () => _open(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: context.creamBackground.withValues(alpha: 0.6),
            border: Border.all(
              color: context.goldBrass.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: context.colorScheme.primary.withValues(alpha: 0.75),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: context.bodySerif(
                  fontSize: 12.5,
                  height: 1.1,
                  color: context.sageGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VendorIconBadge extends StatelessWidget {
  const _VendorIconBadge({
    required this.icon,
    this.logoUrl,
  });

  final IconData icon;
  final String? logoUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.sageGreen.withValues(alpha: 0.22),
            context.goldBrass.withValues(alpha: 0.18),
          ],
        ),
        border: Border.all(
          color: context.goldBrass.withValues(alpha: 0.28),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: logoUrl == null
          ? Center(
              child: Icon(
                icon,
                size: 20,
                color: context.colorScheme.primary.withValues(alpha: 0.75),
              ),
            )
          : Image.network(
              logoUrl!,
              width: 44,
              height: 44,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Center(
                child: Icon(
                  icon,
                  size: 20,
                  color: context.colorScheme.primary.withValues(alpha: 0.75),
                ),
              ),
            ),
    );
  }
}
