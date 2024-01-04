import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect/common/constants.dart';
import 'package:connect/models/api_handler/network_exceptions.dart';
import 'package:connect/models/chat_conversation.dart';
import 'package:connect/models/connect_user.dart';
import 'package:connect/models/last_message.dart';
import 'package:connect/modules/chat/bloc/chat_list_bloc.dart';
import 'package:connect/modules/conversation/conversation/conversation_bloc.dart';
import 'package:connect/modules/conversation/conversation_screen.dart';
import 'package:connect/modules/home/bloc/home_bloc.dart';
import 'package:connect/repository/chat_repository.dart';
import 'package:connect/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final Map<String, Map<String, dynamic>> peerUserMap =
      <String, Map<String, dynamic>>{};

  @override
  void initState() {
    super.initState();
    context.read<ChatListBloc>().add(
          ChatListEvent.fetchUser(
            email: context.read<ConnectUser>().email,
            showLoading: true,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<ChatListBloc, ChatListState>(
          listener: (BuildContext context, ChatListState state) {
            state.maybeWhen(
              loadInProgress: () => EasyLoading.show(),
              fetchUserSuccess: (ConnectUser user, bool showLoading) {
                EasyLoading.dismiss();
                context.read<ChatListBloc>().add(
                      ChatListEvent.fetchConversationList(
                        user: context.read<ConnectUser>(),
                      ),
                    );
              },
              fetchUserFailure: (NetworkExceptions error) {
                EasyLoading.dismiss();
                _showAlert(context);
              },
              fetchConversationListSuccess: (
                ConnectUser user,
                List<ChatConversation> conversations,
                List<ChatConversation>? searchConversations,
              ) {
                EasyLoading.dismiss();
              },
              fetchConversationListFailure: (NetworkExceptions error) {
                EasyLoading.dismiss();
                _showAlert(context);
              },
              orElse: () => null,
            );
          },
          buildWhen: (ChatListState previous, ChatListState current) {
            return current.maybeWhen(
              fetchConversationListSuccess: (
                ConnectUser user,
                List<ChatConversation> conversations,
                List<ChatConversation>? searchConversations,
              ) =>
                  true,
              orElse: () => false,
            );
          },
          builder: (BuildContext context, ChatListState state) {
            return state.maybeWhen(
              fetchConversationListSuccess: (
                ConnectUser user,
                List<ChatConversation> conversations,
                List<ChatConversation>? searchConversations,
              ) {
                if (conversations.isEmpty) {
                  return _buildDefaultScreen(context, user);
                }
                return Column(
                  children: <Widget>[
                    _buildSerachBox(context, user, conversations),
                    _buildList(searchConversations ?? conversations),
                  ],
                );
              },
              orElse: () {
                return const SizedBox();
              },
            );
          },
        ),
      ),
    );
  }

  Center _buildDefaultScreen(BuildContext context, ConnectUser user) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'No connects yet.',
            style: TextStyles().workSansTextStyle(
              fontSize: 16.0,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          MaterialButton(
            onPressed: () {
              context
                  .read<HomeBloc>()
                  .add(HomeEvent.tabChanged(user: user, selectedTab: 0));
            },
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 10.0,
            ),
            color: Colors.blueGrey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50.0),
            ),
            clipBehavior: Clip.antiAlias,
            elevation: 4.0,
            child: Text(
              'Explore',
              style: TextStyles().varelaRoundTextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSerachBox(
    BuildContext context,
    ConnectUser user,
    List<ChatConversation> conversations,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0, top: 16.0, left: 16.0),
      child: Container(
        height: 45.0,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  onChanged: (String value) {
                    context.read<ChatListBloc>().add(
                          ChatListEvent.searchChat(
                            user: user,
                            conversations: conversations,
                            searchText: value,
                            peerUserMap: peerUserMap,
                          ),
                        );
                  },
                  style: TextStyles().latoTextStyle(fontSize: 14.0),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Search',
                    hintStyle: TextStyles().latoTextStyle(color: Colors.grey),
                    contentPadding: const EdgeInsets.only(
                      bottom: 2,
                    ),
                    border: InputBorder.none,
                  ),
                  textAlignVertical: TextAlignVertical.center,
                ),
              ),
            ),
            IconButton(
              onPressed: _searchController.text.isEmpty
                  ? null
                  : () {
                      _searchController.clear();
                      context.read<ChatListBloc>().add(
                            ChatListEvent.searchChat(
                              user: user,
                              conversations: conversations,
                              searchText: _searchController.text,
                              peerUserMap: peerUserMap,
                            ),
                          );
                    },
              icon: Icon(
                _searchController.text.isEmpty
                    ? Icons.search_rounded
                    : Icons.cancel_rounded,
                size: 18.0,
                color: Colors.blueGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<ChatConversation> conversations) {
    return Expanded(
      child: RefreshIndicator(
        onRefresh: () async {
          return _onRefresh();
        },
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          separatorBuilder: (BuildContext context, int index) {
            return const Divider();
          },
          itemCount: conversations.length,
          itemBuilder: (BuildContext context, int index) {
            final ChatConversation conversation = conversations[index];
            final String peerId = conversation.members.firstWhere(
              (String id) => id != context.read<ConnectUser>().id,
            );
            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('chat')
                  .doc(conversation.conversationId)
                  .collection('messages')
                  .where('unreadBy',
                      arrayContains: context.read<ConnectUser>().id)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                      unreadSnapshot) {
                if (!unreadSnapshot.hasData) {
                  return const SizedBox();
                } else {
                  final List<QueryDocumentSnapshot<Map<String, dynamic>>>?
                      unreadMessagesJson = unreadSnapshot.data?.docs;
                  final int? unreadCounter = unreadMessagesJson?.length;
                  return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(peerId)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                            peerSnapshot) {
                      final Map<String, dynamic>? peerUserJson =
                          peerSnapshot.data?.data();
                      if (!peerSnapshot.hasData || peerUserJson == null) {
                        return const SizedBox();
                      }
                      final ConnectUser peerUser =
                          ConnectUser.fromJson(peerUserJson);
                      peerUserMap.putIfAbsent(peerUser.id, () => peerUserJson);
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          _onOpenConversation(
                            context,
                            conversation.conversationId,
                            peerUser,
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              _buildUserProfile(peerUser.profileUrl),
                              const SizedBox(width: 16.0),
                              Flexible(
                                child: Column(
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          peerUser.username,
                                          style:
                                              TextStyles().varelaRoundTextStyle(
                                            fontSize: 16.0,
                                            color: Colors.grey[800],
                                          ),
                                        ),
                                        const SizedBox(width: 4.0),
                                        _buildUnreadCounter(unreadCounter),
                                      ],
                                    ),
                                    const SizedBox(height: 4.0),
                                    _buildLastMessage(conversation.lastMessage),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _onRefresh() {
    context.read<ChatListBloc>().add(
          ChatListEvent.fetchUser(
            email: context.read<ConnectUser>().email,
            showLoading: false,
          ),
        );
    return Future<void>.delayed(const Duration(seconds: 1));
  }

  Future<void> _onOpenConversation(
    BuildContext context,
    String conversationId,
    ConnectUser peerUser,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext ctx) {
          return BlocProvider<ConversationBloc>(
            create: (BuildContext context) => ConversationBloc(
              chatRepository: ChatRepository(),
            )..add(
                ConversationEvent.fetchConversation(
                  conversationId: conversationId,
                ),
              ),
            child: ConversationScreen(
              currentUserId: context.read<ConnectUser>().id,
              conversationId: conversationId,
              peerId: peerUser.id,
              peerName: peerUser.username,
              peerProfileUrl: peerUser.profileUrl,
            ),
          );
        },
      ),
    );
    _onRefresh();
  }

  Row _buildLastMessage(LastMessage lastMessage) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        lastMessage.type == MessageType.text.title
            ? Expanded(
                child: Text(
                  lastMessage.content,
                  style: TextStyles().workSansTextStyle(
                    color: Colors.grey.shade500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            : Icon(
                Icons.image,
                color: Colors.grey.shade500,
              ),
        const SizedBox(
          width: 4.0,
        ),
        Text(
          _getLastMessageTime(lastMessage),
          style: TextStyles().workSansTextStyle(
            color: Colors.blueGrey,
            fontSize: 10.0,
          ),
        ),
      ],
    );
  }

  Widget _buildUnreadCounter(int? unreadCounter) {
    if (unreadCounter == null || unreadCounter == 0) {
      return const SizedBox();
    }
    return Container(
      padding: const EdgeInsets.all(5.0),
      decoration: const BoxDecoration(
        color: Colors.blueGrey,
        shape: BoxShape.circle,
      ),
      child: Text(
        unreadCounter.toString(),
        style: TextStyles().workSansTextStyle(
          fontSize: 10.0,
          color: Colors.white,
        ),
      ),
    );
  }

  String _getLastMessageTime(LastMessage lastMessage) {
    final DateTime date =
        DateTime.fromMicrosecondsSinceEpoch(lastMessage.createdAt);
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime yesterday = DateTime(now.year, now.month, now.day - 1);
    if (date.isAfter(yesterday)) {
      if (date.isAfter(today)) {
        return DateFormat.jm().format(date).toString();
      }
      return 'yesterday';
    } else {
      return DateFormat.yMd().format(date).toString();
    }
  }

  StatelessWidget _buildUserProfile(String? profileUrl) {
    final String? _profileUrl = profileUrl;
    return CircleAvatar(
      child: Material(
        child: CachedNetworkImage(
          placeholder: (BuildContext context, String url) {
            return Container(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.secondary,
                ),
              ),
              width: 200.0,
              height: 200.0,
              padding: const EdgeInsets.all(70.0),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: const BorderRadius.all(
                  Radius.circular(8.0),
                ),
              ),
            );
          },
          errorWidget: (BuildContext context, String url, dynamic error) {
            return Material(
              child: Container(
                child: const Center(
                  child: Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                width: 200.0,
                height: 200.0,
                // padding: const EdgeInsets.all(70.0),
                decoration: const BoxDecoration(
                  color: Colors.blueGrey,
                  borderRadius: BorderRadius.all(
                    Radius.circular(8.0),
                  ),
                ),
              ),
              borderRadius: const BorderRadius.all(
                Radius.circular(8.0),
              ),
              clipBehavior: Clip.hardEdge,
            );
          },
          imageUrl: _profileUrl ?? '',
          width: 200.0,
          height: 200.0,
          fit: BoxFit.cover,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(50.0)),
        clipBehavior: Clip.hardEdge,
      ),
    );
  }

  void _showAlert(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alert'),
          content: const Text('Something went wrong. Please try again.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
