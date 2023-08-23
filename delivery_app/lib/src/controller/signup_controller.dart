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

class SignUpController extends GetxController {
  var isLoading = false;
  bool error = false;
  String errortext = '';
  bool complete = false;
  bool obscureText = true;
  final FocusNode firstnameFocusNode = FocusNode();
  final FocusNode lastnameFocusNode = FocusNode();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode phoneNoFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  final RoundedLoadingButtonController btnController =
      RoundedLoadingButtonController();

  final TextEditingController phoneNoController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController lnameController = TextEditingController();
  final TextEditingController fnameController = TextEditingController();

  Future<bool> signUp() async {
    var signUp = {
      "email": emailController.text.trim(),
      "fname": fnameController.text.trim(),
      "lname": lnameController.text.trim(),
      "password": passwordController.text,
      "phone_no": phoneNoController.text,
    };
    debugPrint("$signUp");
    if (await InternetConnectionChecker().hasConnection) {
      var response =
          await NetworkHandler.post(body: signUp, endpoint: 'auth/register/');
      if (response[1] == 200) {
        try {
          Map data = (response[0]);
          debugPrint("$data");

          // Store The Token
          await SecuredStorage.store(
              key: SharedKeys.token, value: data['accessToken']);

          data.remove('accessToken');
          final user = User.fromJson(data);

          // Store The User
          await SecuredStorage.store(
              key: SharedKeys.user, value: jsonEncode(user.toJson()));

          var x = await SecuredStorage.read(key: SharedKeys.user);

          User y = User.fromJson(jsonDecode(x!));

          ProfileController profileController = Get.put(ProfileController());
          profileController.user = y;

          btnController.success();
          Timer(const Duration(seconds: 2), () {
            btnController.reset();
            Timer(const Duration(milliseconds: 80), () {
              Get.toNamed(RoutesConstant.mainMenu);
            });
          });
          return true;
        } catch (e) {
          btnController.error();
          Timer(const Duration(seconds: 2), () {
            btnController.reset();
          });
          (e);
          return false;
        }
      }
    } else {
      // showSimpleNotification(const Text("Check your Internet Connection ..."),
      //     background: Colors.red);
      return false;
    }
    errortext = 'User with this Email already exists';
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
