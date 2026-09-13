import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../content/repositories/wedding_content_repository.dart';
import '../../models/app/app_page.dart';
import '../../models/faq/faq_item.dart';
import '../../router/app_router.gr.dart';
import '../../utils/extension/string_extension.dart';
import '../../widgets/heart_divider.dart';
import '../../widgets/page_availability_gate.dart';
import '../../widgets/wedding_action_button.dart';
import '../../utils/extension/context_extension.dart';

const _faqs = [
  FaqItem(
    question: 'CAN I BRING A PLUS ONE?',
    answer:
        "We've reserved a seat just for you. If your invitation includes a plus one, you'll see it on your RSVP card.",
  ),
  FaqItem(
    question: 'ARE CHILDREN INVITED?',
    answer: 'Absolutely! We are delighted to celebrate with your little ones. '
        'We respectfully ask that parents keep children supervised '
        'during the Nuptials and First Dance, so that everyone can enjoy '
        'these special moments.',
  ),
  FaqItem(
    question: 'WHAT TIME SHOULD I ARRIVE?',
    answer:
        'We kindly ask guests to arrive 30 minutes before the ceremony begins to allow time for parking, seating, and settling in. The ceremony will start promptly, so please ensure you are seated before the scheduled start time. ',
  ),
  FaqItem(
    question: 'IS PARKING AVAILABLE?',
    answer:
        'Yes — free parking is available on site at both the church and reception venue. '
        'If you would rather not drive, Rickmansworth Station is a few minutes away by taxi.',
  ),
  FaqItem(
    question: 'WHAT IS THE DRESS CODE?',
    answer:
        'Our wedding dress code is Formal Attire. Think elegant, timeless, and occasion-worthy. We encourage guests to dress comfortably while embracing the joy and significance of this auspicious occasion.',
  ),
  FaqItem(
    question: 'WILL THE WEDDING BE INDOORS?',
    answer: 'Yes, both the nuptials and reception will be indoors.',
  ),
  FaqItem(
    question: 'WHEN SHOULD I RSVP BY?',
    answer: 'RSVPs closed on 17th July 2026. The guest list is now final — '
        'if you still need to get in touch about attendance, please contact us directly.',
  ),
];

@RoutePage()
class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  static void push(BuildContext context) {
    context.router.navigate(const FaqRoute());
  }

  @override
  Widget build(BuildContext context) {
    return PageAvailabilityGate(
      page: AppPage.faq,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _FaqHeader(),
            const SizedBox(height: 22),
            const HeartDivider(),
            const SizedBox(height: 22),
            for (var i = 0; i < _faqs.length; i++) ...[
              _FaqAccordionTile(item: _faqs[i]),
              if (i < _faqs.length - 1) const SizedBox(height: 12),
            ],
            const SizedBox(height: 32),
            const _FaqContactSection(),
          ],
        ),
      ),
    );
  }
}

class _FaqHeader extends StatelessWidget {
  const _FaqHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Frequently Asked Questions',
          textAlign: TextAlign.center,
          style: context.scriptHero(fontSize: 48, height: 1.08),
        ),
        const SizedBox(height: 10),
        Text(
          'EVERYTHING YOU NEED TO KNOW',
          textAlign: TextAlign.center,
          style: context.capsLabel(
            color: context.sageGreen,
          ),
        ),
      ],
    );
  }
}

class _FaqAccordionTile extends HookWidget {
  const _FaqAccordionTile({required this.item});

  final FaqItem item;

  @override
  Widget build(BuildContext context) {
    final expanded = useState(false);

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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Material(
          color: Colors.transparent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InkWell(
                onTap: () => expanded.value = !expanded.value,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.question,
                          style: context.faqQuestion(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      AnimatedRotation(
                        turns: expanded.value ? 0.125 : 0,
                        duration: const Duration(milliseconds: 200),
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
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                alignment: Alignment.topCenter,
                child: expanded.value
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                        child: Text(
                          item.answer.withSuperscriptOrdinals(),
                          style: context.faqAnswer(),
                        ),
                      )
                    : const SizedBox(width: double.infinity),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FaqContactSection extends ConsumerWidget {
  const _FaqContactSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final email =
        ref.watch(weddingContentRepositoryProvider).requireValue.contact.email;

    return Column(
      children: [
        Text(
          'Still have a question? Feel free to contact us.',
          textAlign: TextAlign.center,
          style: context.scriptHero(fontSize: 28, height: 1.35),
        ),
        const SizedBox(height: 20),
        Center(
          child: WeddingActionButton(
            label: 'CONTACT US',
            onPressed: () async {
              final opened = await context.openContactEmail(email);
              if (!opened && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Could not open email for $email.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
