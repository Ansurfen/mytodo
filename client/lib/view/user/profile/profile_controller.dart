// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:get/get.dart';
import 'package:my_todo/api/notification.dart';
import 'package:my_todo/api/user.dart';
import 'package:my_todo/model/user.dart';

class ProfileController extends GetxController {
  late int id;
  // late Rx<User> user;
  Rx<UserProfile> user = UserProfile.random(0).obs;
  RxInt unreadCount = 0.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    id = int.parse(Get.parameters["id"]!);
    user.value = UserProfile.fromJson(await userFriendGet(friend: id));
    notificationUnreadCountRequest().then((res) {
      unreadCount.value = res ?? 0;
    });
  }

  void follow() {}
}
