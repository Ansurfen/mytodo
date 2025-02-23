// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

const Map<Type, String> exceptionFormat = {
  DioException: "exp.dio",
  MissingPluginException: "exp.mp",
  UnsupportedError: "exp.mp"
};

extension ExceptionI18NExtension on Exception {
  String get tr {
    String? key = exceptionFormat[runtimeType];
    if (key != null) {
      return key.tr;
    }
    return "exp.unknown".tr;
  }
}

extension ErrorI18NExtension on Error {
  String get tr {
    String? key = exceptionFormat[runtimeType];
    if (key != null) {
      return key.tr;
    }
    return "exp.unknown".tr;
  }
}