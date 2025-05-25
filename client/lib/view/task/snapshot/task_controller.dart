// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_todo/api/notification.dart';
import 'package:my_todo/api/task.dart';
import 'package:my_todo/utils/debounce.dart';
import 'package:my_todo/utils/pagination.dart';
import 'package:my_todo/view/task/snapshot/task_card.dart';

class TaskController extends GetxController with GetTickerProviderStateMixin {
  late final AnimationController animationController;
  Animation<double>? topBarAnimation;
  RxList<TaskCardModel> tasks = <TaskCardModel>[].obs;
  RxList<TaskCardModel> filteredTasks = <TaskCardModel>[].obs;
  Pagination<TaskCardModel> pagination = Pagination();
  Rx<bool> showMask = false.obs;
  late Future<bool> getData;
  Rx<TaskDashboardStats> stats =
      TaskDashboardStats(
        completed: 0,
        overdue: 0,
        inProgress: 0,
        dailyFinished: 0,
        dailyTotal: 0,
        monthlyFinished: 0,
        monthlyTotal: 0,
        yearlyFinished: 0,
        yearlyTotal: 0,
      ).obs;
  RxInt unreadCount = 0.obs;

  // 添加过滤条件
  Rx<bool> filterFinish = false.obs;
  Rx<bool> filterTimeout = false.obs;
  Rx<bool> filterRunning = false.obs;
  Rx<DateTime?> startDate = Rx<DateTime?>(null);
  Rx<DateTime?> endDate = Rx<DateTime?>(null);
  Rx<String> searchQuery = ''.obs;

  void applyFilters() {
    // 如果没有激活任何过滤条件，显示所有任务
    if (searchQuery.value.isEmpty &&
        startDate.value == null &&
        endDate.value == null &&
        !filterFinish.value &&
        !filterTimeout.value &&
        !filterRunning.value) {
      filteredTasks.value = List.from(tasks);
      return;
    }

    filteredTasks.value =
        tasks.where((task) {
          // 搜索过滤
          if (searchQuery.value.isNotEmpty) {
            if (!task.name.toLowerCase().contains(
                  searchQuery.value.toLowerCase(),
                ) &&
                !task.description.toLowerCase().contains(
                  searchQuery.value.toLowerCase(),
                )) {
              return false;
            }
          }

          // 日期过滤
          if (startDate.value != null && endDate.value != null) {
            if (task.startAt.isBefore(startDate.value!) ||
                task.endAt.isAfter(endDate.value!)) {
              return false;
            }
          }

          // 状态过滤
          bool isFinished = task.cond.every((cond) => cond.finish);
          bool isOverdue = task.endAt.isBefore(DateTime.now()) && !isFinished;
          bool isRunning = !isFinished && !isOverdue;

          if (filterFinish.value && !isFinished) return false;
          if (filterTimeout.value && !isOverdue) return false;
          if (filterRunning.value && !isRunning) return false;

          return true;
        }).toList();
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  void clearFilters() {
    searchQuery.value = '';
    startDate.value = null;
    endDate.value = null;
    filterFinish.value = false;
    filterTimeout.value = false;
    filterRunning.value = false;
    applyFilters();
  }

  void closeFilter() {
    showMask.value = false;
  }

  void setDateRange(DateTime? start, DateTime? end) {
    startDate.value = start;
    endDate.value = end;
    applyFilters();
  }

  void toggleFilterFinish(bool value) {
    filterFinish.value = value;
    applyFilters();
  }

  void toggleFilterTimeout(bool value) {
    filterTimeout.value = value;
    applyFilters();
  }

  void toggleFilterRunning(bool value) {
    filterRunning.value = value;
    applyFilters();
  }

  @override
  void onInit() {
    getData = doOnce(_getData)();
    animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    topBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(0, 0.5, curve: Curves.fastOutSlowIn),
      ),
    );
    super.onInit();
    Future.delayed(const Duration(milliseconds: 100), () {
      taskDashboard().then((v) {
        stats.value = v;
      });
      notificationUnreadCountRequest().then((res) {
        unreadCount.value = res ?? 0;
      });
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  void loadTask() {}

  Future refreshTask() {
    pagination.setIndex(1);
    tasks.clear();
    return _fetch();
  }

  Future _fetch() async {
    return taskGetRequest(
      page: pagination.index(),
      limit: pagination.getLimit(),
    ).then((v) {
      for (var e in v) {
        final conds = <ConditionItem>[];
        if (e["conds"] != null) {
          for (var elem in (e["conds"] as List)) {
            conds.add(
              ConditionItem(
                id: elem["want"]["id"],
                type: ConditionType.values[elem["want"]["type"]],
                finish: elem["valid"],
                argument: elem["got"] != null ? elem["got"]["argument"] : {},
              ),
            );
          }
        }
        tasks.add(
          TaskCardModel(
            (e['id'] as num).toInt(),
            e['icon'] as String,
            e['name'] as String,
            e['description'] as String,
            conds,
            DateTime.parse(e["start_at"]),
            DateTime.parse(e["end_at"]),
          ),
        );
      }
      // 初始化时，将原始数据复制到过滤列表中
      filteredTasks.value = List.from(tasks);
    });
  }

  Future<bool> _getData() async {
    await refreshTask();
    return true;
  }
}
