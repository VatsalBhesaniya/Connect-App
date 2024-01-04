part of 'home_bloc.dart';

@freezed
class HomeEvent with _$HomeEvent {
  const factory HomeEvent.tabChanged({
    required ConnectUser user,
    required int selectedTab,
  }) = _TabChanged;
  const factory HomeEvent.fetchUser({
    required String email,
  }) = _FetchUser;
}
