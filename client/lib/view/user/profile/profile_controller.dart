// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:get/get.dart';
import 'package:my_todo/api/user.dart';
import 'package:my_todo/model/entity/user.dart';
import 'package:my_todo/model/user.dart';
import 'package:my_todo/utils/guard.dart';

class ProfileController extends GetxController {
  late int id;
  // late Rx<User> user;
  late Rx<UserProfile> user;

  @override
  void onInit() {
    super.onInit();
    id = int.parse(Get.parameters["id"]!);

    if (Guard.isDevMode()) {
      user = UserProfile.random(id).obs;
    } else {
      //  user = User(id, "", "").obs;
      // Future.delayed(Duration.zero, () {
      //   userInfo(id).then((u) => user.value = u);
      // });
    }
  }

  void follow() {}
}
