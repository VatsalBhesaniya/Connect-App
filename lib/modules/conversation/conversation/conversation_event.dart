part of 'conversation_bloc.dart';

@freezed
class ConversationEvent with _$ConversationEvent {
  const factory ConversationEvent.fetchConversation({
    required String? conversationId,
  }) = _FetchConversation;
  const factory ConversationEvent.updateUnreadStatus({
    required String conversationId,
    required String messageDocId,
    required List<String> unreadBy,
  }) = _UpdateUnreadStatus;
  const factory ConversationEvent.startConversation({
    required String content,
    required MessageType type,
    required String currentUserId,
    required String peerId,
  }) = _StartConversation;
  const factory ConversationEvent.sendMessage({
    required String content,
    required MessageType type,
    required String conversationId,
    required String currentUserId,
    required String peerId,
  }) = _SendMessage;
  const factory ConversationEvent.sendImage({
    required File image,
    required String conversationId,
  }) = _SendImage;
}
