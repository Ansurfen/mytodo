// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:my_todo/model/dto/topic.dart';
import 'package:my_todo/model/user.dart';
import 'package:my_todo/router/home.dart';
import 'package:my_todo/router/map.dart';
import 'package:my_todo/router/other.dart';
import 'package:my_todo/router/task.dart';
import 'package:my_todo/router/topic.dart';
import 'package:my_todo/router/user.dart';
import 'package:my_todo/utils/guard.dart';
import 'package:my_todo/view/page_not_found/page_not_found.dart';
import 'package:my_todo/view/task/snapshot/task_card.dart';

typedef TodoPage = GetPage<dynamic>;

class RouterProvider {
  static List<TodoPage> pages = [
    ...UserRouter.pages,
    ...OtherRouter.pages,
    ...TopicRouter.pages,
    ...MapRouter.pages,
    ...HomeRouter.pages,
    ...TaskRouter.pages,
  ];

  static void back({TodoPage? failPage}) {
    if (kIsWeb) {
      Get.offNamed(failPage!.name);
      return;
    }
    Get.back();
  }

  static Future<T?>? offNamed<T>(
    TodoPage page, {
    String query = "",
    dynamic arguments,
  }) {
    return Get.offNamed("${page.name}$query", arguments: arguments);
  }

  static Future<T?>? to<T>(
    TodoPage page, {
    String query = "",
    dynamic arguments,
  }) {
    return Get.toNamed("${page.name}$query", arguments: arguments);
  }

  static String initialRoute() {
    // return UserRouter.edit.name;
    return HomeRouter.nav.name;
    // return OtherRouter.statistic.name;
    // return MapRouter.locate.name;
    if (Guard.isLogin() || Guard.isOffline()) {
      return HomeRouter.nav.name;
    }
    if (!Guard.isFirstVisit() && !Guard.isLogin()) {
      return UserRouter.sign.name;
    }
    return OtherRouter.splash.name;
  }

  static void viewNotification() {
    to(OtherRouter.notification);
  }

  static Future? viewSetting() {
    return to(OtherRouter.setting);
  }

  static void toUserProfile(int id) {
    to(UserRouter.profile, query: "?id=$id");
  }

  static void viewUserForget() {
    to(UserRouter.forget);
  }

  static void viewUserLicense() {
    to(UserRouter.license);
  }

  static void viewChatConversation(Chatsnapshot chatsnapshot) {
    to(
      OtherRouter.conversation,
      query: "?id=${chatsnapshot.id}",
      arguments: chatsnapshot,
    );
  }

  static void viewUserEdit() {
    to(UserRouter.edit);
  }

  static void viewAdd() {
    to(OtherRouter.add);
  }

  static void toStatistic() {
    to(OtherRouter.statistic);
  }

  static void toPostDetail(int id) {
    to(OtherRouter.post, query: "?id=$id");
  }

  static void toTaskDetail(int id, List<ConditionItem> conds) {
    to(TaskRouter.detail, query: "?id=$id", arguments: conds);
  }

  static void toUserSign() {
    offNamed(UserRouter.sign);
  }

  static Future? toMapSelect() {
    return to(MapRouter.select);
  }

  static Future? toMapLocate() {
    return to(MapRouter.locate);
  }

  static void toPhoto({required PhotoType type, required String url}) {
    switch (type) {
      case PhotoType.svg:
        to(OtherRouter.photo, query: "?type=svg&url=$url");
      case PhotoType.img:
        to(OtherRouter.photo, query: "?type=img&url=$url");
    }
  }

  static void viewTopicMember(int id) {
    to(TopicRouter.member, query: "?id=$id");
  }

  static void viewTopicInvite() {
    to(TopicRouter.invite);
  }

  static void viewTopicDetail(int id, GetTopicDto model) {
    to(TopicRouter.detail, query: "?id=$id", arguments: model);
  }

  static void viewLog() {
    to(OtherRouter.log);
  }

  static final TodoPage notFoundPage = GetPage(
    name: '/404',
    page: () => const PageNotFound(),
  );
}

enum PhotoType { svg, img }
