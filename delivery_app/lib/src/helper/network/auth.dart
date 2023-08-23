import 'dart:io';

convert(value) {
  return Platform.isWindows ? Uri.encodeComponent(value.toString()) : value;
}

Future<Map<String, String>> authToJson(Auth data) async {
  return data.token != ''
      ? {
          'Content-Type': 'application/json',
          'authorization': 'Bearer ${data.token}',
        }
      : {
          'Content-Type': 'application/json',
        };
}

class Auth {
  Auth({
    this.token = '',
  });
  String token;
}
