part of 'explore_bloc.dart';

@freezed
class ExploreEvent with _$ExploreEvent {
  const factory ExploreEvent.getLocationPermissionStatus() =
      _GetLocationPermissionStatus;
  const factory ExploreEvent.getCurrentLocation() = _GetCurrentLocation;
  const factory ExploreEvent.fetchUserConversations({
    required String docId,
    required String peerId,
    required String peerName,
    required String? peerProfileUrl,
  }) = _FetchUserConversations;
}
