// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:get/get.dart';
import 'package:my_todo/view/home/component/home_drawer.dart';

import 'package:my_todo/view/home/home_controller.dart';
import 'package:my_todo/view/home/nav/navigator_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => TodoDrawerController(DrawerIndex.nav));
  }
}

class HomeNavBinding extends HomeBinding {
  @override
  void dependencies() {
    super.dependencies();
    Get.lazyPut(() => NavigatorController());
  }
}
