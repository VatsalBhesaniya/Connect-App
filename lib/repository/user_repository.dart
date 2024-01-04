import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect/models/api_handler/api_result.dart';
import 'package:connect/models/api_handler/network_exceptions.dart';
import 'package:connect/models/connect_user.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UserRepository {
  Future<void> addUser({required ConnectUser user}) async {
    final DocumentReference<Map<String, dynamic>> doc =
        FirebaseFirestore.instance.collection('users').doc();
    await doc.set(user.copyWith(id: doc.id).toJson());
  }

  Future<ApiResult<ConnectUser?>> fetchUser({required String email}) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> userSnap =
          await FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: email)
              .get();
      if (userSnap.docs.isNotEmpty) {
        final QueryDocumentSnapshot<Map<String, dynamic>> userDocument =
            userSnap.docs.first;
        if (userDocument.exists) {
          final CollectionReference<Map<String, dynamic>> convRef =
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(userDocument.id)
                  .collection('conversations');
          final Map<String, dynamic> userData = userDocument.data();
          final QuerySnapshot<Map<String, dynamic>> convColl =
              await convRef.get();

          final List<Map<String, dynamic>> conversations =
              <Map<String, dynamic>>[];
          for (final QueryDocumentSnapshot<Map<String, dynamic>> conv
              in convColl.docs) {
            final DocumentSnapshot<Map<String, dynamic>> convDoc =
                await convRef.doc(conv.id).get();
            final Map<String, dynamic>? data = convDoc.data();
            if (data != null) {
              conversations.add(data);
            }
          }
          userData['conversations'] = conversations;
          return ApiResult<ConnectUser?>.success(
              data: ConnectUser.fromJson(userData));
        }
      }
      return const ApiResult<ConnectUser?>.success(data: null);
    } on FirebaseException catch (e) {
      return ApiResult<ConnectUser?>.failure(
        error:
            NetworkExceptions.firebaseError(message: e.message, code: e.code),
      );
    } on Exception catch (e) {
      return ApiResult<ConnectUser?>.failure(
        error: NetworkExceptions.exception(error: e.error),
      );
    }
  }

  Future<ApiResult<void>> updateUser({required ConnectUser user}) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.id)
          .update(user.toJson()..remove('conversations'));
      return const ApiResult<void>.success(data: null);
    } on FirebaseException catch (e) {
      return ApiResult<ConnectUser?>.failure(
        error:
            NetworkExceptions.firebaseError(message: e.message, code: e.code),
      );
    } on Exception catch (e) {
      return ApiResult<ConnectUser?>.failure(
        error: NetworkExceptions.exception(error: e.error),
      );
    }
  }

  Future<ApiResult<String>> updateUserProfile({
    required String userId,
    required File image,
  }) async {
    try {
      final Reference storageReference =
          FirebaseStorage.instance.ref().child('profile_images/$userId');
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
