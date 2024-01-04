import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect/common/constants.dart';
import 'package:connect/models/api_handler/api_result.dart';
import 'package:connect/models/api_handler/network_exceptions.dart';
import 'package:connect/models/chat_message.dart';
import 'package:connect/repository/chat_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'conversation_state.dart';
part 'conversation_event.dart';
part 'conversation_bloc.freezed.dart';

class ConversationBloc extends Bloc<ConversationEvent, ConversationState> {
  ConversationBloc({
    required ChatRepository chatRepository,
  })  : _chatRepository = chatRepository,
        super(const ConversationState.initial()) {
    on<_FetchConversation>(_onFetchConversation);
    on<_UpdateUnreadStatus>(_onUpdateUnreadStatus);
    on<_StartConversation>(_onStartConversation);
    on<_SendMessage>(_onSendMessage);
    on<_SendImage>(_onSendImage);
  }

  final ChatRepository _chatRepository;

  Future<void> _onFetchConversation(
      _FetchConversation event, Emitter<ConversationState> emit) async {
    emit(const ConversationState.loadInProgress());
    final String? _conversationId = event.conversationId;
    if (_conversationId == null) {
      emit(
        const ConversationState.fetchConversationSuccess(
          messages: <ChatMessage>[],
        ),
      );
      return;
    }
    final ApiResult<Stream<QuerySnapshot<Map<String, dynamic>>>> apiResult =
        _chatRepository.fetchConversation(conversationId: _conversationId);
    await apiResult.when(
      success:
          (Stream<QuerySnapshot<Map<String, dynamic>>> conversation) async {
        await emit.onEach<QuerySnapshot<Map<String, dynamic>>>(
          conversation,
          onData: (QuerySnapshot<Map<String, dynamic>> snapshot) async {
            final List<ChatMessage> messages = <ChatMessage>[];
            for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
                in snapshot.docs) {
              final Map<String, dynamic> messageJson = doc.data();
              messageJson.putIfAbsent('id', () => doc.id);
              messages.add(ChatMessage.fromJson(messageJson));
            }
            emit(
                ConversationState.fetchConversationSuccess(messages: messages));
          },
        );
      },
      failure: (NetworkExceptions error) {
        emit(ConversationState.fetchConversationFailure(error: error));
      },
    );
  }

  Future<void> _onUpdateUnreadStatus(
      _UpdateUnreadStatus event, Emitter<ConversationState> emit) async {
    final ApiResult<bool> apiResult = await _chatRepository.updateUnreadStatus(
      conversationId: event.conversationId,
      messageDocId: event.messageDocId,
      unreadBy: event.unreadBy,
    );
    apiResult.when(
      success: (bool data) {
        emit(const ConversationState.updateUnreadStatusSuccess());
      },
      failure: (NetworkExceptions error) {
        emit(ConversationState.updateUnreadStatusFailure(error: error));
      },
    );
  }

  Future<void> _onStartConversation(
      _StartConversation event, Emitter<ConversationState> emit) async {
    final ApiResult<String> apiResult =
        await _chatRepository.startNewConversation(
      content: event.content,
      type: event.type,
      currentUserId: event.currentUserId,
      peerId: event.peerId,
    );
    apiResult.when(
      success: (String conversationId) {
        emit(ConversationState.startConversationSuccess(
          conversationId: conversationId,
        ));
      },
      failure: (NetworkExceptions error) {
        emit(ConversationState.startConversationFailure(error: error));
      },
    );
  }

  Future<void> _onSendMessage(
      _SendMessage event, Emitter<ConversationState> emit) async {
    final ApiResult<bool> apiResult = await _chatRepository.sendMessage(
      content: event.content,
      type: event.type,
      conversationId: event.conversationId,
      currentUserId: event.currentUserId,
      peerId: event.peerId,
    );
    apiResult.when(
      success: (bool data) {
        emit(const ConversationState.sendMessageSuccess());
      },
      failure: (NetworkExceptions error) {
        emit(ConversationState.sendMessageFailure(error: error));
      },
    );
  }

  Future<void> _onSendImage(
      _SendImage event, Emitter<ConversationState> emit) async {
    final ApiResult<String> apiResult = await _chatRepository.uploadFile(
      image: event.image,
      conversationId: event.conversationId,
    );
    apiResult.when(
      success: (String imageUrl) {
        emit(ConversationState.sendImageSuccess(
          imageUrl: imageUrl,
          conversationId: event.conversationId,
        ));
      },
      failure: (NetworkExceptions error) {
        emit(ConversationState.sendImageFailure(error: error));
      },
    );
  }
}
