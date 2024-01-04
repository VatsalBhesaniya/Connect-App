part of 'profile_bloc.dart';

@freezed
class ProfileState with _$ProfileState {
  const factory ProfileState.initial() = _Initial;
  const factory ProfileState.loadInProgress() = _LoadInProgress;
  const factory ProfileState.fetchUserSuccess({
    required ConnectUser user,
  }) = _FetchUserSuccess;
  const factory ProfileState.fetchUserFailure({
    required NetworkExceptions error,
  }) = _fetchUserFailure;
  const factory ProfileState.logoutSuccess() = _LogoutSuccess;
  const factory ProfileState.logoutFailure({
    required NetworkExceptions error,
  }) = _LogoutFailure;
}
