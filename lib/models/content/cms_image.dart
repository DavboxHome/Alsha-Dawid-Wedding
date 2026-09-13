import 'package:freezed_annotation/freezed_annotation.dart';

import '../../config/strapi_config.dart';

part 'cms_image.freezed.dart';
part 'cms_image.g.dart';

@freezed
class CmsImage with _$CmsImage {
  const CmsImage._();

  const factory CmsImage({
    required String url,
    @JsonKey(
      name: 'formats',
      fromJson: _formatUrlsFromJson,
      toJson: _formatUrlsToJson,
    )
    @Default(<String, String>{})
    Map<String, String> formatUrls,
  }) = _CmsImage;

  factory CmsImage.fromJson(Map<String, dynamic> json) =>
      _$CmsImageFromJson(json);

  String get absoluteUrl => StrapiConfig.mediaUrl(url);

  String get previewUrl => StrapiConfig.mediaUrl(
        formatUrls['small'] ??
            formatUrls['medium'] ??
            formatUrls['thumbnail'] ??
            url,
      );
}

Map<String, String> _formatUrlsFromJson(Object? value) {
  if (value is! Map) {
    return const <String, String>{};
  }

  final urls = <String, String>{};

  for (final entry in value.entries) {
    final format = entry.value;
    if (entry.key is! String || format is! Map) {
      continue;
    }

    final url = format['url'];
    if (url is String && url.trim().isNotEmpty) {
      urls[entry.key as String] = url;
    }
  }

  return urls;
}

Map<String, dynamic> _formatUrlsToJson(Map<String, String> value) {
  return value.map(
    (format, url) => MapEntry(
      format,
      <String, dynamic>{'url': url},
    ),
  );
}
