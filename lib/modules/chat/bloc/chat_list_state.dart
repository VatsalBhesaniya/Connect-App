part of 'chat_list_bloc.dart';

@freezed
class ChatListState with _$ChatListState {
  const factory ChatListState.initial() = _Initial;
  const factory ChatListState.loadInProgress() = _LoadInProgress;
  const factory ChatListState.dummy() = _dummy;
  const factory ChatListState.fetchUserSuccess({
    required ConnectUser user,
    required bool showLoading,
  }) = _FetchUserSuccess;
  const factory ChatListState.fetchUserFailure({
    required NetworkExceptions error,
  }) = _fetchUserFailure;
  const factory ChatListState.fetchConversationListSuccess({
    required ConnectUser user,
    required List<ChatConversation> conversations,
    List<ChatConversation>? searchConversations,
  }) = _FetchConversationListSuccess;
  const factory ChatListState.fetchConversationListFailure({
    required NetworkExceptions error,
  }) = _FetchConversationListFailure;
}
