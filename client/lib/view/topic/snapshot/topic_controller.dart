// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_todo/api/topic.dart';
import 'package:my_todo/hook/topic.dart';
import 'package:my_todo/model/dto/topic.dart';
import 'package:my_todo/model/entity/topic.dart';
import 'package:my_todo/utils/dialog.dart';
import 'package:my_todo/utils/guard.dart';

class TopicSnapshotController extends GetxController
    with GetTickerProviderStateMixin {
  late StreamSubscription<GetTopicDto> _uploadTopic;
  late TabController tabController;
  late final AnimationController animationController;
  TextEditingController inviteCode = TextEditingController();

  RxList<Topic> topics = <Topic>[].obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(vsync: this, initialIndex: 0, length: 2);
    if (Guard.isDevMode()) {
    } else {
      _uploadTopic = TopicHook.subscribeSnapshot(onData: (topic) {});
    }

    animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    Future.delayed(Duration.zero, () async {
      fetchTopicMe();
    });
    tabController.addListener(() {
      if (tabController.indexIsChanging) {
        if (tabController.index == 0) {
          fetchTopicMe();
        } else {}
      }
    });
  }

  @override
  void dispose() {
    _uploadTopic.cancel();
    super.dispose();
  }

  Future freshTopic() async {
    animationController.forward();
  }

  void addTopic(BuildContext context, {required Function setState}) {
    showSingleTextField(
      context,
      title: 'invite_code'.tr,
      hintText: "invite_code_tip".tr,
      controller: inviteCode,
      onCancel: Get.back,
      onConfirm: () {
        subscribeTopic(SubscribeTopicRequest(code: inviteCode.text)).then((
          value,
        ) {
          setState(() {});
        });
        inviteCode.text = "";
        Get.back();
      },
    );
  }

  void fetchTopicMe() {
    topicGetRequest().then((v) {
      for (var e in v) {
        topics.add(Topic.fromJson(e));
      }
      Guard.log.i(topics);
    });
  }

  void fetchTopicFind() {}
}
