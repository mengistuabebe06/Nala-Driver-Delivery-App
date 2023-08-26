import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';

import '../storage/secure_store.dart';
import 'auth.dart';
import 'network_service_provider.dart';

class NetworkHandler {
  static Future<String> downloadImage(
      {required String url, required String fileName}) async {
    final appStore = await getApplicationDocumentsDirectory();
    final file = File('${appStore.path}/$fileName');

    try {
      final response = await Dio()
          .get(url,
              options: Options(
                responseType: ResponseType.bytes,
                followRedirects: false,
                receiveTimeout: const Duration(seconds: 20),
              ))
          .timeout(const Duration(seconds: 20));
      final raf = file.openSync(mode: FileMode.write);
      raf.writeFromSync(response.data);
      await raf.close();
    } on DioException catch (e) {
      debugPrint("ERROR WHILE DOWNLOADING IMAGE: $e");
    } catch (e) {
      debugPrint("ERROR WHILE DOWNLOADING IMAGE: $e");
    }

    return file.path;
  }

  static Future<dynamic> sendImage(String? image, String endpoint) async {
    String? token = await SecuredStorage.read(key: SharedKeys.token);

    FormData formData = FormData.fromMap({
      "profile_pic": await MultipartFile.fromFile((image!), filename: image),
    });
    final header = {
      'authentication': 'Bearer $token',
    };
    Response<dynamic>? response;
    try {
      final dio = Dio();
      dio.options.contentType = Headers.multipartFormDataContentType;
      dio.options.headers = header;
      response = await dio.patch(
        buildStringUrl(endpoint),
        data: formData,
      );
    } on DioException catch (e) {
      debugPrint("ERROR WHILE UPLOADING IMAGE: $e");
    }

    return response;
  }

  static Future<List> uploadProfile(
      {required String? image, required String endpoint}) async {
    // ignore: unused_local_variable, prefer_typing_uninitialized_variables
    var imageResponse;

    if (image != null && image != '') {
      imageResponse = await sendImage(image, endpoint);
    }

    return [imageResponse?.data, imageResponse?.statusCode];
  }

  static Future<List> urlToFile(String imageUrl) async {
    final tempDir = await getTemporaryDirectory();
    final extension = getImageExtension(imageUrl);
    final file = File(
        '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}$extension');
    try {
      final response = await Dio().get<List<int>>(
        imageUrl,
        options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            validateStatus: (status) {
              return status! < 500;
            }),
      );
      // Write response bytes directly to file.
      await file.writeAsBytes(response.data!);
      // Return the file and status code.
      return [response.statusCode, file];
    } on DioException catch (e) {
      debugPrint("ERROR WHILE DOWNLOADING IMAGE: $e");
      return [0, []];
    }
  }

  static String getImageExtension(String imageUrl) {
    final contentType = lookupMimeType(imageUrl);
    if (contentType == 'image/jpeg') {
      return '.jpg';
    } else if (contentType == 'image/gif') {
      return '.gif';
    } else {
      return '.png';
    }
  }

  static Future<List> post(
      {required var body, required String endpoint}) async {
    try {
      String? token = await SecuredStorage.read(key: SharedKeys.token);
      Auth header = Auth(token: token ?? '');

      final response = await provider(await authToJson(header)).post(
        buildStringUrl(endpoint),
        data: body,
      );

      return [response.data, response.statusCode];
    } on DioException catch (e) {
      if (e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        debugPrint("ERROR WHILE POSTING: $e");
        return [[], e.response?.statusCode];
      } else if (e.response == null) {
        debugPrint("ERROR WHILE POSTING: $e");
      }
      return [[], e.response?.statusCode];
    } on SocketException {
      return [[], 0];
    }
  }

  static Future<List> put(
      {String auth = '', required var body, required String endpoint}) async {
    try {
      String? token = await SecuredStorage.read(key: SharedKeys.token);
      Auth header = Auth(token: token ?? '');

      final response = await provider(await authToJson(header)).put(
        buildStringUrl(endpoint),
        data: body,
      );

      return [response.data, response.statusCode];
    } on DioException catch (e) {
      if (e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        debugPrint("TIMEOUT ERROR: $e");
        return [[], e.response?.statusCode];
      } else {
        debugPrint("$e");
        return [[], e.response?.statusCode];
      }
    } on SocketException {
      return [0, 0];
    }
  }

  static Future<List> delete({
    String auth = '',
    required String endpoint,
    Map<String, dynamic> data = const {},
  }) async {
    try {
      String? token = await SecuredStorage.read(key: SharedKeys.token);

      Auth header = Auth(token: token ?? "");

      Response response = await provider(await authToJson(header))
          .delete(buildStringUrl(endpoint), data: data);

      return [response.data, response.statusCode];
    } on DioException catch (e) {
      debugPrint("$e");
      return [[], e.response?.statusCode];
    } on SocketException {
      return [0, 0];
    }
  }

  static Future<List> patch(
      {String auth = '', required var body, required String endpoint}) async {
    try {
      String? token = await SecuredStorage.read(key: SharedKeys.token);

      Auth header = Auth(token: token ?? "");

      var response = await provider(await authToJson(header)).patch(
        buildStringUrl(endpoint),
        data: body,
      );
      return [response.data, response.statusCode];
    } on DioException catch (e) {
      debugPrint("$e");
      return [[], e.response?.statusCode];
    } on SocketException {
      return [0, 0];
    }
  }

  static Future<List> get({String auth = '', required String endpoint}) async {
    try {
      String? token = await SecuredStorage.read(key: SharedKeys.token);

      debugPrint("TOKEN: $token");

      Auth header = Auth(token: token ?? "");

      var response = await provider(await authToJson(header)).get(
        buildStringUrl(endpoint),
      );
      return [response.data, response.statusCode];
    } on DioException catch (e) {
      debugPrint("$e");
      return [[], e.response?.statusCode];
    } on SocketException {
      return [0, 0];
    }
  }

  static String url = dotenv.get('Base-Url', fallback: '/');

  static String buildStringUrl(String endpoint) => '$url$endpoint';
}
