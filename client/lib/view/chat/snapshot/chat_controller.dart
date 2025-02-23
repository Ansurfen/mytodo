// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_todo/api/chat.dart';
import 'package:my_todo/model/dto/chat.dart';

class ChatController extends GetxController with GetTickerProviderStateMixin {
  late TabController tabController;
  late final AnimationController animationController;
  Rx<List<ChatSnapshotDTO>> data = Rx([]);

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    animationController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    Future.delayed(Duration.zero, () {
      chatSnapshot().then((res) {
        data.value = res.data;
      });
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      animationController.forward();
    });
  }
}
