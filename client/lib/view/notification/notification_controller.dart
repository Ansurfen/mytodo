// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/animation.dart';
import 'package:get/get.dart';
import 'package:my_todo/api/notify.dart';
import 'package:my_todo/mock/provider.dart';
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
      notifications.addAll([
        Notify(
          id: 1,
          type: 1,
          status: 0,
          createdAt: DateTime.now(),
          title: Mock.username(),
          content: Mock.text(),
        ),
        Notify(
          id: 1,
          type: 2,
          status: 0,
          createdAt: DateTime.now(),
          title: Mock.username(),
          content: Mock.text(),
        ),
        Notify(
          id: 1,
          type: 3,
          status: 0,
          createdAt: DateTime.now(),
          title: Mock.username(),
          content: Mock.text(),
        ),
      ]);
      animationController.forward();
    } else {
      Future.delayed(const Duration(milliseconds: 100), () {
        animationController.forward();
        notifyAll().then((res) => notifications.value = res.notifications);
      });
    }
  }
}
