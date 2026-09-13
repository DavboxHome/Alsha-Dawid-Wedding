extension ListExtension<T> on List<T> {
  List<T> get shuffled => List<T>.of(this)..shuffle();
}
