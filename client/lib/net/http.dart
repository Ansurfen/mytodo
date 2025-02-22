import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:my_todo/config.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class HTTP {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: TodoConfig.baseUri,
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  ))
    ..interceptors.add(Gateway());

  static void setBaseUrl(String url) {
    _dio.options.baseUrl = url;
  }

  static Future get(String path,
      {Object? data, Map<String, dynamic>? queryParams, Options? options}) {
    return _dio.get(path,
        data: data, queryParameters: queryParams, options: options);
  }

  static Future<Response<T>> post<T>(String path,
      {Object? data, Map<String, dynamic>? queryParams, Options? options}) {
    return _dio.post(path,
        data: data, queryParameters: queryParams, options: options);
  }
}

class Gateway extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    showLoading();
    if (kDebugMode) {
      print(
          'REQUEST[${options.method}] => PATH: ${options.baseUrl}${options.path}');
    }
    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    EasyLoading.dismiss();
    if (kDebugMode) {
      print(
          'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
      if (response.data["code"] != 200) {
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
      // Guard.log.e(err.stackTrace);
      print(
          'ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
    }
    return super.onError(err, handler);
  }
}

void showException(Exception e,
    {EasyLoadingMaskType maskType = EasyLoadingMaskType.none}) {
  EasyLoading.showError(e.toString(), maskType: maskType, dismissOnTap: true);
}

void showLoading({EasyLoadingMaskType maskType = EasyLoadingMaskType.clear}) {
  EasyLoading.show(status: "loading".tr, maskType: maskType);
}
