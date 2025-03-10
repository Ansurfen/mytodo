// Copyright 2025 The mytodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:get/get.dart';
import 'package:my_todo/view/chat/conversation/conversion_controller.dart';

class ConversionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ConversionController());
  }
}
