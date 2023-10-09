import 'dart:convert';
import 'dart:ui';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import 'package:socket_io_client/socket_io_client.dart' as io_client;

import '../../controller/profile_controller.dart';
import '../network/network_provider.dart';
import '../storage/secure_store.dart';

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    iosConfiguration: IosConfiguration(),
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: false,
      autoStart: true,
    ),
  );
}

@pragma('vm:entry-point')
Future<void> onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  // -----------------Environment Setup-----------------
  await dotenv.load(fileName: ".env");
  await SecuredStorage.initialize();

  service.on('getDeliveries').listen((event) async {
    final userJson = await SecuredStorage.read(key: SharedKeys.user);
    if (userJson != null) {
      final user = User.fromJson(jsonDecode(userJson));

      if (await InternetConnectionChecker().hasConnection) {
        var response = await NetworkHandler.get(endpoint: 'orders/${user.id}');
        if (response[1] == 200) {
          List data = response[0]['orders'];
          List added = data.map((e) {
            e['accepted'] = false;
            return e;
          }).toList();
          await SecuredStorage.store(
              key: SharedKeys.deliveries, value: jsonEncode(added));
        }
      }
    }
  });

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  final String urlX = dotenv.get("Base-Url", fallback: "");
  final String url = urlX.split("/api")[0];

  io_client.Socket socket = io_client.io(
      url, io_client.OptionBuilder().setTransports(['websocket']).build());

  socket.onDisconnect((_) => debugPrint('disconnect'));

  socket.onConnect((_) {
    debugPrint('connect');
    // service.invoke("startService");
  });

  socket.on("deliveryRequest", (data) async {
    String? storedData = await SecuredStorage.read(key: SharedKeys.deliveries);

    List<dynamic> combinedData = [];

    if (storedData != null) {
      List<dynamic> previousData = jsonDecode(storedData);
      combinedData.addAll(previousData);
    }
    (data as Map<String, dynamic>).addAll({"accepted": false});
    combinedData.add(data);

    service.invoke("NotificationUpdate", {
      "data": jsonEncode(combinedData),
    });

    await SecuredStorage.store(
        key: SharedKeys.deliveries, value: jsonEncode(combinedData));

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1,
        channelKey: 'delivery_notifier',
        title: 'New Delivery Request',
        body: 'You have a new delivery request from ${data['deliverTo']}',
        payload: {"data": jsonEncode(data)},
      ),
      actionButtons: [
        NotificationActionButton(
            key: 'accept_action',
            label: 'Accept',
            actionType: ActionType.KeepOnTop),
        NotificationActionButton(
            key: 'reject_action',
            label: 'Reject',
            actionType: ActionType.KeepOnTop),
      ],
    );
  });

  socket.on("update", (data) {
    service.invoke("positionUpdate");
  });

  service.on("startService").listen((event) async {
    if (event != null) {
      final data = event['data'];
      final user = data['user'];
      double? lat;
      double? long;
      await getCurrentLocation().then((value) {
        lat = value.latitude;
        long = value.longitude;
      });

      socket.emit('sendLocation', {
        "userId": user,
        "lat": lat,
        "long": long,
      });
    }
  });

  service.on("updatePosition").listen((event) {
    if (event != null) {
      final userId = event['userId'];
      double? lat;
      double? long;
      getCurrentLocation().then((value) {
        lat = value.latitude;
        long = value.longitude;

        socket.emit('sendLocation', {
          "userId": userId,
          "lat": lat,
          "long": long,
        });
      });
    }
  });

  service.on("deliveryRequestResponse").listen((event) async {
    var data = {};
    if (event != null) {
      data = event['data'];
      socket.emit('deliveryRequestResponse', data);
    }
  });

  service.on("stopService").listen((event) {
    service.stopSelf();
  });
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
