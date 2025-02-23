// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/foundation.dart';
import 'package:my_todo/view/home/component/home_drawer.dart';
import 'package:my_todo/view/home/home_controller.dart';

class FeedbackController extends TodoDrawerController {
  FeedbackController() : super(DrawerIndex.feedback);

  @override
  void onInit() {
    super.onInit();
    if (kDebugMode) {
      print("feedback_controller init");
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (kDebugMode) {
      print("feedback_controller dispose");
    }
  }
}
