// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_todo/api/chat.dart';
import 'package:my_todo/model/user.dart';
import 'package:my_todo/utils/guard.dart';

class ChatController extends GetxController with GetTickerProviderStateMixin {
  late TabController tabController;
  late final AnimationController animationController;
  List<Chatsnapshot> allItems = [];
  RxList<Chatsnapshot> pinnedItems = <Chatsnapshot>[].obs;
  RxList<Chatsnapshot> filteredSnapItems = <Chatsnapshot>[].obs;

  String searchQuery = "";
  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    Future.delayed(Duration.zero, () {
      if (Guard.isDevMode()) {
        allItems = Chatsnapshot.randomList();
        updateFilteredList("");
      } else {
        chatSnapshotRequest().then((res) {
          // data.value = res.data;
        });
      }
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      animationController.forward();
    });
  }

  void updateFilteredList(String query) {
    filteredSnapItems.value =
        allItems
            .where(
              (item) =>
                  !pinnedItems.contains(item) &&
                  item.name.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
  }

  void removeItem(Chatsnapshot item) {
    if (pinnedItems.contains(item)) {
      pinnedItems.remove(item);
    } else {
      allItems.remove(item);
      filteredSnapItems.remove(item);
    }
    updateFilteredList(searchQuery);
  }
}
