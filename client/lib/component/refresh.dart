// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'dart:async';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TodoRefreshFooter extends ClassicFooter {
  BuildContext context;

  TodoRefreshFooter(this.context);

  @override
  double? get infiniteOffset => null;

  @override
  String? get dragText => "refresh_drag".tr;

  @override
  String? get armedText => "refresh_armed".tr;

  @override
  String? get readyText => "refresh_ready".tr;

  @override
  String? get processingText => "refresh_processing".tr;

  @override
  String? get processedText => "refresh_processed".tr;

  @override
  String? get noMoreText => "refresh_no_more".tr;

  @override
  String? get failedText => "refresh_failed".tr;

  @override
  String? get messageText => "refresh_message".tr;

  @override
  IconThemeData? get iconTheme =>
      IconThemeData(color: Theme.of(context).primaryColor);
}

class TodoRefreshHeader extends ClassicHeader {
  BuildContext context;

  TodoRefreshHeader(this.context);

  @override
  String? get dragText => "refresh_drag".tr;

  @override
  String? get armedText => "refresh_armed".tr;

  @override
  String? get readyText => "refresh_ready".tr;

  @override
  String? get processingText => "refresh_processing".tr;

  @override
  String? get processedText => "refresh_processed".tr;

  @override
  String? get noMoreText => "refresh_no_more".tr;

  @override
  String? get failedText => "refresh_failed".tr;

  @override
  String? get messageText => "refresh_message".tr;

  @override
  IconThemeData? get iconTheme =>
      IconThemeData(color: Theme.of(context).primaryColor);
}

Widget refreshContainer(
    {required BuildContext context,
    required Widget child,
    FutureOr Function()? onRefresh,
    FutureOr Function()? onLoad,
    EasyRefreshController? controller}) {
  return EasyRefresh(
    controller: controller,
    header: TodoRefreshHeader(context),
    footer: TodoRefreshFooter(context),
    onRefresh: onRefresh,
    onLoad: onLoad,
    child: child,
  );
}
