import 'dart:async';
import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:socket_io_client/socket_io_client.dart' as io_client;

import '../helper/network/network_provider.dart';
import '../helper/storage/secure_store.dart';
import 'profile_controller.dart';

class HomeController extends GetxController {
  double lat = 0.0;
  double long = 0.0;
  User? user;
  List deliveries = [];
  final Set<Marker> markers = {};
  final Set<Polyline> polylines = {};
  final Completer<GoogleMapController> t_controller =
      Completer<GoogleMapController>();

  CameraPosition pos =
      CameraPosition(target: LatLng(38, 9), zoom: 19.151926040649414);

  Future<void> _goToTheLake(var position) async {
    final GoogleMapController controller = await t_controller.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(position));
  }

  @override
  onInit() {
    getCurrentLocation().then((value) {
      lat = value.latitude;
      long = value.longitude;
      update();

      CameraPosition newPosition =
          CameraPosition(target: LatLng(lat, long), zoom: 19.151926040649414);

      markers.add(
        Marker(
          markerId: const MarkerId('initialLocation'),
          position: LatLng(lat, long),
          infoWindow: const InfoWindow(title: 'Current Location'),
        ),
      );

      pos = newPosition;
      update();

      _goToTheLake(newPosition);
    });
    checkFunction();

    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications()
            .requestPermissionToSendNotifications()
            .then((_) {});
      }
    });

    super.onInit();
  }

  Future getHistory() async {
    return Future.delayed(const Duration(seconds: 1), () async {
      return deliveries;
    });
  }

  void checkFunction() async {
    await SecuredStorage.read(key: SharedKeys.user)
        .then((value) => user = User.fromJson(jsonDecode(value!)));

    io_client.Socket socket = io_client.io('http://192.168.249.240:5000',
        io_client.OptionBuilder().setTransports(['websocket']).build());
    socket.onConnect((_) {
      debugPrint('connect');
      socket.emit('sendLocation', {
        "userId": user?.id,
        "lat": lat,
        "long": long,
      });
    });
    socket.on('deliveryRequest', (data) async {
      deliveries.add(data);
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 1,
          channelKey: 'delivery_notifier',
          title: 'New Delivery Request',
          body: 'You have a new delivery request from ${data['deliverTo']}',
        ),
      );

      // Snackbar for accepting or rejecting delivery
      Get.snackbar(
        'Delivery Request',
        'You have a delivery request',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color.fromARGB(255, 148, 134, 255),
        duration: const Duration(seconds: 15),
        mainButton: TextButton(
          onPressed: () {
            // remove snackbar
            Get.back();

            markers.add(Marker(
              markerId: const MarkerId('deliveryFrom'),
              position: LatLng(data['initialLat'], data['initialLong']),
              infoWindow: const InfoWindow(title: 'Pickup From Here'),
            ));
            markers.add(Marker(
              markerId: const MarkerId('deliveryTo'),
              position: LatLng(data['destLat'], data['destLong']),
              infoWindow: const InfoWindow(title: 'Deliver To Here'),
            ));

            polylines.add(Polyline(
              polylineId: const PolylineId('Delivery Route'),
              points: [
                LatLng(lat, long),
                LatLng(data['initialLat'], data['initialLong']),
                LatLng(data['destLat'], data['destLong']),
              ],
              color: Colors.orange,
            ));

            update();

            socket.emit('deliveryRequestResponse', {
              "accepted": true,
              "userId": user?.id,
              "lat": lat,
              "long": long,
            });
          },
          child: const Text(
            'Accept',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      );
    });
    socket.on('update', (_) {
      socket.emit('sendLocation', {
        "userId": user?.id,
        "lat": lat,
        "long": long,
      });
    });
    socket.onDisconnect((_) => debugPrint('disconnect'));
  }

  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    var x = await Geolocator.getCurrentPosition();

    debugPrint("${x.latitude}, ${x.longitude}");

    return x;
  }
}
