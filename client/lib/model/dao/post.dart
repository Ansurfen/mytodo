// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:my_todo/model/entity/post.dart';
import 'package:my_todo/utils/db.dart';

class PostDao {
  static const String tableName = "post";

  static Future<int> create(Post c) async {
    return await DBProvider.db.insert(tableName, c.toJson());
  }

  static Future<Row?> findOne() async {
    Rows rows = await DBProvider.db.query(tableName);
    if (rows.isNotEmpty) {
      return rows[0];
    }
    return null;
  }

  static Future<List<Post>> findMany() async {
    List<Post> communities = [];
    Rows rows = await DBProvider.db.query(tableName);
    for (Row row in rows) {
      communities.add(Post(row["id"] as int, row["content"] as String,
          row["created_at"] as int, row["deleted_at"] as int, []));
    }
    return communities;
  }

  static Future<int> deleteAll() async {
    return await DBProvider.db.delete(tableName);
  }
}
