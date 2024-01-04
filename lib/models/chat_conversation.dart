import 'package:connect/models/last_message.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_conversation.freezed.dart';
part 'chat_conversation.g.dart';

@freezed
class ChatConversation with _$ChatConversation {
  factory ChatConversation({
    required String conversationId,
    required List<String> members,
    required LastMessage lastMessage,
    int? unreadCounter,
  }) = _ChatConversation;

  factory ChatConversation.fromJson(Map<String, dynamic> json) =>
      _$ChatConversationFromJson(json);
}
