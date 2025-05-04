// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:get/get.dart';
import 'package:my_todo/api/notification.dart';
import 'package:my_todo/api/task.dart';
import 'package:my_todo/api/topic.dart';
import 'package:my_todo/model/entity/topic.dart';
import 'package:my_todo/model/topic.dart';
import 'package:my_todo/utils/guard.dart';

class TopicMemberController extends GetxController {
  late int id;
  Rx<List<TopicMember>> members = Rx([]);
  RxInt unreadCount = 0.obs;
  Rx<TopicRole> role = TopicRole.member.obs;
  @override
  void onInit() {
    super.onInit();
    id = int.parse(Get.parameters["id"]!);
    topicPermissionRequest(topicId: id).then((v) {
      role.value = v;
    });
    topicMemberGetRequest(id: id).then((v) {
      for (var e in v) {
        members.value.add(TopicMember.fromJson(e));
      }
      members.refresh();
    });
    notificationUnreadCountRequest().then((res) {
      unreadCount.value = res ?? 0;
    });
  }

  void fetchMembers() {
    topicMemberGetRequest(id: id).then((v) {
      members.value.clear();
      for (var e in v) {
        members.value.add(TopicMember.fromJson(e));
      }
      members.refresh();
    });
  }
}
