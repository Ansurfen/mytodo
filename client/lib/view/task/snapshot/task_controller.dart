// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_todo/api/task.dart';
import 'package:my_todo/model/dto/task.dart';
import 'package:my_todo/utils/debounce.dart';
import 'package:my_todo/utils/pagination.dart';

class TaskController extends GetxController with GetTickerProviderStateMixin {
  late final AnimationController animationController;
  Animation<double>? topBarAnimation;
  Rx<Map<int, GetTaskDto>> tasks = Rx({});
  Pagination<GetTaskDto> pagination = Pagination();
  Rx<bool> showMask = false.obs;
  late Future<bool> getData;

  @override
  void onInit() {
    getData = doOnce(_getData)();
    animationController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    topBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: animationController,
            curve: const Interval(0, 0.5, curve: Curves.fastOutSlowIn)));
    super.onInit();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  Future loadTask() {
    // page++;
    pagination.inc();
    return _fetch();
  }

  Future refreshTask() {
    // page = 1;
    pagination.setIndex(1);
    // listViews.clear();
    return _fetch();
  }

  Future _fetch() {
    return getTask(GetTaskRequest(pagination.index(), pagination.getLimit()))
        .then((res) {
      for (var task in res.tasks) {
        tasks.value[task.id] = task;
      }
    }).onError((error, stackTrace) {});
  }

  Future<bool> _getData() async {
    await refreshTask();
    return true;
  }
}
