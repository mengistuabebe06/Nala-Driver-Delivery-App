import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:image_picker/image_picker.dart';

import '../helper/network/network_provider.dart';
import '../helper/storage/secure_store.dart';
import '../routes.dart';

class ProfileController extends GetxController {
  var isLoading = false;
  var formKey = GlobalKey<FormState>();
  User? user;
  XFile? profilePic;
  XFile? coverPic;
  List? companies;
  List? categories;
  TextEditingController fname = TextEditingController();
  TextEditingController lname = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController compbio = TextEditingController();
  TextEditingController profbio = TextEditingController();
  TextEditingController phoneNumber = TextEditingController();

  @override
  void onInit() async {
    try {
      await SecuredStorage.read(key: SharedKeys.user)
          .then((value) => user = User.fromJson(jsonDecode(value!)));
    } catch (e) {
      debugPrint("$e");
    }
    super.onInit();
  }

  Future<void> logout() async {
    await SecuredStorage.clear();
    Get.offAllNamed(RoutesConstant.login);
  }

  Future<bool> editProfile() async {
    isLoading = true;
    update();
    late FormData formData;
    formData = FormData.fromMap(
      {
        'profilePic': profilePic == null
            ? null
            : await MultipartFile.fromFile(profilePic!.path,
                filename: 'Profile.jpg'),
        'coverPic': coverPic == null
            ? null
            : await MultipartFile.fromFile(coverPic!.path,
                filename: 'cover.jpg'),
        'lname': lname.text,
        'fname': fname.text,
        'phoneNumber': phoneNumber.text,
        'bio': profbio.text
      },
    );

    var response = await NetworkHandler.post(
        body: formData, endpoint: 'profile/${user!.id}');
    if (response[1] == 200) {
      try {
        Map data = (response[0]);

        user = User.fromJson(data);

        await SecuredStorage.store(
            key: SharedKeys.user, value: jsonEncode(user!.toJson()));
        isLoading = false;
        update();
        return true;
      } catch (e) {
        debugPrint("$e");
        isLoading = false;
        update();
        return false;
      }
    }
    isLoading = false;
    update();
    return false;
  }

  Future<void> getImage({required bool profile}) async {
    final ImagePicker picker = ImagePicker();
    // Pick an image.
    if (profile) {
      profilePic = null;
      profilePic = await picker.pickImage(source: ImageSource.gallery);
    } else {
      coverPic = null;
      coverPic = await picker.pickImage(source: ImageSource.gallery);
    }
    update();
  }

  Future<List> getCompanies() async {
    return await Future.delayed(
      const Duration(seconds: 1),
      () async {
        var response = await NetworkHandler.get(endpoint: 'companies/');
        if (response[1] == 200 || response[1] == 304) {
          try {
            List data = (response[0]);
            companies = data;
            return data;
          } catch (e) {
            debugPrint("$e");
            return [];
          }
        }
        return [];
      },
    );
  }
}

class User {
  String id;
  String name;
  String email;
  String profilePic;
  String phoneNumber;
  double? lat;
  double? long;
  int? age;

  User({
    required this.id,
    required this.name,
    required this.profilePic,
    required this.phoneNumber,
    required this.email,
    required this.lat,
    required this.long,
  });

  factory User.fromJson(Map<dynamic, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      profilePic: json['profilePic'],
      phoneNumber: json['phone_no'],
      lat: json['lat'],
      long: json['long'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profilePic': profilePic,
      'phone_no': phoneNumber,
      'lat': lat,
      'long': long,
    };
  }
}
