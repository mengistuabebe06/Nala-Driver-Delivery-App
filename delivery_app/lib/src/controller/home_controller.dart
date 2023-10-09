import 'dart:async';
import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import '../helper/background_service/background.dart';
import '../helper/storage/secure_store.dart';
import 'profile_controller.dart';

class HomeController extends GetxController {
  double lat = 0.0;
  double long = 0.0;
  User? user;
  List deliveries = [];
  final Set<Marker> markers = {};
  final Set<Polyline> polylines = {};
  final Completer<GoogleMapController> tController =
      Completer<GoogleMapController>();

  CameraPosition pos =
      const CameraPosition(target: LatLng(38, 9), zoom: 19.151926040649414);

  Future<void> _goToTheLake(var position) async {
    final GoogleMapController controller = await tController.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(position));
  }

  void connectSocket() async {
    final isRunning = await FlutterBackgroundService().isRunning();
    if (!isRunning) {
      await initializeService();
    }
    FlutterBackgroundService().invoke("startService", {
      "data": {"user": user?.id, "lat": lat, "long": long}
    });

    FlutterBackgroundService().on('positionUpdate').listen((event) {
      FlutterBackgroundService().invoke(
        "updatePosition",
        {
          "userId": user?.id,
          "lat": lat,
          "long": long,
        },
      );
    });

    FlutterBackgroundService().invoke("getDeliveries");

    FlutterBackgroundService().on('NotificationUpdate').listen((event) {
      if (event != null) {
        final data = jsonDecode(event['data']);
        deliveries = data;
        update();
      }
    });
  }

  void setDelivered(data) async {
    for (var delivery in deliveries) {
      if (delivery["orderId"] == data["orderId"]) {
        delivery["status"] = "Delivered";
      }
    }

    markers.clear();
    polylines.clear();

    await Future.delayed(const Duration(seconds: 3));

    await SecuredStorage.store(
        key: SharedKeys.deliveries, value: jsonEncode(deliveries));

    FlutterBackgroundService().invoke(
      "deliveryRequestResponse",
      {
        "data": {
          "delivered": true,
          "orderId": data['orderId'],
          "accepted": true,
          "userId": user?.id,
          "lat": lat,
          "long": long,
        },
      },
    );
  }

  void getSnack(data) async {
    for (var delivery in deliveries) {
      if (delivery["orderId"] == data["orderId"]) {
        delivery["accepted"] = true;
        delivery["status"] = "Accepted";
      }
    }

    await SecuredStorage.store(
        key: SharedKeys.deliveries, value: jsonEncode(deliveries));

    FlutterBackgroundService().invoke(
      "deliveryRequestResponse",
      {
        "data": {
          "delivered": false,
          "orderId": data['orderId'],
          "accepted": true,
          "userId": user?.id,
          "lat": lat,
          "long": long,
        },
      },
    );

    markers.add(Marker(
      markerId: const MarkerId('deliveryFrom'),
      position: LatLng(data['initial_lat'] + 0.0, data['initial_long'] + 0.0),
      infoWindow: const InfoWindow(title: 'Pickup From Here'),
    ));
    markers.add(Marker(
      markerId: const MarkerId('deliveryTo'),
      position: LatLng(data['final_lat'] + 0.0, data['final_long'] + 0.0),
      infoWindow: const InfoWindow(title: 'Deliver To Here'),
    ));

    polylines.add(
      Polyline(
        polylineId: const PolylineId('Delivery Route'),
        points: [
          LatLng(lat, long),
          LatLng(data['initial_lat'] + 0.0, data['initial_long'] + 0.0),
          LatLng(data['final_lat'] + 0.0, data['final_long'] + 0.0),
        ],
        color: Colors.orange,
      ),
    );

    update();
  }

  @override
  onInit() async {
    await SecuredStorage.read(key: SharedKeys.user)
        .then((value) => user = User.fromJson(jsonDecode(value!)));

    await getCurrentLocation().then((value) {
      lat = value.latitude;
      long = value.longitude;
      update();

      connectSocket();

      CameraPosition newPosition =
          CameraPosition(target: LatLng(lat, long), zoom: 18.151926040649414);

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
    // sort deliveries based on time
    if (await SecuredStorage.check(key: SharedKeys.deliveries)) {
      final x = await SecuredStorage.read(key: SharedKeys.deliveries);
      deliveries = jsonDecode(x!);
    }

    if (deliveries.isNotEmpty) {
      deliveries.sort((a, b) {
        if (b["created_at"] != null && a["created_at"] != null) {
          return b['created_at'].compareTo(a['created_at']);
        }
        return 2;
      });

      // put the accepted deliveries at the top
      for (var delivery in deliveries) {
        if ((delivery as Map).containsKey("accepted")) {
          if (delivery['accepted']) {
            deliveries.remove(delivery);
            deliveries.insert(0, delivery);
          }
        }
      }
    }
    return deliveries;
  }

  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (await Permission.contacts.request().isGranted) {
        // Either the permission was already granted before or the user just granted it.
      }

// You can request multiple permissions at once.
      await [
        Permission.location,
      ].request();
      // print(status[Permission.location]);
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
