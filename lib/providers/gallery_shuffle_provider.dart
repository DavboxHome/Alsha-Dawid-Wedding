import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'gallery_shuffle_provider.g.dart';

@Riverpod(keepAlive: true)
class GalleryShuffle extends _$GalleryShuffle {
  @override
  bool build() => true;

  void setEnabled(bool enabled) {
    state = enabled;
  }
}
