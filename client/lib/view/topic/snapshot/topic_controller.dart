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

  RxList<Topic> topicMe = <Topic>[].obs;
  RxList<TopicFind> topicFind = <TopicFind>[].obs;

  int topicFindTotal = 0;
  int topicFindPage = 1;
  int topicFindPageSize = 10;

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
        } else {
          fetchTopicFind();
        }
      }
    });
  }

  @override
  void dispose() {
    _uploadTopic.cancel();
    super.dispose();
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
    topicMe.clear();
    topicGetRequest().then((v) {
      if (v != null) {
        for (var e in v) {
          topicMe.add(Topic.fromJson(e));
        }
      }
    });
  }

  void fetchTopicFind() {
    topicFind.clear();
    topicFindTotal = 0;
    topicFindPage = 1;
    topicFindPageSize = 10;
    topicFindRequest(page: topicFindPage, pageSize: topicFindPageSize).then((
      v,
    ) {
      for (var e in v["topic"]) {
        topicFind.add(TopicFind.fromJson(e));
      }
      topicFindTotal = v["total"];
    });
  }

  void loadTopicFind() {
    if (topicFindPageSize * topicFindPageSize > topicFindTotal) {
      return;
    }
    topicFindPage++;
    topicFindRequest(page: topicFindPage, pageSize: topicFindPageSize).then((
      v,
    ) {
      for (var e in v["topic"]) {
        topicFind.add(TopicFind.fromJson(e));
      }
      topicFindTotal = v["total"];
    });
  }
}

class TopicFind extends Topic {
  late int memberCount;

  TopicFind(
    super.icon,
    super.id,
    super.creator,
    super.name,
    super.description,
    super.tags,
    super.inviteCode,
    this.memberCount,
  );

  static TopicFind fromJson(Map<String, dynamic> json) {
    final parent = Topic.fromJson(json);
    return TopicFind(
      parent.icon,
      parent.id,
      parent.creator,
      parent.name,
      parent.description,
      parent.tags,
      parent.inviteCode,
      json['member_count'],
    );
  }
}
