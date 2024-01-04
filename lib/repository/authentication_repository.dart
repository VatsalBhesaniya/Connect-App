import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect/models/api_handler/api_result.dart';
import 'package:connect/models/api_handler/network_exceptions.dart';
import 'package:connect/models/connect_user.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum AuthenticationStatus { unknown, authenticated, unauthenticated }

class AuthenticationRepository {
  final StreamController<AuthenticationStatus> _controller =
      StreamController<AuthenticationStatus>();

  Stream<User?> get status async* {
    yield* FirebaseAuth.instance.authStateChanges();
  }

  Future<ApiResult<String>> logIn({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential firebaseUser =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? user = firebaseUser.user;
      if (user != null && user.emailVerified) {
        _controller.add(AuthenticationStatus.authenticated);
        return const ApiResult<String>.success(data: 'Login Successful');
      } else {
        await logOut();
        return const ApiResult<String>.failure(
          error: NetworkExceptions.firebaseError(
            message: 'Email is not verified',
            code: '',
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      return ApiResult<String>.failure(
        error: NetworkExceptions.firebaseError(code: e.code),
      );
    } on Exception catch (e) {
      return ApiResult<String>.failure(
        error: NetworkExceptions.exception(error: e.error),
      );
    }
  }

  Future<ApiResult<String?>> logOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      _controller.add(AuthenticationStatus.unauthenticated);
      return const ApiResult<String?>.success(data: null);
    } on FirebaseAuthException catch (e) {
      return ApiResult<String?>.failure(
        error: NetworkExceptions.firebaseError(code: e.code),
      );
    } on Exception catch (e) {
      return ApiResult<String?>.failure(
        error: NetworkExceptions.exception(error: e.error),
      );
    }
  }

  Future<ApiResult<String>> signUp({required ConnectUser user}) async {
    try {
      final UserCredential firebaseUser =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: user.email,
        password: user.password!,
      );
      await addUser(user: user);
      await firebaseUser.user?.sendEmailVerification();
      await logOut();
      return const ApiResult<String>.success(data: 'Signup Successful');
    } on FirebaseAuthException catch (e) {
      return ApiResult<String>.failure(
        error: NetworkExceptions.firebaseError(code: e.code),
      );
    } on Exception catch (e) {
      return ApiResult<String>.failure(
        error: NetworkExceptions.exception(error: e.error),
      );
    }
  }

  Future<ApiResult<String>> sendVerificationEmail() async {
    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      return const ApiResult<String>.success(
          data: 'Send email verification successful');
    } on FirebaseAuthException catch (e) {
      return ApiResult<String>.failure(
        error: NetworkExceptions.firebaseError(code: e.code),
      );
    } on Exception catch (e) {
      return ApiResult<String>.failure(
        error: NetworkExceptions.exception(error: e.error),
      );
    }
  }

  Future<ApiResult<String?>> sendResetPasswordEmail(String email) async {
    try {
      final List<String> signInMethods =
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      if (signInMethods.isNotEmpty) {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
        return const ApiResult<String?>.success(data: null);
      } else {
        return const ApiResult<String>.failure(
          error: NetworkExceptions.firebaseError(
            message: 'No user found with this email.',
            code: '',
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      return ApiResult<String>.failure(
        error: NetworkExceptions.firebaseError(code: e.code),
      );
    } on Exception catch (e) {
      return ApiResult<String>.failure(
        error: NetworkExceptions.exception(error: e.error),
      );
    }
  }

  Future<void> addUser({required ConnectUser user}) async {
    final DocumentReference<Map<String, dynamic>> doc =
        FirebaseFirestore.instance.collection('users').doc();
    await doc.set(user.copyWith(id: doc.id).toJson());
  }

  void dispose() => _controller.close();
}
