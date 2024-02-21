import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:connect/models/api_handler/api_result.dart';
import 'package:connect/models/api_handler/network_exceptions.dart';
import 'package:connect/models/connect_user.dart';
import 'package:connect/repository/authentication_repository.dart';
import 'package:connect/repository/user_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_state.dart';
part 'profile_event.dart';
part 'profile_bloc.freezed.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({
    required UserRepository userRepository,
    required AuthenticationRepository authenticationRepository,
  })  : _userRepository = userRepository,
        _authenticationRepository = authenticationRepository,
        super(const ProfileState.initial()) {
    on<_FetchUser>(_onFetchUser);
    on<_LogoutSubmitted>(_onLogoutSubmitted);
    on<_DeleteAccountSubmitted>(_onDeleteAccountSubmitted);
  }

  final UserRepository _userRepository;
  final AuthenticationRepository _authenticationRepository;

  Future<void> _onFetchUser(_FetchUser event, Emitter<ProfileState> emit) async {
    emit(const ProfileState.loadInProgress());
    final ApiResult<ConnectUser?> result = await _userRepository.fetchUser(
      email: event.email,
    );
    result.when(
      success: (ConnectUser? user) {
        if (user == null) {
          emit(
            const ProfileState.fetchUserFailure(
                error: NetworkExceptions.defaultError(error: 'Something went wrong.')),
          );
        } else {
          emit(ProfileState.fetchUserSuccess(user: user));
        }
      },
      failure: (NetworkExceptions error) {
        ProfileState.fetchUserFailure(error: error);
      },
    );
  }

  Future<void> _onLogoutSubmitted(_LogoutSubmitted event, Emitter<ProfileState> emit) async {
    final ApiResult<String?> result = await _authenticationRepository.logOut();

    result.when(
      success: (String? data) {
        emit(const ProfileState.logoutSuccess());
      },
      failure: (NetworkExceptions error) {
        ProfileState.logoutFailure(error: error);
      },
    );
  }

  Future<void> _onDeleteAccountSubmitted(
      _DeleteAccountSubmitted event, Emitter<ProfileState> emit) async {
    final ApiResult<String?> result = await _authenticationRepository.deleteAccount(
      user: event.user,
      password: event.password,
    );

    result.when(
      success: (String? data) {
        emit(const ProfileState.deleteAccountSuccess());
      },
      failure: (NetworkExceptions error) {
        ProfileState.deleteAccountFailure(error: error);
      },
    );
  }
}
