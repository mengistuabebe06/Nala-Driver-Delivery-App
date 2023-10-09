import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SharedKeys {
  static const String token = "token";
  static const String user = "user";
  static const String firstTime = "firstTime";
  static const String theme = "theme";
  static const String deliveries = "deliveries";
  static const String profile = "profile";
  static const String package = "package";
  static const String notification = "notification";
  static const List list = [
    token,
    user,
    firstTime,
    deliveries,
    theme,
    profile,
    package,
    notification,
  ];
}

class SecuredStorage {
  static late FlutterSecureStorage _storage;

  static Future<void> initialize() async {
    _storage = new FlutterSecureStorage();
  }

  static Future<bool> check({required String key}) async {
    return _storage.containsKey(key: key);
  }

  static Future<String?> read({required String key}) async {
    try {
      return _storage.read(key: key);
    } catch (e) {
      print('Error while reading preference keys: $e');
      return null;
    }
  }

  static Future<void> store(
      {required String key, required String value}) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      print('Error while storing preference keys: $e');
    }
  }

  static Future<void> clear() async {
    for (var key in SharedKeys.list) {
      try {
        await _storage.delete(key: key);
      } catch (e) {
        print('Error while clearing preference keys: $e');
      }
    }
  }

  static Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      print('Error while deleting preference key: $e');
    }
  }
}
