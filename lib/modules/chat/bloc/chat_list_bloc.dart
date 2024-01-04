import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect/models/api_handler/api_result.dart';
import 'package:connect/models/api_handler/network_exceptions.dart';
import 'package:connect/models/chat_conversation.dart';
import 'package:connect/models/connect_user.dart';
import 'package:connect/repository/chat_repository.dart';
import 'package:connect/repository/user_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_list_state.dart';
part 'chat_list_event.dart';
part 'chat_list_bloc.freezed.dart';

class ChatListBloc extends Bloc<ChatListEvent, ChatListState> {
  ChatListBloc({
    required String userId,
    required UserRepository userRepository,
    required ChatRepository chatRepository,
  })  : _userId = userId,
        _userRepository = userRepository,
        _chatRepository = chatRepository,
        super(const ChatListState.initial()) {
    on<_FetchUser>(_onFetchUser);
    on<_SearchChat>(_onSearchChat);
    on<_FetchConversationList>(_onFetchConversationList);
  }

  final String _userId;
  final UserRepository _userRepository;
  final ChatRepository _chatRepository;

  Future<void> _onFetchConversationList(
      _FetchConversationList event, Emitter<ChatListState> emit) async {
    emit(const ChatListState.loadInProgress());
    final ApiResult<Stream<QuerySnapshot<Map<String, dynamic>>>> result =
        await _chatRepository.fetchConversationList(
      userId: event.user.id,
    );
    await result.when(
      success:
          (Stream<QuerySnapshot<Map<String, dynamic>>> conversations) async {
        await emit.onEach<QuerySnapshot<Map<String, dynamic>>>(
          conversations,
          onData: (QuerySnapshot<Map<String, dynamic>> snapshot) async {
            final List<ChatConversation> conversationList =
                <ChatConversation>[];
            if (snapshot.docs.isEmpty) {
              emit(
                ChatListState.fetchConversationListSuccess(
                  user: event.user,
                  conversations: conversationList,
                ),
              );
              return;
            }
            for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
                in snapshot.docs) {
              final ChatConversation conversation =
                  ChatConversation.fromJson(doc.data());
              final QuerySnapshot<Map<String, dynamic>> unreadMessages =
                  await FirebaseFirestore.instance
                      .collection('chat')
                      .doc(conversation.conversationId)
                      .collection('messages')
                      .where('unreadBy', arrayContains: _userId)
                      .get();

              conversationList.add(conversation.copyWith(
                  unreadCounter: unreadMessages.docs.length));
            }
            conversationList.sort((ChatConversation a, ChatConversation b) =>
                b.lastMessage.createdAt.compareTo(a.lastMessage.createdAt));
            emit(
              ChatListState.fetchConversationListSuccess(
                user: event.user,
                conversations: conversationList,
              ),
            );
          },
        );
      },
      failure: (NetworkExceptions error) {
        emit(ChatListState.fetchConversationListFailure(error: error));
      },
    );
  }

  Future<void> _onFetchUser(
      _FetchUser event, Emitter<ChatListState> emit) async {
    if (event.showLoading) {
      emit(const ChatListState.loadInProgress());
    }
    final ApiResult<ConnectUser?> result = await _userRepository.fetchUser(
      email: event.email,
    );
    result.when(
      success: (ConnectUser? user) {
        if (user == null) {
          emit(
            const ChatListState.fetchUserFailure(
                error: NetworkExceptions.defaultError(
                    error: 'Something went wrong.')),
          );
        } else {
          emit(
            ChatListState.fetchUserSuccess(
              user: user,
              showLoading: event.showLoading,
            ),
          );
        }
      },
      failure: (NetworkExceptions error) {
        emit(ChatListState.fetchUserFailure(error: error));
      },
    );
  }

  Future<void> _onSearchChat(
      _SearchChat event, Emitter<ChatListState> emit) async {
    if (event.searchText.isEmpty) {
      emit(
        ChatListState.fetchConversationListSuccess(
          user: event.user,
          conversations: event.conversations,
        ),
      );
      return;
    }
    final List<ChatConversation> searchConversations = <ChatConversation>[];
    for (final Map<String, dynamic> peerUserJson
        in event.peerUserMap.values.toList() as List<Map<String, dynamic>>) {
      final ConnectUser peerUser = ConnectUser.fromJson(peerUserJson);
      if (peerUser.username
          .toLowerCase()
          .contains(event.searchText.toLowerCase())) {
        searchConversations.addAll(event.conversations.where(
            (ChatConversation conversation) =>
                conversation.members.contains(peerUser.id)));
      }
    }
    emit(const ChatListState.dummy());
    emit(
      ChatListState.fetchConversationListSuccess(
        user: event.user,
        conversations: event.conversations,
        searchConversations: searchConversations,
      ),
    );
  }
}
