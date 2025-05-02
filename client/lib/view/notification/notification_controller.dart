// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/animation.dart';
import 'package:get/get.dart';
import 'package:my_todo/api/notification.dart';
import 'package:my_todo/model/entity/notify.dart';
import 'package:my_todo/utils/guard.dart';

class NotificationController extends GetxController
    with GetTickerProviderStateMixin {
  late final AnimationController animationController;
  RxList<Notify> notifications = <Notify>[].obs;

  @override
  void onInit() {
    super.onInit();
    animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    if (Guard.isDevMode()) {
      animationController.forward();
    } else {
      Future.delayed(const Duration(milliseconds: 100), () {
        animationController.forward();
        notificationPublishGetRequest(page: 1, pageSize: 10).then((res) {
          for (var e in res["notifications"]) {
            notifications.add(Notify.fromJson(e));
          }
        });
      });
    }
  }
}
