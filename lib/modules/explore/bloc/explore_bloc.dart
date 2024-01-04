import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:connect/models/api_handler/api_result.dart';
import 'package:connect/models/api_handler/network_exceptions.dart';
import 'package:connect/models/conversation.dart';
import 'package:connect/repository/chat_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

part 'explore_bloc.freezed.dart';
part 'explore_event.dart';
part 'explore_state.dart';

class ExploreBloc extends Bloc<ExploreEvent, ExploreState> {
  ExploreBloc({
    required ChatRepository chatRepository,
  })  : _chatRepository = chatRepository,
        super(const ExploreState.initial()) {
    on<_GetLocationPermissionStatus>(_onGetLocationPermissionStatus);
    on<_GetCurrentLocation>(_onGetCurrentLocation);
    on<_FetchUserConversations>(_onFetchUserConversations);
  }

  final ChatRepository _chatRepository;

  Future<void> _onGetLocationPermissionStatus(
      _GetLocationPermissionStatus event, Emitter<ExploreState> emit) async {
    emit(const ExploreState.loadInProgress());
    final bool status = await ph.Permission.location.isGranted;
    if (status) {
      emit(const ExploreState.locationPermissionStatusSuccess());
    } else {
      emit(const ExploreState.locationPermissionStatusFailure());
    }
  }

  Future<void> _onGetCurrentLocation(
      _GetCurrentLocation event, Emitter<ExploreState> emit) async {
    try {
      emit(const ExploreState.loadInProgress());
      final Position locationData = await Geolocator.getCurrentPosition();
      final double latitude = locationData.latitude;
      final double longitude = locationData.longitude;
      final LatLng location = LatLng(latitude, longitude);
      emit(ExploreState.getCurrentLocationSuccess(location: location));
    } on Exception catch (_) {
      emit(const ExploreState.getCurrentLocationFailure());
    }
  }

  Future<void> _onFetchUserConversations(
      _FetchUserConversations event, Emitter<ExploreState> emit) async {
    emit(const ExploreState.loadInProgress());
    final ApiResult<List<Conversation>> apiResult =
        await _chatRepository.fetchUserConversations(docId: event.docId);
    apiResult.when(
      success: (List<Conversation> conversations) {
        emit(
          ExploreState.fetchUserConversationsSuccess(
            conversations: conversations,
            peerId: event.peerId,
            peerName: event.peerName,
            peerProfileUrl: event.peerProfileUrl,
          ),
        );
      },
      failure: (NetworkExceptions exception) {
        emit(
          ExploreState.fetchUserConversationsFailure(
            networkException: exception,
          ),
        );
      },
    );
  }
}
