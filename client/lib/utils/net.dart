// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:my_todo/config.dart';
import 'package:my_todo/utils/dialog.dart';
import 'package:my_todo/utils/guard.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

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
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    EasyLoading.dismiss();
    showException(err);
    if (err.response?.statusCode == 401 &&
        err.response?.data["msg"] == "token expired" &&
        err.requestOptions.extra["_retry"] != true) {
      Guard.log.i(err.response?.data["data"]);
      Guard.jwt = err.response?.data["data"];

      err.requestOptions.extra["_retry"] = true;
      final retry = await HTTP._dio.request(
        err.requestOptions.path,
        options: Options(
          headers:
              err.requestOptions.headers..addAll({"Authorization": Guard.jwt}),
        ),
      );
      if (retry.statusCode == 200) {
        return handler.resolve(retry);
      } else {
        return handler.reject(
          DioException(requestOptions: err.requestOptions, error: err.error),
        );
      }
    }
    if (kDebugMode) {
      Guard.log.e(err.stackTrace);
      print(
        'ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}',
      );
    }
    return handler.next(err);
  }
}

class WS {
  static Future init() async {
    final channel = WebSocketChannel.connect(
      Uri.parse("${TodoConfig.wsUri}/qr"),
    );
    channel.stream.listen((data) {
      if (kDebugMode) {
        print(data);
      }
    });
    channel.sink.add("hello world!");
  }

  static WebSocketChannel listen(
    String route, {
    String? onInit,
    ValueChanged<dynamic>? callback,
  }) {
    final uri = "${TodoConfig.wsUri}$route";
    final headers = {
      'Authorization': Guard.jwt,
    };

    WebSocketChannel channel;
    if (kIsWeb) {
      // Web 平台使用原生 WebSocket
      final webUri = Uri.parse(uri).replace(
        queryParameters: {
          'token': Guard.jwt,
        },
      );
      channel = WebSocketChannel.connect(webUri);
    } else {
      // 移动平台使用 io.dart
      channel = IOWebSocketChannel.connect(
        uri,
        headers: headers,
      );
    }

    if (onInit != null) {
      channel.sink.add(onInit);
    }
    channel.stream.listen(callback ?? (v) {});
    return channel;
  }
}
