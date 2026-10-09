
enum FoodCulture {
  polish,
  goan,
  drinks;

  String get displayName => switch (this) {
        FoodCulture.polish => 'POLISH',
        FoodCulture.goan => 'GOAN',
        FoodCulture.drinks => 'DRINKS',
      };
}
