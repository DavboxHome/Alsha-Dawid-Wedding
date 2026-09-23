import 'package:freezed_annotation/freezed_annotation.dart';

import 'cms_image.dart';
import 'food_course.dart';

part 'wedding_food_item.freezed.dart';
part 'wedding_food_item.g.dart';

@freezed
class WeddingFoodItem with _$WeddingFoodItem {
  const WeddingFoodItem._();

  const factory WeddingFoodItem({
    required String name,
    required String culture,
    String? description,
    String? contains,
    String? allergens,
    String? spiceLevel,
    String? wikipediaUrl,
    String? course,
    CmsImage? image,
    @Default(0) int sortOrder,
  }) = _WeddingFoodItem;

  factory WeddingFoodItem.fromJson(Map<String, dynamic> json) =>
      _$WeddingFoodItemFromJson(json);

  FoodCourse? get parsedCourse {
    final value = course?.trim().toLowerCase();

    for (final course in FoodCourse.values) {
      if (course.name.toLowerCase() == value) {
        return course;
      }
    }

    return null;
  }

  String? get imageUrl {
    final value = image?.previewUrl.trim();

    if (value == null || value.isEmpty) {
      return null;
    }

    return value;
  }
}
