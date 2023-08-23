import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../helper/network/network_provider.dart';
import '../helper/storage/secure_store.dart';
import '../routes.dart';
import 'profile_controller.dart';

class LoginController extends GetxController {
  var isLoading = false;
  bool error = false;
  String errortext = '';
  bool complete = false;
  bool obscureText = true;

  final RoundedLoadingButtonController btnController =
      RoundedLoadingButtonController();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<bool> login() async {
    var login = {
      "email": emailController.text,
      "password": passwordController.text,
    };
    debugPrint(login.toString());
    if (await InternetConnectionChecker().hasConnection) {
      var response =
          await NetworkHandler.post(body: login, endpoint: 'auth/login/');
      if (response[1] == 200) {
        try {
          Map data = (response[0]);

          // Store The Token
          await SecuredStorage.store(
              key: SharedKeys.token, value: data['token']);

          data.remove('token');
          final user = User.fromJson(data);

          // Store The User
          await SecuredStorage.store(
              key: SharedKeys.user, value: jsonEncode(user.toJson()));
          var x = await SecuredStorage.read(key: SharedKeys.user);

          User y = User.fromJson(jsonDecode(x!));

          ProfileController profileController = Get.put(ProfileController());
          profileController.user = y;

          btnController.success();
          Timer(const Duration(milliseconds: 1300), () {
            btnController.reset();
            Timer(const Duration(milliseconds: 300), () {
              Get.toNamed(RoutesConstant.mainMenu);
            });
          });
          return true;
        } catch (e) {
          btnController.error();
          Timer(const Duration(seconds: 2), () {
            btnController.reset();
          });
          debugPrint("$e");
          return false;
        }
      }
    } else {
      return false;
    }
    errortext = 'Something went wrong';
    update();
    btnController.error();
    Timer(const Duration(seconds: 2), () {
      btnController.reset();
      Timer(const Duration(seconds: 2), () {
        errortext = '';
        update();
      });
    });
    return false;
  }
}
