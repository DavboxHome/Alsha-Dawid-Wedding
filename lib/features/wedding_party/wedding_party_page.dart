import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../content/repositories/wedding_content_repository.dart';
import '../../models/app/app_page.dart';
import '../../models/content/content.dart';
import '../../router/app_router.gr.dart';
import '../../utils/extension/context_extension.dart';
import '../../widgets/heart_divider.dart';
import '../../widgets/lazy_cms_image.dart';
import '../../widgets/page_availability_gate.dart';
import '../../widgets/party_member_polaroid_overlay.dart';

@RoutePage()
class WeddingPartyPage extends ConsumerWidget {
  const WeddingPartyPage({super.key});

  static void push(BuildContext context) {
    context.router.navigate(const WeddingPartyRoute());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final party =
        ref.watch(weddingContentRepositoryProvider).requireValue.weddingParty;
    final flowerGirls = _visibleMembers(party.flowerGirls);
    final pageBoys = _visibleMembers(party.pageBoys);

    return PageAvailabilityGate(
      page: AppPage.weddingParty,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _PartyHeader(),
            const SizedBox(height: 28),
            _PartySection(
              section: WeddingPartySection.dogs,
              members: party.dogs,
            ),
            const SizedBox(height: 28),
            const HeartDivider(),
            const SizedBox(height: 28),
            _PartySection(
              section: WeddingPartySection.parents,
              members: party.parents,
            ),
            if (flowerGirls.isNotEmpty || pageBoys.isNotEmpty) ...[
              const SizedBox(height: 28),
              const HeartDivider(),
              const SizedBox(height: 28),
              if (flowerGirls.isNotEmpty && pageBoys.isNotEmpty)
                _PartySectionPair(
                  leftSection: WeddingPartySection.flowerGirls,
                  rightSection: WeddingPartySection.pageBoys,
                  leftMembers: flowerGirls,
                  rightMembers: pageBoys,
                )
              else if (flowerGirls.isNotEmpty)
                _PartySection(
                  section: WeddingPartySection.flowerGirls,
                  members: flowerGirls,
                )
              else
                _PartySection(
                  section: WeddingPartySection.pageBoys,
                  members: pageBoys,
                ),
            ],
            const SizedBox(height: 28),
            const HeartDivider(),
            const SizedBox(height: 28),
            _PartySectionPair(
              leftSection: WeddingPartySection.maidOfHonor,
              rightSection: WeddingPartySection.bestMan,
              leftMembers: [party.maidOfHonor],
              rightMembers: [party.bestMan],
            ),
            const SizedBox(height: 28),
            const HeartDivider(),
            const SizedBox(height: 28),
            _PartySection(
              section: WeddingPartySection.groomsmen,
              members: party.groomsmen,
            ),
            const SizedBox(height: 28),
            const HeartDivider(),
            const SizedBox(height: 28),
            _PartySection(
              section: WeddingPartySection.bridesmaids,
              members: party.bridesmaids,
            ),
            const SizedBox(height: 28),
            const HeartDivider(),
            const SizedBox(height: 28),
            _PartySection(
              section: WeddingPartySection.bridesquad,
              members: party.bridesquad,
            ),
          ],
        ),
      ),
    );
  }
}

List<WeddingPartyMember> _visibleMembers(List<WeddingPartyMember> members) {
  return members
      .where((member) => member.hasName || member.photoUrl != null)
      .toList();
}

class _PartyHeader extends StatelessWidget {
  const _PartyHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Our Wedding Entourage',
          textAlign: TextAlign.center,
          style: context.scriptHero(),
        ),
        const SizedBox(height: 10),
        Text(
          'THE PEOPLE BY OUR SIDE',
          textAlign: TextAlign.center,
          style: context.capsLabel(),
        ),
      ],
    );
  }
}

class _PartySectionPair extends StatelessWidget {
  const _PartySectionPair({
    required this.leftSection,
    required this.rightSection,
    required this.leftMembers,
    required this.rightMembers,
  });

  final WeddingPartySection leftSection;
  final WeddingPartySection rightSection;
  final List<WeddingPartyMember> leftMembers;
  final List<WeddingPartyMember> rightMembers;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _PartySection(
            section: leftSection,
            members: leftMembers,
            crossAxisCount: 1,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _PartySection(
            section: rightSection,
            members: rightMembers,
            crossAxisCount: 1,
          ),
        ),
      ],
    );
  }
}

class _PartySection extends StatelessWidget {
  const _PartySection({
    required this.section,
    required this.members,
    this.crossAxisCount,
  });

  final WeddingPartySection section;
  final List<WeddingPartyMember> members;
  final int? crossAxisCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          section.title,
          textAlign: TextAlign.center,
          style: context.sectionCaps(),
        ),
        const SizedBox(height: 22),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns =
                crossAxisCount ?? (constraints.maxWidth >= 520 ? 4 : 2);
            const spacing = 12.0;
            const runSpacing = 20.0;
            final mainAxisExtent = columns == 4 ? 168.0 : 176.0;
            final itemWidth =
                (constraints.maxWidth - (columns - 1) * spacing) / columns;

            return Wrap(
              alignment: WrapAlignment.center,
              spacing: spacing,
              runSpacing: runSpacing,
              children: [
                for (final member in members)
                  SizedBox(
                    width: itemWidth,
                    height: mainAxisExtent,
                    child: _PartyPortrait(
                      member: member,
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _PartyPortrait extends StatelessWidget {
  const _PartyPortrait({
    required this.member,
  });

  final WeddingPartyMember member;

  @override
  Widget build(BuildContext context) {
    const portraitSize = 104.0;
    final photoUrl = member.photoUrl;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => showPartyMemberPolaroid(
              context,
              member: member,
            ),
            child: Container(
              width: portraitSize,
              height: portraitSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: context.goldBrass.withValues(alpha: 0.35),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: context.textCharcoal.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: photoUrl == null
                    ? const _PartyPortraitPlaceholder()
                    : LazyCmsImage(
                        imageUrl: photoUrl,
                        width: portraitSize,
                        height: portraitSize,
                        placeholderBuilder: (
                          context, {
                          required loading,
                        }) {
                          return _PartyPortraitPlaceholder(
                            loading: loading,
                          );
                        },
                      ),
              ),
            ),
          ),
        ),
        if (member.hasName) ...[
          const SizedBox(height: 12),
          Text(
            member.displayName,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.portraitName(),
          ),
        ],
      ],
    );
  }
}

class _PartyPortraitPlaceholder extends StatelessWidget {
  const _PartyPortraitPlaceholder({
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
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: context.colorScheme.tertiary.withValues(alpha: 0.7),
                ),
              )
            : Icon(
                Icons.image_outlined,
                color: context.colorScheme.primary.withValues(alpha: 0.4),
              ),
      ),
    );
  }
}
