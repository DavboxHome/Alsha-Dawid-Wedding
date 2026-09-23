import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../content/repositories/wedding_content_repository.dart';
import '../../models/app/app_page.dart';
import '../../models/content/content.dart';
import '../../router/app_router.gr.dart';
import '../../utils/extension/context_extension.dart';
import '../../widgets/heart_divider.dart';
import '../../widgets/lazy_cms_image.dart';
import '../../widgets/page_availability_gate.dart';

@RoutePage()
class FoodPage extends ConsumerWidget {
  const FoodPage({super.key});

  static void push(BuildContext context) {
    context.router.navigate(const FoodRoute());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final food = ref.watch(weddingContentRepositoryProvider).requireValue.food;

    return PageAvailabilityGate(
      page: AppPage.food,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _FoodHeader(),
            const SizedBox(height: 22),
            const HeartDivider(),
            const SizedBox(height: 22),
            _FoodMenuBody(
              food: food,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _FoodHeader extends StatelessWidget {
  const _FoodHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Food & Menu',
          textAlign: TextAlign.center,
          style: context.scriptHero(
            fontSize: 48,
            height: 1.08,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'A FEAST OF TWO CULTURES',
          textAlign: TextAlign.center,
          style: context.capsLabel(
            color: context.sageGreen,
          ),
        ),
      ],
    );
  }
}

class _FoodMenuBody extends HookWidget {
  const _FoodMenuBody({
    required this.food,
  });

  final List<WeddingFoodList> food;

  @override
  Widget build(BuildContext context) {
    final hasGoan =
        food.any((foodList) => foodList.parsedCulture == FoodCulture.goan);

    final hasPolish =
        food.any((foodList) => foodList.parsedCulture == FoodCulture.polish);

    final initialCulture = hasGoan
        ? FoodCulture.goan
        : hasPolish
            ? FoodCulture.polish
            : FoodCulture.goan;

    final culture = useState(initialCulture);

    WeddingFoodList? selectedFood;

    for (final foodList in food) {
      if (foodList.parsedCulture == culture.value) {
        selectedFood = foodList;
        break;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CulturePillSwitch(
          selected: culture.value,
          onChanged: (value) => culture.value = value,
        ),
        const SizedBox(height: 24),
        Text(
          culture.value == FoodCulture.polish
              ? 'Polish classics from Dawid\'s side of the family.'
              : 'Goan flavours from Alisha\'s side of the family.',
          textAlign: TextAlign.center,
          style: context.bodySerif(
            fontSize: 14.5,
          ),
        ),
        const SizedBox(height: 28),
        if (selectedFood == null)
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 24,
            ),
            child: Text(
              'Menu coming soon.',
              textAlign: TextAlign.center,
              style: context.bodySerif(
                fontSize: 14.5,
              ),
            ),
          )
        else
          for (final (index, course) in FoodCourse.values.indexed) ...[
            _FoodCourseSection(
              course: course,
              food: selectedFood,
            ),
            if (index < FoodCourse.values.length - 1)
              const SizedBox(height: 28),
          ],
      ],
    );
  }
}

class _CulturePillSwitch extends StatelessWidget {
  const _CulturePillSwitch({
    required this.selected,
    required this.onChanged,
  });

  final FoodCulture selected;
  final ValueChanged<FoodCulture> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.creamBackground.withValues(
          alpha: 0.9,
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: context.goldBrass.withValues(
            alpha: 0.35,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: context.textCharcoal.withValues(
              alpha: 0.05,
            ),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final halfWidth = constraints.maxWidth / 2;

            return Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(
                    milliseconds: 220,
                  ),
                  curve: Curves.easeOut,
                  left: selected == FoodCulture.polish ? 0 : halfWidth,
                  top: 0,
                  bottom: 0,
                  width: halfWidth,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: context.colorScheme.primary,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: [
                        BoxShadow(
                          color: context.colorScheme.primary.withValues(
                            alpha: 0.25,
                          ),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    _CulturePillOption(
                      label: 'POLISH',
                      selected: selected == FoodCulture.polish,
                      onTap: () => onChanged(FoodCulture.polish),
                    ),
                    _CulturePillOption(
                      label: 'GOAN',
                      selected: selected == FoodCulture.goan,
                      onTap: () => onChanged(FoodCulture.goan),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CulturePillOption extends StatelessWidget {
  const _CulturePillOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 13,
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: context.capsLabel(
                fontSize: 11.5,
                letterSpacing: 2.2,
                color: selected
                    ? context.colorScheme.onPrimary
                    : context.colorScheme.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FoodCourseSection extends StatelessWidget {
  const _FoodCourseSection({
    required this.course,
    required this.food,
  });

  final FoodCourse course;
  final WeddingFoodList food;

  @override
  Widget build(BuildContext context) {
    final items = food.items
        .where(
          (item) => item.parsedCourse == course,
        )
        .toList(
          growable: false,
        );

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          course.displayName,
          textAlign: TextAlign.center,
          style: context.cardTitleCaps(
            fontSize: 14,
            letterSpacing: 2.4,
            color: context.sageGreen,
          ),
        ),
        const SizedBox(height: 14),
        for (var i = 0; i < items.length; i++) ...[
          _FoodAccordionTile(
            item: items[i],
          ),
          if (i < items.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _FoodAccordionTile extends HookWidget {
  const _FoodAccordionTile({
    required this.item,
  });

  final WeddingFoodItem item;

  @override
  Widget build(BuildContext context) {
    final expanded = useState(false);

    final description = item.description?.trim() ?? '';

    final contains = item.contains?.trim() ?? '';

    final allergens = item.allergens?.trim() ?? '';

    final spiceLevel = item.spiceLevel?.trim() ?? '';

    final wikipediaUrl = item.wikipediaUrl?.trim() ?? '';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.creamBackground.withValues(
          alpha: 0.85,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.goldBrass.withValues(
            alpha: 0.22,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: context.textCharcoal.withValues(
              alpha: 0.06,
            ),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Material(
          color: Colors.transparent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InkWell(
                onTap: () {
                  expanded.value = !expanded.value;
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    14,
                    14,
                    14,
                    14,
                  ),
                  child: Row(
                    children: [
                      _FoodItemImage(
                        imageUrl: item.imageUrl,
                        width: 64,
                        height: 64,
                        borderRadius: 10,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          item.name.trim(),
                          style: context.faqQuestion(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      AnimatedRotation(
                        turns: expanded.value ? 0.125 : 0,
                        duration: const Duration(
                          milliseconds: 200,
                        ),
                        curve: Curves.easeOut,
                        child: Text(
                          '+',
                          style: context.faqToggle(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedSize(
                duration: const Duration(
                  milliseconds: 220,
                ),
                curve: Curves.easeOut,
                alignment: Alignment.topCenter,
                child: expanded.value
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(
                          14,
                          0,
                          14,
                          18,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _FoodItemImage(
                              imageUrl: item.imageUrl,
                              height: 180,
                              borderRadius: 10,
                            ),
                            if (description.isNotEmpty) ...[
                              const SizedBox(
                                height: 14,
                              ),
                              Text(
                                description,
                                style: context.faqAnswer(),
                              ),
                            ],
                            if (contains.isNotEmpty) ...[
                              const SizedBox(
                                height: 14,
                              ),
                              _FoodDetailLine(
                                label: 'CONTAINS',
                                value: contains,
                              ),
                            ],
                            if (allergens.isNotEmpty) ...[
                              const SizedBox(
                                height: 10,
                              ),
                              _FoodDetailLine(
                                label: 'ALLERGENS',
                                value: allergens,
                              ),
                            ],
                            if (spiceLevel.isNotEmpty) ...[
                              const SizedBox(
                                height: 10,
                              ),
                              _FoodDetailLine(
                                label: 'SPICE',
                                value: spiceLevel,
                              ),
                            ],
                            if (wikipediaUrl.isNotEmpty) ...[
                              const SizedBox(
                                height: 16,
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton.icon(
                                  onPressed: () async {
                                    final opened =
                                        await context.openExternalUrl(
                                      Uri.parse(
                                        wikipediaUrl,
                                      ),
                                    );

                                    if (!opened && context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Could not open Wikipedia link.',
                                          ),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    }
                                  },
                                  icon: Icon(
                                    Icons.open_in_new_rounded,
                                    size: 16,
                                    color: context.colorScheme.primary,
                                  ),
                                  label: Text(
                                    'READ MORE ON WIKIPEDIA',
                                    style: context.capsLabel(
                                      fontSize: 10.5,
                                      letterSpacing: 1.6,
                                      color: context.colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      )
                    : const SizedBox(
                        width: double.infinity,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FoodDetailLine extends StatelessWidget {
  const _FoodDetailLine({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.capsLabel(
            fontSize: 10,
            letterSpacing: 1.8,
            color: context.sageGreen,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: context.faqAnswer(),
        ),
      ],
    );
  }
}

class _FoodItemImage extends StatelessWidget {
  const _FoodItemImage({
    required this.imageUrl,
    this.width,
    required this.height,
    required this.borderRadius,
  });

  final String? imageUrl;
  final double? width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim();

    if (url == null || url.isEmpty) {
      return SizedBox(
        width: width,
        height: height,
        child: _FoodImagePlaceholder(
          height: height,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: width,
        height: height,
        child: LazyCmsImage(
          imageUrl: url,
          width: width,
          height: height,
          placeholderBuilder: (
            context, {
            required loading,
          }) {
            return _FoodImagePlaceholder(
              height: height,
            );
          },
        ),
      ),
    );
  }
}

class _FoodImagePlaceholder extends StatelessWidget {
  const _FoodImagePlaceholder({
    required this.height,
  });

  final double height;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.sageGreen.withValues(
              alpha: 0.25,
            ),
            context.goldBrass.withValues(
              alpha: 0.18,
            ),
          ],
        ),
        border: Border.all(
          color: context.goldBrass.withValues(
            alpha: 0.2,
          ),
        ),
      ),
      child: Center(
        child: Icon(
          Icons.restaurant_menu_rounded,
          size: height < 100 ? 24 : 36,
          color: context.colorScheme.primary.withValues(
            alpha: 0.45,
          ),
        ),
      ),
    );
  }
}
