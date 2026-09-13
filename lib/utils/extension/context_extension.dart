import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

extension ContextExtension on BuildContext {
  ThemeData get theme => Theme.of(this);

  ColorScheme get colorScheme => theme.colorScheme;

  TextTheme get textTheme => theme.textTheme;

  AppBarThemeData get appBarTheme => theme.appBarTheme;

  Color get seed => AppColors.seed;

  Color get creamBackground => AppColors.creamBackground;

  Color get sageGreen => AppColors.sageGreen;

  Color get burgundyAccent => AppColors.burgundyAccent;

  Color get dustyRose => AppColors.dustyRose;

  Color get goldBrass => AppColors.goldBrass;

  Color get textCharcoal => AppColors.textCharcoal;

  Color get mauveLegacy => AppColors.mauveLegacy;

  Color get deepForest => AppColors.deepForest;

  Color get blushPeach => AppColors.blushPeach;

  Color get polaroidWhite => AppColors.polaroidWhite;

  TextStyle scriptHero({
    double fontSize = 52,
    double height = 1.05,
    Color? color,
  }) =>
      AppTypography.scriptHero(
        color: color ?? colorScheme.primary,
        fontSize: fontSize,
        height: height,
      );

  TextStyle capsLabel({
    double fontSize = 12,
    double letterSpacing = 2.6,
    double height = 1.25,
    Color? color,
    FontWeight fontWeight = FontWeight.w600,
  }) =>
      AppTypography.capsLabel(
        color: color ?? colorScheme.onSurfaceVariant,
        fontSize: fontSize,
        letterSpacing: letterSpacing,
        height: height,
        fontWeight: fontWeight,
      );

  TextStyle sectionCaps({
    double fontSize = 14,
    double letterSpacing = 2.2,
    Color? color,
  }) =>
      AppTypography.sectionCaps(
        color: color ?? colorScheme.primary,
        fontSize: fontSize,
        letterSpacing: letterSpacing,
      );

  TextStyle bodySerif({
    double fontSize = 15,
    double height = 1.55,
    Color? color,
    FontWeight fontWeight = FontWeight.w400,
  }) =>
      AppTypography.bodySerif(
        color: color ?? colorScheme.primary,
        fontSize: fontSize,
        height: height,
        fontWeight: fontWeight,
      );

  TextStyle countdownBannerTitle({
    required double fontSize,
    bool compact = false,
  }) =>
      AppTypography.countdownBannerTitle(
        color: colorScheme.primary,
        fontSize: fontSize,
        compact: compact,
      );

  TextStyle countdownNumber({required double fontSize}) =>
      AppTypography.countdownNumber(
        color: colorScheme.primary,
        fontSize: fontSize,
      );

  TextStyle countdownUnit({
    required double fontSize,
    bool compact = false,
  }) =>
      AppTypography.countdownUnit(
        color: colorScheme.primary.withValues(alpha: 0.85),
        fontSize: fontSize,
        compact: compact,
      );

  TextStyle cardTitleCaps({
    double fontSize = 13,
    double letterSpacing = 1.8,
    Color? color,
  }) =>
      AppTypography.cardTitleCaps(
        color: color ?? colorScheme.primary,
        fontSize: fontSize,
        letterSpacing: letterSpacing,
      );

  TextStyle cardTime({
    double fontSize = 20,
    Color? color,
  }) =>
      AppTypography.cardTime(
        color: color ?? colorScheme.primary,
        fontSize: fontSize,
      );

  TextStyle cardBody({
    double fontSize = 14.5,
    double height = 1.45,
    Color? color,
  }) =>
      AppTypography.cardBody(
        color: color ?? colorScheme.primary.withValues(alpha: 0.92),
        fontSize: fontSize,
        height: height,
      );

  TextStyle navCardTitle({Color? color}) => AppTypography.navCardTitle(
        color: color ?? colorScheme.tertiary,
      );

  TextStyle navCardSubtitle({Color? color}) => AppTypography.navCardSubtitle(
        color: color ?? colorScheme.primary.withValues(alpha: 0.9),
      );

  TextStyle contactLine() => AppTypography.contactLine(
        color: colorScheme.onSurfaceVariant,
      );

  TextStyle faqQuestion() => AppTypography.faqQuestion(
        color: colorScheme.primary,
      );

  TextStyle faqToggle() => AppTypography.faqToggle(
        color: colorScheme.primary.withValues(alpha: 0.75),
      );

  TextStyle faqAnswer() => AppTypography.faqAnswer(
        color: colorScheme.onSurfaceVariant,
      );

  TextStyle buttonLabel({
    double fontSize = 12.5,
    double letterSpacing = 1.6,
  }) =>
      AppTypography.buttonLabel(
        color: colorScheme.onPrimary,
        fontSize: fontSize,
        letterSpacing: letterSpacing,
      );

  TextStyle timelineTitle() => AppTypography.timelineTitle(
        color: colorScheme.primary,
      );

  TextStyle timelineBody() => AppTypography.timelineBody(
        color: colorScheme.onSurfaceVariant,
      );

  TextStyle portraitName() => AppTypography.portraitName(
        color: colorScheme.onSurface,
      );

  TextStyle portraitInitials() => AppTypography.portraitInitials(
        color: colorScheme.primary.withValues(alpha: 0.55),
      );

  Future<bool> openExternalUrl(Uri uri) {
    return launchUrl(
      uri,
      webOnlyWindowName: kIsWeb ? '_blank' : null,
      mode:
          kIsWeb ? LaunchMode.platformDefault : LaunchMode.externalApplication,
    );
  }

  Uri contactEmailUri(String email) => Uri(
        scheme: 'mailto',
        path: email,
      );

  Future<bool> openContactEmail(String email) {
    return launchUrl(contactEmailUri(email));
  }

  Uri venueMapUri(String query) {
    final encoded = Uri.encodeComponent(query);

    if (kIsWeb) {
      return Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$encoded',
      );
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.iOS => Uri.parse('https://maps.apple.com/?q=$encoded'),
      _ => Uri.parse('geo:0,0?q=$encoded'),
    };
  }

  Future<void> openVenueMap(String query) async {
    final uri = venueMapUri(query);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
