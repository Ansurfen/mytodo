// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:my_todo/utils/dialog.dart';

import 'package:my_todo/utils/guard.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class HTTP {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: Guard.server,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
    ),
  )..interceptors.add(Gateway());

  static void setBaseUrl(String url) {
    _dio.options.baseUrl = url;
  }

  static Future get(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParams,
    Options? options,
  }) {
    return _dio.get(
      path,
      data: data,
      queryParameters: queryParams,
      options: options,
    );
  }

  static Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParams,
    Options? options,
  }) {
    return _dio.post(
      path,
      data: data,
      queryParameters: queryParams,
      options: options,
    );
  }

  static Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParams,
    Options? options,
  }) {
    return _dio.delete(
      path,
      data: data,
      queryParameters: queryParams,
      options: options,
    );
  }
}

class Gateway extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    showLoading();
    if (kDebugMode) {
      print(
        'REQUEST[${options.method}] => PATH: ${options.baseUrl}${options.path}',
      );
    }
    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    EasyLoading.dismiss();
    if (kDebugMode) {
      print(
        'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
      );
      if (response.statusCode != 200) {
        EasyLoading.showError(response.data["msg"]);
      }
    }
    return super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    EasyLoading.dismiss();
    showException(err);
    if (kDebugMode) {
      Guard.log.e(err.stackTrace);
      print(
        'ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}',
      );
    }
    return super.onError(err, handler);
  }
}

class WS {
  static Future init() async {
    final channel = WebSocketChannel.connect(
      Uri.parse("ws://localhost:8080/qr"),
    );
    channel.stream.listen((data) {
      // channel.sink.add("hello world!");
      if (kDebugMode) {
        print(data);
      }
      // channel.sink.close();
    });
    channel.sink.add("hello world!");
  }

  static WebSocketChannel listen(
    String route, {
    String? onInit,
    ValueChanged<dynamic>? callback,
  }) {
    final channel = WebSocketChannel.connect(
      Uri.parse("ws://localhost:8080$route"),
    );
    if (onInit != null) {
      channel.sink.add(onInit);
    }
    channel.stream.listen(callback ?? (v) {});
    return channel;
  }
}
