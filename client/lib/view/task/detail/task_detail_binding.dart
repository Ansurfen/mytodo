// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:get/get.dart';
import 'package:my_todo/view/task/detail/task_detail_controller.dart';

class TaskInfoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TaskInfoController>(() => TaskInfoController());
  }
}
