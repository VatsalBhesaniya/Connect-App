import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect/common/constants.dart';
import 'package:connect/models/api_handler/api_result.dart';
import 'package:connect/models/api_handler/network_exceptions.dart';
import 'package:connect/models/conversation.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ChatRepository {
  Future<ApiResult<Stream<QuerySnapshot<Map<String, dynamic>>>>>
      getUserConversationsStream({required String userId}) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> userSnap =
          await FirebaseFirestore.instance
              .collection('users')
              .where('id', isEqualTo: userId)
              .get();
      if (userSnap.docs.isEmpty) {
        return const ApiResult<
            Stream<QuerySnapshot<Map<String, dynamic>>>>.failure(
          error: NetworkExceptions.defaultError(error: 'No conversations yet.'),
        );
      }
      final QueryDocumentSnapshot<Map<String, dynamic>> userDocument =
          userSnap.docs.first;
      if (!userDocument.exists) {
        return const ApiResult<
            Stream<QuerySnapshot<Map<String, dynamic>>>>.failure(
          error: NetworkExceptions.defaultError(
              error: 'Something went wrong. Could not fetch the data.'),
        );
      }
      final Stream<QuerySnapshot<Map<String, dynamic>>> convSnap =
          FirebaseFirestore.instance
              .collection('users')
              .doc(userDocument.id)
              .collection('conversations')
              .snapshots();
      return ApiResult<Stream<QuerySnapshot<Map<String, dynamic>>>>.success(
          data: convSnap);
    } on FirebaseException catch (e) {
      return ApiResult<Stream<QuerySnapshot<Map<String, dynamic>>>>.failure(
        error:
            NetworkExceptions.firebaseError(message: e.message, code: e.code),
      );
    } on Exception catch (e) {
      return ApiResult<Stream<QuerySnapshot<Map<String, dynamic>>>>.failure(
        error: NetworkExceptions.exception(error: e.error),
      );
    }
  }

  Future<ApiResult<Stream<QuerySnapshot<Map<String, dynamic>>>>>
      fetchConversationList({required String userId}) async {
    try {
      final Stream<QuerySnapshot<Map<String, dynamic>>> conversations =
          FirebaseFirestore.instance
              .collection('chat')
              .where('members', arrayContains: userId)
              .snapshots();
      return ApiResult<Stream<QuerySnapshot<Map<String, dynamic>>>>.success(
        data: conversations,
      );
    } on FirebaseException catch (e) {
      return ApiResult<Stream<QuerySnapshot<Map<String, dynamic>>>>.failure(
        error:
            NetworkExceptions.firebaseError(message: e.message, code: e.code),
      );
    } on Exception catch (e) {
      return ApiResult<Stream<QuerySnapshot<Map<String, dynamic>>>>.failure(
        error: NetworkExceptions.exception(error: e.error),
      );
    }
  }

  Future<ApiResult<List<Conversation>>> fetchUserConversations(
      {required String docId}) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> convCollection =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(docId)
              .collection('conversations')
              .get();
      if (convCollection.docs.isEmpty) {
        return const ApiResult<List<Conversation>>.success(
          data: <Conversation>[],
        );
      }
      return ApiResult<List<Conversation>>.success(
          data: convCollection.docs
              .map((QueryDocumentSnapshot<Map<String, dynamic>> convDoc) =>
                  Conversation.fromJson(convDoc.data()))
              .toList());
    } on FirebaseException catch (e) {
      return ApiResult<List<Conversation>>.failure(
        error:
            NetworkExceptions.firebaseError(message: e.message, code: e.code),
      );
    } on Exception catch (e) {
      return ApiResult<List<Conversation>>.failure(
        error: NetworkExceptions.exception(error: e.error),
      );
    }
  }

  ApiResult<Stream<QuerySnapshot<Map<String, dynamic>>>> fetchConversation({
    required String conversationId,
  }) {
    try {
      final Stream<QuerySnapshot<Map<String, dynamic>>> conversation =
          FirebaseFirestore.instance
              .collection('chat')
              .doc(conversationId)
              .collection('messages')
              .orderBy('createdAt', descending: true)
              .limit(100)
              .snapshots();
      return ApiResult<Stream<QuerySnapshot<Map<String, dynamic>>>>.success(
          data: conversation);
    } on FirebaseException catch (e) {
      return ApiResult<Stream<QuerySnapshot<Map<String, dynamic>>>>.failure(
        error:
            NetworkExceptions.firebaseError(message: e.message, code: e.code),
      );
    } on Exception catch (e) {
      return ApiResult<Stream<QuerySnapshot<Map<String, dynamic>>>>.failure(
        error: NetworkExceptions.exception(error: e.error),
      );
    }
  }

  Future<ApiResult<bool>> updateUnreadStatus({
    required String conversationId,
    required String messageDocId,
    required List<String> unreadBy,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('chat')
          .doc(conversationId)
          .collection('messages')
          .doc(messageDocId)
          .update(<String, dynamic>{
        'unreadBy': unreadBy,
      });
      return const ApiResult<bool>.success(data: true);
    } on FirebaseException catch (e) {
      return ApiResult<bool>.failure(
        error:
            NetworkExceptions.firebaseError(message: e.message, code: e.code),
      );
    } on Exception catch (e) {
      return ApiResult<bool>.failure(
        error: NetworkExceptions.exception(error: e.error),
      );
    }
  }

  Future<ApiResult<String>> startNewConversation({
    required String content,
    required MessageType type,
    required String currentUserId,
    required String peerId,
  }) async {
    try {
      // add new conversation in chat collection
      final DocumentReference<Map<String, dynamic>> newConvDocRef =
          FirebaseFirestore.instance.collection('chat').doc();
      newConvDocRef.set(
        <String, dynamic>{
          'conversationId': newConvDocRef.id,
          'members': <String>[
            currentUserId,
            peerId,
          ],
          'lastMessage': <String, dynamic>{
            'content': content,
            'idFrom': currentUserId,
            'idTo': peerId,
            'type': type.title,
            'createdAt': DateTime.now().toUtc().microsecondsSinceEpoch,
          },
        },
      );

      // add message in conversation in chat collection
      final DocumentReference<Map<String, dynamic>> messageDocRef =
          FirebaseFirestore.instance
              .collection('chat')
              .doc(newConvDocRef.id)
              .collection('messages')
              .doc();
      await messageDocRef.set(<String, dynamic>{
        'id': messageDocRef.id,
        'content': content,
        'idFrom': currentUserId,
        'idTo': peerId,
        'type': type.title,
        'createdAt': DateTime.now().toUtc().microsecondsSinceEpoch,
        'unreadBy': <String>[peerId],
      });

      // add conversation members in chat collection
      final CollectionReference<Map<String, dynamic>> membersCollectionRef =
          FirebaseFirestore.instance
              .collection('chat')
              .doc(newConvDocRef.id)
              .collection('members');
      membersCollectionRef.doc(currentUserId).set(<String, dynamic>{
        'id': currentUserId,
        'isBlocked': false,
        'isBlockedAt': null,
        'hasBlocked': false,
        'hasBlockedAt': null,
        'isDeleted': false,
        'isDeletedAt': null,
        'deletedFromConversation': false,
      });
      membersCollectionRef.doc(peerId).set(<String, dynamic>{
        'id': peerId,
        'isBlocked': false,
        'isBlockedAt': null,
        'hasBlocked': false,
        'hasBlockedAt': null,
        'isDeleted': false,
        'isDeletedAt': null,
        'deletedFromConversation': false,
      });

      // add conversaion in current user in users collection
      FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .collection('conversations')
          .doc(newConvDocRef.id)
          .set(
        <String, dynamic>{
          'conversationId': newConvDocRef.id,
        },
      );
      // add conversation in peer user in users collection
      FirebaseFirestore.instance
          .collection('users')
          .doc(peerId)
          .collection('conversations')
          .doc(newConvDocRef.id)
          .set(
        <String, dynamic>{
          'conversationId': newConvDocRef.id,
        },
      );
      return ApiResult<String>.success(data: newConvDocRef.id);
    } on FirebaseException catch (e) {
      return ApiResult<String>.failure(
        error:
            NetworkExceptions.firebaseError(message: e.message, code: e.code),
      );
    } on Exception catch (e) {
      return ApiResult<String>.failure(
        error: NetworkExceptions.exception(error: e.error),
      );
    }
  }

  Future<ApiResult<bool>> sendMessage({
    required String content,
    required MessageType type,
    required String conversationId,
    required String currentUserId,
    required String peerId,
  }) async {
    try {
      // add new conversation in chat collection
      final DocumentReference<Map<String, dynamic>> convDocRef =
          FirebaseFirestore.instance.collection('chat').doc(conversationId);
      convDocRef.update(
        <String, dynamic>{
          'lastMessage': <String, dynamic>{
            'content': content,
            'idFrom': currentUserId,
            'idTo': peerId,
            'type': type.title,
            'createdAt': DateTime.now().toUtc().microsecondsSinceEpoch,
          },
        },
      );

      final DocumentReference<Map<String, dynamic>> messageDocRef =
          FirebaseFirestore.instance
              .collection('chat')
              .doc(conversationId)
              .collection('messages')
              .doc();
      await messageDocRef.set(
        <String, dynamic>{
          'id': messageDocRef.id,
          'content': content,
          'idFrom': currentUserId,
          'idTo': peerId,
          'type': type.title,
          'createdAt': DateTime.now().toUtc().microsecondsSinceEpoch,
          'unreadBy': <String>[peerId],
        },
      );
      return const ApiResult<bool>.success(data: true);
    } on FirebaseException catch (e) {
      return ApiResult<bool>.failure(
        error:
            NetworkExceptions.firebaseError(message: e.message, code: e.code),
      );
    } on Exception catch (e) {
      return ApiResult<bool>.failure(
        error: NetworkExceptions.exception(error: e.error),
      );
    }
  }

  Future<ApiResult<String>> uploadFile({
    required File image,
    required String conversationId,
  }) async {
    try {
      final Reference storageReference = FirebaseStorage.instance.ref().child(
          'images/$conversationId/${DateTime.now().toUtc().millisecondsSinceEpoch}');
      final UploadTask uploadTask = storageReference.putFile(image);
      final TaskSnapshot taskSnapshot = await uploadTask;
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return ApiResult<String>.success(data: downloadUrl);
    } on FirebaseException catch (e) {
      return ApiResult<String>.failure(
        error:
            NetworkExceptions.firebaseError(message: e.message, code: e.code),
      );
    } on Exception catch (e) {
      return ApiResult<String>.failure(
        error: NetworkExceptions.exception(error: e.error),
      );
    }
  }
}
