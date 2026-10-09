
import 'package:freezed_annotation/freezed_annotation.dart';

import 'food_culture.dart';
import 'wedding_food_item.dart';

part 'wedding_food_list.freezed.dart';
part 'wedding_food_list.g.dart';

@freezed
class WeddingFoodList with _$WeddingFoodList {
  const WeddingFoodList._();

  const factory WeddingFoodList({
    required String culture,
    required List<WeddingFoodItem> items,
  }) = _WeddingFoodList;

  factory WeddingFoodList.fromJson(Map<String, dynamic> json) =>
      _$WeddingFoodListFromJson(json);

  FoodCulture? get parsedCulture => switch (culture.trim().toLowerCase()) {
        'polish' => FoodCulture.polish,
        'goan' => FoodCulture.goan,
        'drinks' => FoodCulture.drinks,
        _ => null,
      };
}
