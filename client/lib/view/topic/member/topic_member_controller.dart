// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:get/get.dart';
import 'package:my_todo/api/topic.dart';
import 'package:my_todo/model/entity/topic.dart';

class TopicMemberController extends GetxController {
  late int id;
  Rx<List<TopicMember>> members = Rx([]);

  @override
  void onInit() {
    super.onInit();
    id = int.parse(Get.parameters["id"]!);
    topicMemberGetRequest(id: id).then((v) {
      for (var e in v) {
        members.value.add(TopicMember.fromJson(e));
      }
      members.refresh();
    });
  }
}
