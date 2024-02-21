// ignore_for_file: invalid_annotation_target

import 'package:connect/models/conversation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'connect_user.freezed.dart';
part 'connect_user.g.dart';

@freezed
class ConnectUser with _$ConnectUser {
  @JsonSerializable()
  factory ConnectUser({
    required String id,
    String? profileUrl,
    required String username,
    required String firstName,
    required String lastName,
    required String gender,
    required String birthDate,
    required String email,
    @JsonKey(includeFromJson: false, includeToJson: false) String? password,
    required int createdAt,
    List<Conversation>? conversations,
  }) = _ConnectUser;

  factory ConnectUser.fromJson(Map<String, dynamic> json) =>
      _$ConnectUserFromJson(json);
}
