// ignore_for_file: file_names

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

Interceptor loggerInterceptor = InterceptorsWrapper(
  onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('REQUEST[${options.method}] => PATH: ${options.path} => ');
    // debugPrint('HEADERS: ${options.headers} => BODY: ${options.data}');

    return handler.next(options);
  },
  onResponse: (Response response, ResponseInterceptorHandler handler) {
    debugPrint(
        'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path} => DATA: ${response.data}');

    return handler.next(response);
  },
  onError: (DioException e, ErrorInterceptorHandler handler) {
    debugPrint(
        'ERROR[${e.response?.statusCode}] => PAYLOAD: ${e.response?.data}');

    return handler.next(e); //continue
  },
);
