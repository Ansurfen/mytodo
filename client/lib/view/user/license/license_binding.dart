// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:get/get.dart';
import 'package:my_todo/view/user/license/license_controller.dart';

class LicenseBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<LicenseController>(LicenseController());
  }
}
