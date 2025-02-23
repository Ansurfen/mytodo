// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:my_todo/component/tabIcon/tabIcon_data.dart';
import 'package:my_todo/view/chat/snapshot/chat_controller.dart';
import 'package:my_todo/view/chat/snapshot/chat_page.dart';
import 'package:my_todo/view/post/snapshot/post_page.dart';
import 'package:my_todo/view/post/snapshot/post_snapshot_controller.dart';
import 'package:my_todo/view/task/snapshot/task_controller.dart';
import 'package:my_todo/view/task/snapshot/task_page.dart';
import 'package:my_todo/view/topic/snapshot/topic_controller.dart';
import 'package:my_todo/view/topic/snapshot/topic_page.dart';

class CachedWidgetBuilder {
  Widget? widget;
  Widget Function() builder;

  CachedWidgetBuilder(this.builder);

  Widget init() {
    return widget ??= builder();
  }

  void destroy() {
    if (widget != null) {
      widget = null;
    }
  }
}

class CachedWidgetBuilderList extends ListMixin<CachedWidgetBuilder> {
  late final List<CachedWidgetBuilder> _list;

  CachedWidgetBuilderList(List<Widget Function()> builders) {
    _list = builders.map((e) => CachedWidgetBuilder(e)).toList();
  }

  @override
  int get length => _list.length;

  @override
  set length(int newLength) {
    _list.length = newLength;
  }

  @override
  CachedWidgetBuilder operator [](int index) {
    final builder = _list[index];
    return builder..init();
  }

  @override
  void operator []=(int index, CachedWidgetBuilder value) {
    _list[index] = value;
  }
}

class NavigatorController extends GetxController
    with GetTickerProviderStateMixin {
  late AnimationController animationController;
  final List<TabIconData> tabIconsList = TabIconData.tabIconsList;
  bool multiple = true;
  late PageController pageController;

  static List<Widget> pages = [
    const TaskPage(),
    const TopicSnapshotPage(),
    const ChatPage(),
    const PostSnapshotPage(),
  ];

  @override
  void onInit() {
    super.onInit();
    for (var tab in tabIconsList) {
      tab.isSelected = false;
    }
    int index = 0;
    pageController = PageController();
    tabIconsList[index].isSelected = true;
    animationController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  void switchPage(int index) {
    animationController.reverse().then((value) {
      if (Get.context != null) {
        switch (index) {
          case 0:
            Get.lazyPut(() => TaskController());
            break;
          case 1:
            Get.lazyPut(() => TopicSnapshotController());
            break;
          case 2:
            Get.lazyPut(() => ChatController());
            break;
          case 3:
            Get.lazyPut(() => PostSnapshotController());
            break;
          default:
            return;
        }
        pageController.jumpToPage(index);
      }
    });
  }
}
