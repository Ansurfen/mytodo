// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:get/get.dart';
import 'package:my_todo/api/topic.dart';
import 'package:my_todo/model/entity/topic.dart';
import 'package:my_todo/utils/guard.dart';

class TopicMemberController extends GetxController {
  late int id;
  Rx<List<TopicMember>> members = Rx([]);

  @override
  void onInit() {
    super.onInit();
    id = int.parse(Get.parameters["id"]!);
    if (Guard.isDevMode()) {
      members.value.add(TopicMember(id: 1, name: "abc"));
    } else {
      getSubscribedMember(GetSubscribedMemberRequest(id: id)).then((res) {
        members.value = res.members;
        members.refresh();
      });
    }
  }
}
