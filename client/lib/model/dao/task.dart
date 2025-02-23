// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:my_todo/model/entity/task.dart';
import 'package:my_todo/utils/db.dart';

class TaskDao {
  static const String tableName = "task";

  static Future<int> create(Task t) async {
    return await DBProvider.db.insert(tableName, t.toJson());
  }

  static Future<Row?> findOne() async {
    Rows rows = await DBProvider.db.query(tableName);
    if (rows.isNotEmpty) {
      return rows[0];
    }
    return null;
  }

  static Future<List<Task>> findMany() async {
    List<Task> tasks = [];
    Rows rows = await DBProvider.db.query(tableName);
    for (Row row in rows) {
      tasks.add(Task.fromJson(row));
    }
    return tasks;
  }

  static Future<int> deleteAll() async {
    return await DBProvider.db.delete(tableName);
  }
}
