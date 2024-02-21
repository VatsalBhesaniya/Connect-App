import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect/models/api_handler/network_exceptions.dart';
import 'package:connect/models/connect_user.dart';
import 'package:connect/models/conversation.dart';
import 'package:connect/modules/conversation/conversation/conversation_bloc.dart';
import 'package:connect/modules/conversation/conversation_screen.dart';
import 'package:connect/modules/explore/bloc/explore_bloc.dart';
import 'package:connect/repository/chat_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with WidgetsBindingObserver {
  final Map<String, Marker> _markers = <String, Marker>{};
  late GoogleMapController _googleMapController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    context
        .read<ExploreBloc>()
        .add(const ExploreEvent.getLocationPermissionStatus());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      context
          .read<ExploreBloc>()
          .add(const ExploreEvent.getLocationPermissionStatus());
    }
  }

  Future<void> _onMapCreated(
      GoogleMapController controller, LatLng location) async {
    _googleMapController = controller;
    moveToCurrentLocation(controller, location);
    // changeMapMode();
    await setMarkers();
  }

  Future<void> moveToCurrentLocation(
      GoogleMapController controller, LatLng location) async {
    controller.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(location.latitude, location.longitude),
        8.0,
      ),
    );
    // update user's location
    final ConnectUser user = context.read<ConnectUser>();
    final double latitude = location.latitude;
    final double longitude = location.longitude;
    final GeoPoint geoPoint = GeoPoint(latitude, longitude);
    final DocumentReference<Map<String, dynamic>> usersCollRef =
        FirebaseFirestore.instance.collection('users').doc(user.id);
    usersCollRef.update(
      <String, dynamic>{
        'location': geoPoint,
      },
    );
  }

  Future<void> setMarkers() async {
    _markers.clear();
    final QuerySnapshot<Map<String, dynamic>> usersCollRef =
        await FirebaseFirestore.instance.collection('users').get();
    for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
        in usersCollRef.docs) {
      final String userId = doc.get('id') as String;
      if (userId != context.read<ConnectUser>().id) {
        final String userName = doc.get('username') as String;
        final String? userProfileUrl = doc.get('profileUrl') as String?;
        if (doc.get('location') != null) {
          final GeoPoint location = doc.get('location') as GeoPoint;
          final List<geo.Placemark> placemarks = await geo
              .placemarkFromCoordinates(location.latitude, location.longitude);
          String? place;
          if (placemarks.isNotEmpty) {
            place = placemarks.first.country;
          }
          final Marker marker = Marker(
            markerId: MarkerId(userId),
            position: LatLng(location.latitude, location.longitude),
            infoWindow: InfoWindow(
              onTap: () async {
                context.read<ExploreBloc>().add(
                      ExploreEvent.fetchUserConversations(
                        docId: context.read<ConnectUser>().id,
                        peerId: userId,
                        peerName: userName,
                        peerProfileUrl: userProfileUrl,
                      ),
                    );
              },
              title: userName,
              snippet: place,
            ),
          );
          _markers.addAll(<String, Marker>{userId: marker});
          setState(() {});
        }
      }
    }
  }

  Future<void> navigateToConversation(
    List<Conversation> conversations,
    String peerId,
    String peerName,
    String? peerProfileUrl,
  ) async {
    String? conversationId;
    if (conversations.isNotEmpty) {
      final QuerySnapshot<Map<String, dynamic>> peerConversations =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(peerId)
              .collection('conversations')
              .get();
      if (peerConversations.docs.isNotEmpty) {
        for (final Conversation conv in conversations) {
          for (final QueryDocumentSnapshot<
                  Map<String, dynamic>> peerConversation
              in peerConversations.docs) {
            if (peerConversation.id == conv.id) {
              conversationId = conv.id;
              break;
            }
          }
          if (conversationId != null) {
            break;
          }
        }
      }
    }
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext ctx) {
          return BlocProvider<ConversationBloc>(
            create: (BuildContext context) => ConversationBloc(
              chatRepository: ChatRepository(),
            )..add(
                ConversationEvent.fetchConversation(
                  conversationId: conversationId,
                ),
              ),
            child: ConversationScreen(
              currentUserId: context.read<ConnectUser>().id,
              conversationId: conversationId,
              peerId: peerId,
              peerName: peerName,
              peerProfileUrl: peerProfileUrl,
            ),
          );
        },
      ),
    );
    context
        .read<ExploreBloc>()
        .add(const ExploreEvent.getLocationPermissionStatus());
  }

  // void changeMapMode() {
  //   getMapNightJson('assets/map_night.json')
  //       .then((String mapStyle) => setMapStyle(mapStyle));
  // }

  void setMapStyle(String mapStyle) {
    _googleMapController.setMapStyle(mapStyle);
  }

  Future<String> getMapNightJson(String path) async {
    return rootBundle.loadString(path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: BlocConsumer<ExploreBloc, ExploreState>(
      listener: (BuildContext context, ExploreState state) {
        state.maybeWhen(
          loadInProgress: () => EasyLoading.show(),
          locationPermissionStatusSuccess: () {
            EasyLoading.dismiss();
            context
                .read<ExploreBloc>()
                .add(const ExploreEvent.getCurrentLocation());
          },
          locationPermissionStatusFailure: () {
            EasyLoading.dismiss();
          },
          getCurrentLocationSuccess: (LatLng location) {
            EasyLoading.dismiss();
          },
          getCurrentLocationFailure: () {
            EasyLoading.dismiss();
          },
          fetchUserConversationsSuccess: (
            List<Conversation> conversations,
            String peerId,
            String peerName,
            String? peerProfileUrl,
          ) {
            EasyLoading.dismiss();
            navigateToConversation(
              conversations,
              peerId,
              peerName,
              peerProfileUrl,
            );
          },
          fetchUserConversationsFailure: (NetworkExceptions exception) {
            EasyLoading.dismiss();
            _showAlert(context);
          },
          orElse: () => null,
        );
      },
      buildWhen: (ExploreState previous, ExploreState current) {
        return current.maybeWhen(
          locationPermissionStatusSuccess: () => false,
          fetchUserConversationsSuccess: (
            List<Conversation> conversations,
            String peerId,
            String peerName,
            String? peerProfileUrl,
          ) =>
              false,
          fetchUserConversationsFailure: (NetworkExceptions exception) => false,
          orElse: () => true,
        );
      },
      builder: (BuildContext context, ExploreState state) {
        return state.maybeWhen(
          getCurrentLocationSuccess: (LatLng location) {
            return GoogleMap(
              onMapCreated: (GoogleMapController googleMapController) =>
                  _onMapCreated(googleMapController, location),
              initialCameraPosition: CameraPosition(
                target: location,
                zoom: 8.0,
              ),
              markers: _markers.values.toSet(),
            );
          },
          locationPermissionStatusFailure: () {
            return _buildEnableLocation(context);
          },
          getCurrentLocationFailure: () {
            return _buildEnableLocation(context);
          },
          orElse: () => const SizedBox(),
        );
      },
    ));
  }

  Widget _buildEnableLocation(BuildContext context) {
    return Center(
      child: MaterialButton(
        onPressed: () async {
          if (Platform.isAndroid) {
            if (await ph.Permission.location.shouldShowRequestRationale) {
              await ph.openAppSettings();
            } else {
              await ph.Permission.location.request();
              context
                  .read<ExploreBloc>()
                  .add(const ExploreEvent.getLocationPermissionStatus());
            }
          } else {
            if (await ph.Permission.location.isPermanentlyDenied) {
              await ph.openAppSettings();
            } else {
              await ph.Permission.location.request();
              context
                  .read<ExploreBloc>()
                  .add(const ExploreEvent.getLocationPermissionStatus());
            }
          }
        },
        child: const Text('Enable location to explore'),
      ),
    );
  }

  void _showAlert(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alert'),
          content: const Text('Something went wrong. Please try again.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
