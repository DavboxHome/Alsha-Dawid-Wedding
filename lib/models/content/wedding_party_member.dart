import 'package:freezed_annotation/freezed_annotation.dart';

import 'cms_image.dart';

part 'wedding_party_member.freezed.dart';
part 'wedding_party_member.g.dart';

@freezed
class WeddingPartyMember with _$WeddingPartyMember {
  const WeddingPartyMember._();

  const factory WeddingPartyMember({
    required String firstName,
    required String lastName,
    String? honorific,
    String? bio,
    CmsImage? photo,
    String? role,
    @Default(0) int sortOrder,
  }) = _WeddingPartyMember;

  factory WeddingPartyMember.fromJson(Map<String, dynamic> json) =>
      _$WeddingPartyMemberFromJson(json);

  bool get hasName => firstName.trim().isNotEmpty || lastName.trim().isNotEmpty;

  bool get hasBio => bio?.trim().isNotEmpty ?? false;

  String? get photoUrl {
    final value = photo?.previewUrl.trim();

    if (value == null || value.isEmpty) {
      return null;
    }

    return value;
  }

  String? get fullPhotoUrl {
    final value = photo?.absoluteUrl.trim();

    if (value == null || value.isEmpty) {
      return null;
    }

    return value;
  }

  String get displayName {
    final name = '$firstName $lastName'.trim();
    final trimmedHonorific = honorific?.trim();

    if (trimmedHonorific != null && trimmedHonorific.isNotEmpty) {
      return '$trimmedHonorific $name'.trim();
    }

    return name;
  }
}
