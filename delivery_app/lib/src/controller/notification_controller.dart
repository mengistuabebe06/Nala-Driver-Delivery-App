import 'dart:convert';

import 'package:NalaDelivery/src/controller/home_controller.dart';
import 'package:NalaDelivery/src/routes.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:get/get.dart';
import '../helper/storage/secure_store.dart';
import 'profile_controller.dart';

class NotificationController {
  /// Use this method to detect when a new notification or a schedule is created
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    // Your code goes here
  }

  /// Use this method to detect every time that a new notification is displayed
  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    // Your code goes here
    FlutterBackgroundService().on('addDelivery').listen(
          (event) async {},
        );
  }

  /// Use this method to detect if the user dismissed a notification
  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    // Your code goes here
  }

  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    // Your code goes here

    final userJson = await SecuredStorage.read(key: SharedKeys.user);

    final user = User.fromJson(jsonDecode(userJson!));

    Map data = jsonDecode(receivedAction.payload!['data']!);

    if (receivedAction.buttonKeyPressed == 'accept_action') {
      FlutterBackgroundService().invoke(
        "deliveryRequestResponse",
        {
          "data": {
            "delivered": false,
            "orderId": data['orderId'],
            "accepted": true,
            "userId": user.id,
          },
        },
      );
      Get.toNamed(RoutesConstant.mainMenu);
      Get.find<HomeController>().getSnack(data);
    } else if (receivedAction.buttonKeyPressed == 'reject_action') {
      // Handle the "Reject" action
    }
  }
}
