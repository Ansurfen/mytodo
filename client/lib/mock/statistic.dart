// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:my_todo/api/task.dart';
import 'package:my_todo/mock/provider.dart';

final TaskDashboardStats statisticTableData = () {
  int recycleFinishedCount = Mock.number(max: 10000);
  int scheduleFinishedCount = Mock.number(max: 10000);
  int generalFinishedCount = Mock.number(max: 10000);
  return TaskDashboardStats(
    completed: Mock.number(),
    overdue: Mock.number(),
    inProgress: Mock.number(),
    dailyFinished: recycleFinishedCount,
    dailyTotal: recycleFinishedCount + Mock.number(max: 10000),
    monthlyFinished: scheduleFinishedCount,
    monthlyTotal: scheduleFinishedCount + Mock.number(max: 10000),
    yearlyFinished: generalFinishedCount,
    yearlyTotal: generalFinishedCount + Mock.number(max: 10000),
  );
}();
