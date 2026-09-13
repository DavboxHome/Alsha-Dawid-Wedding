typedef JsonFactory<T> = T Function(Map<String, dynamic> json);

T _parseData<T>(Object? raw, JsonFactory<T> fromJson) {
  if (raw is! Map<String, dynamic>) {
    throw StateError('Strapi response data was not an object.');
  }

  return fromJson(raw);
}

class StrapiSingleResponse<T> {
  const StrapiSingleResponse({required this.data});

  final T data;

  factory StrapiSingleResponse.fromJson(
    Map<String, dynamic> json,
    JsonFactory<T> fromJson,
  ) {
    return StrapiSingleResponse<T>(
      data: _parseData(json['data'], fromJson),
    );
  }
}

class StrapiCollectionResponse<T> {
  const StrapiCollectionResponse({required this.data});

  final List<T> data;

  factory StrapiCollectionResponse.fromJson(
    Map<String, dynamic> json,
    JsonFactory<T> fromJson,
  ) {
    final raw = json['data'];

    if (raw is! List) {
      throw StateError('Strapi collection response data was not a list.');
    }

    return StrapiCollectionResponse<T>(
      data: raw.map((item) {
        if (item is! Map<String, dynamic>) {
          throw StateError('Strapi collection item was not an object.');
        }

        return fromJson(item);
      }).toList(growable: false),
    );
  }
}
