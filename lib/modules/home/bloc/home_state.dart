part of 'home_bloc.dart';

@freezed
class HomeState with _$HomeState {
  const factory HomeState.initial() = _Initial;
  const factory HomeState.loadInProgress() = _LoadInProgress;
  const factory HomeState.fetchUserSuccess({
    required ConnectUser user,
    required int selectedTab,
  }) = _FetchUserSuccess;
  const factory HomeState.fetchUserFailure({
    required NetworkExceptions error,
  }) = _fetchUserFailure;
}
