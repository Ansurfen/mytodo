// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:my_todo/component/calendar/calendar.dart';
import 'package:my_todo/component/timeline/event_item.dart';
import 'package:my_todo/model/dto/topic.dart';

class TopicController extends GetxController with GetTickerProviderStateMixin {
  late GetTopicDto model;
  late TabController tabController;
  Rx<DateTime> startDate = DateTime.now().obs;
  Rx<DateTime> endDate = DateTime.now().obs;
  List<TimelineEventDisplay> event = [];

  @override
  void onInit() {
    if (Get.arguments is GetTopicDto) {
      model = Get.arguments;
    } else {
      EasyLoading.showError("invalid topic model");
      Get.back();
    }
    tabController = TabController(length: 2, vsync: this);
    super.onInit();
  }

  void showDemoDialog({BuildContext? context}) {
    showDialog<dynamic>(
      context: context!,
      builder: (BuildContext context) => CalendarPopupView(
        barrierDismissible: true,
        minimumDate: DateTime.now(),
        //  maximumDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + 10),
        initialEndDate: endDate.value,
        initialStartDate: startDate.value,
        onApplyClick: (DateTime startData, DateTime endData) {
          startDate.value = startData;
          endDate.value = endData;
        },
        onCancelClick: () {},
      ),
    );
  }
}
