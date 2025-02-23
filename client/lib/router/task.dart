// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:get/get.dart';
import 'package:my_todo/view/task/detail/task_detail_binding.dart';
import 'package:my_todo/view/task/detail/task_detail_page.dart';

class TaskRouter {
  static List<GetPage> pages = [detail];

  static final detail = GetPage(
      name: '/detail',
      page: () => const TaskInfoPage(),
      binding: TaskInfoBinding());
}
