// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'conversation_member.freezed.dart';
part 'conversation_member.g.dart';

@freezed
class ConversationMember with _$ConversationMember {
  @JsonSerializable()
  factory ConversationMember({
    required String id,
    required bool isBlocked,
    bool? isBlockedAt,
    required bool isDeleted,
    int? isDeletedAt,
    required bool hasBlocked,
    int? hasBlockedAt,
    required bool deletedFromConversation,
  }) = _ConversationMember;

  factory ConversationMember.fromJson(Map<String, dynamic> json) =>
      _$ConversationMemberFromJson(json);
}
