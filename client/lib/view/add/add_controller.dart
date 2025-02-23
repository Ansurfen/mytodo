// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:my_todo/api/task.dart';
import 'package:my_todo/api/topic.dart';
import 'package:my_todo/model/entity/task.dart';
import 'package:my_todo/view/add/popular_filter_list.dart';
import 'package:my_todo/view/map/select/place.dart';

class AddController extends GetxController {
  bool sync = false;
  List<DropdownMenuItem<int>> topics = [];
  int? selectedTopic;
  late TabController tabController;
  Rx<bool> activeLocale = Rx(false);
  Rx<bool> activeFileUpload = Rx(false);
  Rx<bool> activeContent = Rx(false);
  bool activeImage = false;
  bool activeHand = false;
  bool activeTimer = false;
  bool activeQR = false;
  late List<TaskConditionModel> taskConditions;
  Rx<List<Place>> pos = Rx([]);
  TextEditingController departureController = TextEditingController();
  TextEditingController arrivalController = TextEditingController();
  TextEditingController sendController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController descController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    taskConditions = [
      TaskConditionModel(
          text: "手动签到",
          onTap: (v) {
            activeHand = v;
          }),
      TaskConditionModel(
          text: "定时签到",
          onTap: (v) {
            activeTimer = v;
          }),
      TaskConditionModel(
          text: "位置定位",
          onTap: (v) {
            activeLocale.value = v;
          }),
      TaskConditionModel(
          text: "文件上传",
          onTap: (v) {
            activeFileUpload.value = v;
          }),
      TaskConditionModel(
          text: "图片上传",
          onTap: (v) {
            activeImage = v;
          }),
      TaskConditionModel(
          text: "文字内容",
          onTap: (v) {
            activeContent.value = v;
          }),
      TaskConditionModel(
          text: "扫码签到",
          onTap: (v) {
            activeQR = v;
          }),
    ];
    Future.delayed(Duration.zero, () async {
      GetTopicResponse res = await getTopic(GetTopicRequest());
      for (var topic in res.topics) {
        topics.add(DropdownMenuItem(value: topic.id, child: Text(topic.name)));
      }
    });
  }

  void confirm() {
    List<TaskCondition> conds = [];
    for (var e in pos.value) {
      conds.add(TaskCondition(TaskCondType.locale.index, "${e.lat},${e.lng}"));
    }
    if (activeTimer) {
      conds.add(TaskCondition(TaskCondType.timer.index, ""));
    }
    if (activeHand) {
      conds.add(TaskCondition(TaskCondType.hand.index, ""));
    }
    if (activeContent.value) {
      conds.add(TaskCondition(TaskCondType.content.index, ""));
    }
    if (activeFileUpload.value) {
      conds.add(TaskCondition(TaskCondType.file.index, ""));
    }
    if (activeImage) {
      conds.add(TaskCondition(TaskCondType.image.index, ""));
    }
    if (activeQR) {
      conds.add(TaskCondition(TaskCondType.qr.index, ""));
    }
    createTask(CreateTaskRequest(
            selectedTopic!,
            nameController.text,
            descController.text,
            DateTime.parse(departureController.text),
            DateTime.parse(arrivalController.text),
            conds))
        .then((value) => EasyLoading.showSuccess("Creates task successfully."))
        .onError((error, stackTrace) {});
  }
}
