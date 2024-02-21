part of 'profile_bloc.dart';

@freezed
class ProfileEvent with _$ProfileEvent {
  const factory ProfileEvent.fetchUser({
    required String email,
  }) = _FetchUser;
  const factory ProfileEvent.logoutSubmitted() = _LogoutSubmitted;
  const factory ProfileEvent.deleteAccountSubmitted({
    required ConnectUser user,
    required String password,
  }) = _DeleteAccountSubmitted;
}
