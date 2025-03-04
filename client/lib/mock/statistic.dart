// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:my_todo/mock/provider.dart';
import 'package:my_todo/view/task/component/statistic_table.dart';

final StatisticTableModel statisticTableData = () {
  int recycleFinishedCount = Mock.number(max: 10000);
  int scheduleFinishedCount = Mock.number(max: 10000);
  int generalFinishedCount = Mock.number(max: 10000);
  return StatisticTableModel(
    completed: Mock.number(),
    timeout: Mock.number(),
    running: Mock.number(),
    periodTotalCount: recycleFinishedCount + Mock.number(max: 10000),
    periodFinishedCount: recycleFinishedCount,
    scheduleTotalCount: scheduleFinishedCount + Mock.number(max: 10000),
    scheduleFinishedCount: scheduleFinishedCount,
    generalTotalCount: generalFinishedCount + Mock.number(max: 10000),
    generalFinishedCount: generalFinishedCount,
  );
}();
