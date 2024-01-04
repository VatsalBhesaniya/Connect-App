import 'package:connect/models/chat_message.dart';
import 'package:connect/models/connect_user.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'conversation_item.freezed.dart';

@freezed
class ConversationItem with _$ConversationItem {
  factory ConversationItem({
    required String conversationId,
    ConnectUser? peerUser,
    ChatMessage? lastMessage,
    int? unreadCounter,
  }) = _ConversationItem;
}
