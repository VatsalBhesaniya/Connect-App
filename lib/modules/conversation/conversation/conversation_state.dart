part of 'conversation_bloc.dart';

@freezed
class ConversationState with _$ConversationState {
  const factory ConversationState.initial() = _Initial;
  const factory ConversationState.loadInProgress() = _LoadInProgress;
  const factory ConversationState.fetchConversationSuccess({
    required List<ChatMessage> messages,
  }) = _FetchConversationSuccess;
  const factory ConversationState.fetchConversationFailure({
    required NetworkExceptions error,
  }) = _FetchConversationFailure;
  const factory ConversationState.updateUnreadStatusSuccess() =
      _UpdateUnreadStatusSuccess;
  const factory ConversationState.updateUnreadStatusFailure({
    required NetworkExceptions error,
  }) = _UpdateUnreadStatusFailure;
  const factory ConversationState.loading() = _Loading;
  const factory ConversationState.startConversationSuccess({
    required String conversationId,
  }) = _StartConversationSuccess;
  const factory ConversationState.startConversationFailure({
    required NetworkExceptions error,
  }) = _StartConversationFailure;
  const factory ConversationState.sendMessageSuccess() = _SendMessageSuccess;
  const factory ConversationState.sendMessageFailure({
    required NetworkExceptions error,
  }) = _SendMessageFailure;
  const factory ConversationState.sendImageSuccess({
    required String imageUrl,
    required String conversationId,
  }) = _SendImageSuccess;
  const factory ConversationState.sendImageFailure({
    required NetworkExceptions error,
  }) = _SendImageFailure;
}
