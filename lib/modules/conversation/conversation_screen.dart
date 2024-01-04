import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connect/common/constants.dart';
import 'package:connect/models/api_handler/network_exceptions.dart';
import 'package:connect/models/chat_message.dart';
import 'package:connect/modules/conversation/conversation/conversation_bloc.dart';
import 'package:connect/utils/text_styles.dart';
import 'package:connect/widgets/image_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ConversationScreen extends StatefulWidget {
  const ConversationScreen({
    Key? key,
    required this.currentUserId,
    this.conversationId,
    required this.peerId,
    required this.peerName,
    this.peerProfileUrl,
  }) : super(key: key);

  final String currentUserId;
  final String? conversationId;
  final String peerId;
  final String peerName;
  final String? peerProfileUrl;

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();
  String? _conversationId;

  @override
  void initState() {
    _conversationId = widget.conversationId;
    listScrollController.addListener(_scrollListener);
    super.initState();
  }

  void _scrollListener() {
    if (listScrollController.offset >=
            listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
        titleSpacing: 0.0,
        title: Row(
          children: <Widget>[
            _buildUserProfile(),
            const SizedBox(width: 8.0),
            Text(
              widget.peerName,
              style: TextStyles().latoTextStyle(color: Colors.black),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: BlocConsumer<ConversationBloc, ConversationState>(
          listener: (BuildContext context, ConversationState state) {
            state.maybeWhen(
              loadInProgress: EasyLoading.show,
              fetchConversationSuccess: (List<ChatMessage> messages) {
                EasyLoading.dismiss();
              },
              fetchConversationFailure: (NetworkExceptions error) {
                EasyLoading.dismiss();
                _showAlert(context);
              },
              startConversationSuccess: (String conversationId) {
                _messageController.clear();
                setState(() {
                  _conversationId = conversationId;
                });
                context
                    .read<ConversationBloc>()
                    .add(ConversationEvent.fetchConversation(
                      conversationId: _conversationId,
                    ));
                if (listScrollController.hasClients) {
                  listScrollController.animateTo(0.0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut);
                }
              },
              startConversationFailure: (NetworkExceptions error) {
                _showAlert(context);
              },
              sendMessageSuccess: () {
                _messageController.clear();
                if (listScrollController.hasClients) {
                  listScrollController.animateTo(0.0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut);
                }
              },
              sendMessageFailure: (NetworkExceptions error) {
                _showAlert(context);
              },
              sendImageSuccess: (String downloadUrl, String conversationId) {
                context.read<ConversationBloc>().add(
                      ConversationEvent.sendMessage(
                        content: downloadUrl,
                        type: MessageType.image,
                        conversationId: conversationId,
                        currentUserId: widget.currentUserId,
                        peerId: widget.peerId,
                      ),
                    );
              },
              sendImageFailure: (NetworkExceptions error) {
                _showAlert(context);
              },
              orElse: () => null,
            );
          },
          buildWhen: (ConversationState previous, ConversationState current) {
            return current.maybeWhen(
              fetchConversationSuccess: (List<ChatMessage> messages) => true,
              orElse: () => false,
            );
          },
          builder: (BuildContext context, ConversationState state) {
            return state.maybeWhen(
              fetchConversationSuccess: (List<ChatMessage> messages) {
                return Column(
                  children: <Widget>[
                    buildListMessage(messages),
                    buildInput(),
                    const SizedBox(height: 16.0),
                  ],
                );
              },
              orElse: () => const SizedBox(),
            );
          },
        ),
      ),
    );
  }

  StatelessWidget _buildUserProfile() {
    final String? _peerProfileUrl = widget.peerProfileUrl;
    if (_peerProfileUrl == null) {
      return const Icon(
        Icons.account_circle,
        color: Colors.blueGrey,
        size: 48,
      );
    } else {
      return CircleAvatar(
        child: Material(
          child: CachedNetworkImage(
            placeholder: (BuildContext context, String url) => Container(
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
            ),
            errorWidget: (BuildContext context, String url, dynamic error) =>
                const Material(
              child: Icon(Icons.account_circle),
              borderRadius: BorderRadius.all(
                Radius.circular(8.0),
              ),
              clipBehavior: Clip.hardEdge,
            ),
            imageUrl: _peerProfileUrl,
            width: 200.0,
            height: 200.0,
            fit: BoxFit.cover,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(50.0)),
          clipBehavior: Clip.hardEdge,
        ),
      );
    }
  }

  Widget buildListMessage(List<ChatMessage> messages) {
    return Flexible(
      child: ListView.builder(
        padding: const EdgeInsets.all(10.0),
        itemCount: messages.length,
        itemBuilder: (BuildContext context, int index) {
          String? firstDateTime;
          String? dateTime;
          if (index > 0) {
            final DateTime currentDate =
                DateTime.fromMicrosecondsSinceEpoch(messages[index].createdAt);
            if (index == messages.length - 1) {
              firstDateTime = DateFormat.yMd().format(currentDate).toString();
            }
            final DateTime previousDate = DateTime.fromMicrosecondsSinceEpoch(
                messages[index - 1].createdAt);
            if (currentDate.day != previousDate.day) {
              final DateTime now = DateTime.now();
              final DateTime today = DateTime(now.year, now.month, now.day);
              final DateTime yesterday =
                  DateTime(now.year, now.month, now.day - 1);
              if (previousDate.isAfter(yesterday)) {
                if (previousDate.isAfter(today)) {
                  dateTime = 'Today';
                } else {
                  dateTime = 'Yesterday';
                }
              } else {
                dateTime = DateFormat.yMd().format(previousDate).toString();
              }
            }
          }
          if (dateTime == null && firstDateTime == null) {
            return buildItem(index, messages[index]);
          }
          return Column(
            children: <Widget>[
              if (firstDateTime != null) _buildDateSeparator(firstDateTime),
              buildItem(index, messages[index]),
              if (dateTime != null) _buildDateSeparator(dateTime),
            ],
          );
        },
        reverse: true,
        controller: listScrollController,
      ),
    );
  }

  Padding _buildDateSeparator(String dateTime) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: <Widget>[
          const Expanded(
            child: Divider(),
          ),
          const SizedBox(width: 8),
          Text(
            dateTime,
            style: TextStyles().workSansTextStyle(
              color: Colors.blueGrey,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Divider(),
          ),
        ],
      ),
    );
  }

  Widget buildItem(int index, ChatMessage message) {
    if (message.idFrom == widget.currentUserId) {
      return userMessages(message);
    } else {
      if ((message.unreadBy).contains(widget.currentUserId)) {
        final List<String> unreadBy = <String>[...message.unreadBy];
        unreadBy.remove(widget.currentUserId);
        context
            .read<ConversationBloc>()
            .add(ConversationEvent.updateUnreadStatus(
              conversationId: _conversationId!,
              messageDocId: message.id,
              unreadBy: unreadBy,
            ));
      }
      return peerMessages(message);
    }
  }

  Widget userMessages(ChatMessage message) {
    if (message.type == MessageType.text.title) {
      return Align(
        alignment: Alignment.centerRight,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Flexible(
                        child: Text(
                          message.content,
                          style: TextStyles()
                              .varelaRoundTextStyle(color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4.0),
                  messageDateTime(message),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      return Container(
        margin: EdgeInsets.only(
          left: MediaQuery.of(context).size.width * 0.3,
          right: 8.0,
          bottom: 8.0,
        ),
        height: 200.0,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: const BorderRadius.all(
            Radius.circular(8.0),
          ),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(
            Radius.circular(8.0),
          ),
          child: CachedNetworkImage(
            placeholder: (BuildContext context, String url) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.secondary,
                  ),
                ),
              );
            },
            errorWidget: (BuildContext context, String url, dynamic error) {
              return const Icon(Icons.error);
            },
            imageUrl: message.content,
            fit: BoxFit.cover,
          ),
        ),
      );
    }
  }

  Widget messageDateTime(ChatMessage message) {
    return Text(
      DateFormat.jm().format(
        DateTime.fromMicrosecondsSinceEpoch(
          message.createdAt,
        ),
      ),
      style: const TextStyle(
        color: Colors.grey,
        fontSize: 12.0,
      ),
    );
  }

  Widget peerMessages(ChatMessage message) {
    if (message.type == MessageType.text.title) {
      return Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.lightBlue.shade50,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.lightBlue.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Flexible(
                        child: Text(
                          message.content,
                          style: TextStyles()
                              .workSansTextStyle(color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4.0),
                  messageDateTime(message),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      return Container(
        margin: EdgeInsets.only(
          left: 8.0,
          right: MediaQuery.of(context).size.width * 0.3,
          bottom: 8.0,
        ),
        height: 200.0,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: const BorderRadius.all(
            Radius.circular(8.0),
          ),
          border: Border.all(color: Colors.lightBlue.shade200),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(
            Radius.circular(8.0),
          ),
          child: CachedNetworkImage(
            placeholder: (BuildContext context, String url) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.secondary,
                  ),
                ),
              );
            },
            errorWidget: (BuildContext context, String url, dynamic error) {
              return const Icon(Icons.error);
            },
            imageUrl: message.content,
            fit: BoxFit.cover,
          ),
        ),
      );
    }
  }

  Widget buildInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Container(
              height: 45.0,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(50),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    controller: _messageController,
                    style: TextStyles().latoTextStyle(fontSize: 14.0),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Type a message',
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
            ),
          ),
          _buildSendImageIcon(),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: () async {
              if (_messageController.text.trim().isNotEmpty) {
                final String? convId = _conversationId;
                if (convId == null) {
                  context.read<ConversationBloc>().add(
                        ConversationEvent.startConversation(
                          content: _messageController.text,
                          type: MessageType.text,
                          currentUserId: widget.currentUserId,
                          peerId: widget.peerId,
                        ),
                      );
                } else {
                  context.read<ConversationBloc>().add(
                        ConversationEvent.sendMessage(
                          content: _messageController.text,
                          type: MessageType.text,
                          conversationId: convId,
                          currentUserId: widget.currentUserId,
                          peerId: widget.peerId,
                        ),
                      );
                }
              }
            },
            icon: const Icon(
              Icons.send_rounded,
              color: Colors.blueGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSendImageIcon() {
    final String? _convId = _conversationId;
    if (_convId == null) {
      return const SizedBox();
    }
    return IconButton(
      visualDensity: VisualDensity.compact,
      onPressed: () async {
        FocusScope.of(context).unfocus();
        await _showBottomSheet(_convId);
      },
      icon: Icon(
        Icons.image_rounded,
        size: 20.0,
        color: Colors.grey[600],
      ),
    );
  }

  Future<void> _showBottomSheet(String convId) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: 90.0,
          padding: const EdgeInsets.all(8.0),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildBottomSheetItem(Icons.camera_alt, 'Camera', convId),
              _buildBottomSheetItem(Icons.image, 'Gallary', convId),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomSheetItem(IconData icon, String option, String convId) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () async {
          Navigator.pop(context);
          if (option == 'Camera') {
            getImage(ImageSource.camera, convId);
          }
          if (option == 'Gallary') {
            getImage(ImageSource.gallery, convId);
          }
        },
        child: Column(
          children: <Widget>[
            Icon(
              icon,
              color: Colors.blue,
              size: 28.0,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                option,
                style: const TextStyle(fontSize: 16.0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getImage(ImageSource imageSource, String convId) async {
    ImagePicker().pickImage(source: imageSource).then((XFile? image) async {
      if (image != null) {
        final File imageFile = File(image.path);
        final bool? result = await Navigator.push(
          context,
          MaterialPageRoute<bool>(
            builder: (BuildContext context) => ImagePreview(
              imageFile: imageFile,
            ),
          ),
        );
        if (result != null && result) {
          context.read<ConversationBloc>().add(
                ConversationEvent.sendImage(
                  image: imageFile,
                  conversationId: convId,
                ),
              );
        }
      }
    });
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
