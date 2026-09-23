import 'package:freezed_annotation/freezed_annotation.dart';

import 'cms_image.dart';

part 'our_story_photo.freezed.dart';
part 'our_story_photo.g.dart';

@freezed
class OurStoryPhoto with _$OurStoryPhoto {
  const OurStoryPhoto._();

  const factory OurStoryPhoto({
    @JsonKey(name: 'blurb') String? title,
    String? description,
    CmsImage? image,
    @Default(0) int sortOrder,
  }) = _OurStoryPhoto;

  factory OurStoryPhoto.fromJson(Map<String, dynamic> json) =>
      _$OurStoryPhotoFromJson(json);

  String? get imageUrl {
    final value = image?.previewUrl.trim();

    if (value == null || value.isEmpty) {
      return null;
    }

    return value;
  }

  bool get hasTitle => title?.trim().isNotEmpty ?? false;

  bool get hasDescription => description?.trim().isNotEmpty ?? false;
}
