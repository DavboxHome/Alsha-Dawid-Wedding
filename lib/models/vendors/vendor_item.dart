import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../content/cms_image.dart';

part 'vendor_item.freezed.dart';
part 'vendor_item.g.dart';

enum VendorCategory {
  photographyFilm('PHOTOGRAPHY & FILM'),
  floralsStyling('FLORALS & STYLING'),
  foodDrink('FOOD & DRINK'),
  musicEntertainment('MUSIC & ENTERTAINMENT'),
  beauty('BEAUTY');

  const VendorCategory(this.title);

  final String title;
}

@freezed
class VendorLinks with _$VendorLinks {
  const VendorLinks._();

  const factory VendorLinks({
    String? instagram,
    String? website,
    String? facebook,
    String? tiktok,
    String? youtube,
    String? twitter,
    String? linkedin,
    String? pinterest,
    String? reddit,
    String? telegram,
    String? whatsapp,
  }) = _VendorLinks;

  factory VendorLinks.fromJson(Map<String, dynamic> json) =>
      _$VendorLinksFromJson(json);

  Uri? get instagramUri => _socialUri(
        instagram,
        (handle) => 'https://www.instagram.com/$handle/',
      );

  Uri? get websiteUri => _absoluteUri(website);

  Uri? get facebookUri => _socialUri(
        facebook,
        (handle) => 'https://www.facebook.com/$handle/',
      );

  Uri? get tiktokUri => _socialUri(
        tiktok,
        (handle) => 'https://www.tiktok.com/@$handle/',
      );

  Uri? get youtubeUri => _socialUri(
        youtube,
        (handle) => 'https://www.youtube.com/channel/$handle/',
      );

  Uri? get twitterUri => _socialUri(
        twitter,
        (handle) => 'https://www.twitter.com/$handle/',
      );

  Uri? get linkedinUri => _socialUri(
        linkedin,
        (handle) => 'https://www.linkedin.com/in/$handle/',
      );

  Uri? get pinterestUri => _socialUri(
        pinterest,
        (handle) => 'https://www.pinterest.com/$handle/',
      );

  Uri? get redditUri => _socialUri(
        reddit,
        (handle) => 'https://www.reddit.com/user/$handle/',
      );

  Uri? get telegramUri => _socialUri(
        telegram,
        (handle) => 'https://t.me/$handle/',
      );

  Uri? get whatsappUri => _socialUri(
        whatsapp,
        (handle) => 'https://wa.me/$handle/',
      );

  String? get instagramHandle {
    final value = instagram?.trim();
    if (value == null || value.isEmpty) {
      return null;
    }

    final uri = Uri.tryParse(value);
    if (uri != null && uri.hasScheme) {
      final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
      if (segments.isEmpty) {
        return null;
      }
      return segments.first.replaceFirst(RegExp(r'^@'), '');
    }

    return value.replaceFirst(RegExp(r'^@'), '');
  }

  /// All non-null social/website links ready for display.
  List<VendorLinkEntry> get entries {
    return [
      if (instagramUri != null)
        VendorLinkEntry(
          label: '@${instagramHandle ?? 'instagram'}',
          icon: Icons.camera_alt_rounded,
          uri: instagramUri!,
        ),
      if (websiteUri != null)
        VendorLinkEntry(
          label: _websiteLabel(websiteUri!),
          icon: Icons.language_rounded,
          uri: websiteUri!,
        ),
      if (facebookUri != null)
        VendorLinkEntry(
          label: 'Facebook',
          icon: Icons.facebook,
          uri: facebookUri!,
        ),
      if (tiktokUri != null)
        VendorLinkEntry(
          label: 'TikTok',
          icon: Icons.music_note_rounded,
          uri: tiktokUri!,
        ),
      if (youtubeUri != null)
        VendorLinkEntry(
          label: 'YouTube',
          icon: Icons.play_circle_filled_rounded,
          uri: youtubeUri!,
        ),
      if (twitterUri != null)
        VendorLinkEntry(
          label: 'X',
          icon: Icons.alternate_email_rounded,
          uri: twitterUri!,
        ),
      if (linkedinUri != null)
        VendorLinkEntry(
          label: 'LinkedIn',
          icon: Icons.business_center_rounded,
          uri: linkedinUri!,
        ),
      if (pinterestUri != null)
        VendorLinkEntry(
          label: 'Pinterest',
          icon: Icons.push_pin_rounded,
          uri: pinterestUri!,
        ),
      if (redditUri != null)
        VendorLinkEntry(
          label: 'Reddit',
          icon: Icons.forum_rounded,
          uri: redditUri!,
        ),
      if (telegramUri != null)
        VendorLinkEntry(
          label: 'Telegram',
          icon: Icons.send_rounded,
          uri: telegramUri!,
        ),
      if (whatsappUri != null)
        VendorLinkEntry(
          label: 'WhatsApp',
          icon: Icons.chat_rounded,
          uri: whatsappUri!,
        ),
    ];
  }
}

class VendorLinkEntry {
  const VendorLinkEntry({
    required this.label,
    required this.icon,
    required this.uri,
  });

  final String label;
  final IconData icon;
  final Uri uri;
}

Uri? _absoluteUri(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }

  return Uri.tryParse(trimmed);
}

String _websiteLabel(Uri uri) {
  final host = uri.host.replaceFirst('www.', '');
  if (host.isNotEmpty) {
    return host;
  }

  return 'Website';
}

Uri? _socialUri(String? value, String Function(String handle) builder) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }

  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    return Uri.tryParse(trimmed);
  }

  final handle = trimmed.replaceFirst(RegExp(r'^@'), '');
  if (handle.isEmpty) {
    return null;
  }

  return Uri.parse(builder(handle));
}

@freezed
class VendorItem with _$VendorItem {
  const VendorItem._();

  const factory VendorItem({
    required String name,
    required VendorCategory category,
    String? description,
    CmsImage? logo,
    required VendorLinks links,
    @Default(0) int sortOrder,
  }) = _VendorItem;

  factory VendorItem.fromJson(Map<String, dynamic> json) =>
      _$VendorItemFromJson(json);

  String? get logoUrl {
    final value = logo?.previewUrl.trim();

    if (value == null || value.isEmpty) {
      return null;
    }

    return value;
  }

  IconData get icon => switch (category) {
        VendorCategory.photographyFilm => Icons.photo_camera_rounded,
        VendorCategory.floralsStyling => Icons.local_florist_rounded,
        VendorCategory.foodDrink => Icons.restaurant_rounded,
        VendorCategory.musicEntertainment => Icons.music_note_rounded,
        VendorCategory.beauty => Icons.spa_rounded,
      };
}
