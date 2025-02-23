// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/cupertino.dart';

import 'package:get/get.dart';
import 'package:my_todo/view/home/about/about_page.dart';
import 'package:my_todo/view/home/component/home_drawer.dart';
import 'package:my_todo/view/home/feedback/feedback_page.dart';
import 'package:my_todo/view/home/mine/mine_page.dart';
import 'package:my_todo/view/home/log/log_controller.dart';
import 'package:my_todo/view/home/log/log_page.dart';

import 'package:my_todo/view/task/snapshot/task_controller.dart';
import 'package:my_todo/view/home/nav/component/bottom_bar_controller.dart';
import 'package:my_todo/view/home/nav/navigator_controller.dart';
import 'package:my_todo/view/home/nav/navigator_page.dart';

class TodoDrawerController extends GetxController {
  late Widget? subPage;
  late DrawerIndex? drawerIndex;

  TodoDrawerController(this.drawerIndex);

  Widget currentSubPage() {
    if (drawerIndex == null) {
      return const Text("error");
    } else {
      switch (drawerIndex) {
        case DrawerIndex.nav:
          Get.lazyPut(() => NavigatorController());
          Get.lazyPut(() => BottomBarController());
          Get.lazyPut(() => TaskController());
          return const NavigatorPage();
        case DrawerIndex.feedback:
          return const FeedbackPage();
        case DrawerIndex.invite:
          return const MePage();
        case DrawerIndex.about:
          return const AboutPage();
        case DrawerIndex.log:
          Get.lazyPut(() => LogController());
          return const LogPage();
        default:
          return const Text("error");
      }
    }
  }
}
