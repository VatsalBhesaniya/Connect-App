// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message.freezed.dart';
part 'chat_message.g.dart';

@freezed
class ChatMessage with _$ChatMessage {
  @JsonSerializable()
  factory ChatMessage({
    required String id,
    required String content,
    required String idFrom,
    required String idTo,
    required String type,
    required int createdAt,
    required List<String> unreadBy,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);
}
