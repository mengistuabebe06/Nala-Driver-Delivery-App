import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedKeys {
  static const String token = "token";
  static const String user = "user";
  static const String firstTime = "firstTime";
  static const String theme = "theme";
  static const String profile = "profile";
  static const String package = "package";
  static const String notification = "notification";
  static const List list = [
    token,
    user,
    firstTime,
    theme,
    profile,
    package,
    notification,
  ];
}

class SecuredStorage {
  static SharedPreferences? storage;

  static Future<bool> check({required String key}) async {
    storage = await SharedPreferences.getInstance();
    debugPrint('SECURE STORAGE : CHECKING THE KEY CALLED $key');
    return storage!.containsKey(key);
  }

  static Future<String?> read({required String key}) async {
    storage = await SharedPreferences.getInstance();
    debugPrint('SECURE STORAGE : READING THE KEY CALLED $key');
    try {
      return storage?.getString(key);
    } catch (e) {
      debugPrint('ERROR WHILE READING PREFRENCE KEYS !! $e');
    }
    return null;
  }

  static Future<void> store(
      {required String key, required String value}) async {
    storage = await SharedPreferences.getInstance();
    debugPrint('SECURE STORAGE : STORING TO KEY CALLED $key');
    try {
      await storage?.setString(key, value);
    } catch (e) {
      debugPrint('ERROR WHILE STORING PREFRENCE KEYS !! $e');
    }
  }

  static Future<void> clear() async {
    storage = await SharedPreferences.getInstance();
    debugPrint('CLEARING PREFRENCE KEYS !!');
    for (var key in SharedKeys.list) {
      try {
        await (storage as SharedPreferences).remove(key);
      } catch (e) {
        debugPrint('ERROR WHILE CLEARING PREFRENCE KEYS !! $e');
      }
    }
  }

  static Future<void> delete(key) async {
    storage = await SharedPreferences.getInstance();
    debugPrint('CLEARING REFRESH TOKEN !!');
    await (storage as SharedPreferences).remove(key);
  }
}
