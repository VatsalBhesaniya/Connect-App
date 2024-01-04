import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:connect/repository/authentication_repository.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'authentication_state.dart';
part 'authentication_event.dart';
part 'authentication_bloc.freezed.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc({
    required AuthenticationRepository authenticationRepository,
  })  : _authenticationRepository = authenticationRepository,
        super(AuthenticationState.initial()) {
    on<_AuthenticationStatusChanged>(_onAuthenticationStatusChanged);
    on<_AuthenticationLogoutRequested>(_onAuthenticationLogoutRequested);
    _authenticationStatusSubscription = _authenticationRepository.status.listen(
      (auth.User? user) => add(_AuthenticationStatusChanged(user: user)),
    );
  }

  final AuthenticationRepository _authenticationRepository;
  late StreamSubscription<auth.User?> _authenticationStatusSubscription;

  @override
  Future<void> close() {
    _authenticationStatusSubscription.cancel();
    _authenticationRepository.dispose();
    return super.close();
  }

  Future<void> _onAuthenticationStatusChanged(
    _AuthenticationStatusChanged event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(state.copyWith(status: AuthenticationStatus.unknown));
    final auth.User? user = event.user;
    if (user != null && user.emailVerified) {
      emit(state.copyWith(
        status: AuthenticationStatus.authenticated,
        user: event.user,
      ));
    } else {
      emit(state.copyWith(status: AuthenticationStatus.unauthenticated));
    }
  }

  void _onAuthenticationLogoutRequested(
    _AuthenticationLogoutRequested event,
    Emitter<AuthenticationState> emit,
  ) {
    _authenticationRepository.logOut();
  }
}
