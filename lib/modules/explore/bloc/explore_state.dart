part of 'explore_bloc.dart';

@freezed
class ExploreState with _$ExploreState {
  const factory ExploreState.initial() = _Initial;
  const factory ExploreState.loadInProgress() = _LoadInProgress;
  const factory ExploreState.locationPermissionStatusSuccess() =
      _LocationPermissionStatusSuccess;
  const factory ExploreState.locationPermissionStatusFailure() =
      _LocationPermissionStatusFailure;
  const factory ExploreState.getCurrentLocationSuccess({
    required LatLng location,
  }) = _GetCurrentLocationSuccess;
  const factory ExploreState.getCurrentLocationFailure() =
      _GetCurrentLocationFailure;
  const factory ExploreState.fetchUserConversationsSuccess({
    required List<Conversation> conversations,
    required String peerId,
    required String peerName,
    required String? peerProfileUrl,
  }) = _FetchUserConversationsSuccess;
  const factory ExploreState.fetchUserConversationsFailure({
    required NetworkExceptions networkException,
  }) = _FetchUserConversationsFailure;
}
