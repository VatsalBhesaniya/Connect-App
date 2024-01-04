part of 'chat_list_bloc.dart';

@freezed
class ChatListEvent with _$ChatListEvent {
  const factory ChatListEvent.fetchUser({
    required String email,
    required bool showLoading,
  }) = _FetchUser;
  const factory ChatListEvent.fetchConversationList({
    required ConnectUser user,
  }) = _FetchConversationList;
  const factory ChatListEvent.searchChat({
    required ConnectUser user,
    required List<ChatConversation> conversations,
    required String searchText,
    required Map<String, dynamic> peerUserMap,
  }) = _SearchChat;
}
