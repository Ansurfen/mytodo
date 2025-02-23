// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:my_todo/utils/store.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

typedef Column = String;
typedef Row = Map<Column, Object?>;
typedef Rows = List<Row>;
typedef FieldAttr = int;

const int fieldAttrNotNULL = 1;
const int fieldAttrAutoINCR = 2;

class FieldMeta {
  int attr = 0;
  int cnt = 0;

  int incr() {
    cnt++;
    return cnt;
  }

  bool isIncr() {
    return attr >> 1 == 1;
  }
}

class DB {
  Future<int> delete(String table, {String? where, List<Object?>? whereArgs}) {
    throw UnimplementedError();
  }

  Future close() async {
    throw UnimplementedError();
  }

  Future execute(String sql, [List<Object?>? arguments]) async {
    throw UnimplementedError();
  }

  Future<int> insert(String table, Row values,
      {String? nullColumnHack, dynamic conflictAlgorithm}) async {
    throw UnimplementedError();
  }

  Future<List<Row>> query(String table,
      {bool? distinct,
      List<String>? columns,
      String? where,
      List<Object?>? whereArgs,
      String? groupBy,
      String? having,
      String? orderBy,
      int? limit,
      int? offset}) async {
    throw UnimplementedError();
  }

  Future<int> update(String table, Row values,
      {String? where,
      List<Object?>? whereArgs,
      dynamic conflictAlgorithm}) async {
    throw UnimplementedError();
  }
}

class AppDB implements DB {
  late final Database db;

  AppDB(this.db);

  @override
  Future close() async {
    await db.close();
  }

  @override
  Future<int> delete(String table, {String? where, List<Object?>? whereArgs}) {
    return db.delete(table, where: where, whereArgs: whereArgs);
  }

  @override
  Future execute(String sql, [List<Object?>? arguments]) {
    return db.execute(sql, arguments);
  }

  @override
  Future<int> insert(String table, Row values,
      {String? nullColumnHack, conflictAlgorithm}) {
    return db.insert(table, values);
  }

  @override
  Future<List<Row>> query(String table,
      {bool? distinct,
      List<String>? columns,
      String? where,
      List<Object?>? whereArgs,
      String? groupBy,
      String? having,
      String? orderBy,
      int? limit,
      int? offset}) {
    return db.query(table, where: where, whereArgs: whereArgs);
  }

  @override
  Future<int> update(String table, Row values,
      {String? where, List<Object?>? whereArgs, conflictAlgorithm}) {
    return db.update(table, values, where: where, whereArgs: whereArgs);
  }
}

class WebDB implements DB {
  late final String path;
  static final RegExp _createReg = RegExp(
      r"CREATE * TABLE * IF* NOT * EXISTS* (.*) \(|CREATE *TABLE *(.*) \(");
  static final RegExp _dropReg = RegExp(r"DROP *TABLE *(.*)");
  Map<String, List<Row>> data = HashMap();
  Map<String, Map<String, FieldMeta>> meta = HashMap();

  WebDB(this.path);

  String _join(String tbl) {
    return "$path/$tbl";
  }

  List<String> _parseWhereClause(String clause) {
    List<String> ret = [];
    for (String subClause in clause.toLowerCase().split('and')) {
      ret.add(subClause.splitMapJoin('=',
          onMatch: (Match match) => subClause.substring(0, match.start).trim(),
          onNonMatch: (String nonMatch) => ""));
    }
    return ret;
  }

  @override
  Future close() async {}

  @override
  Future<int> delete(String table,
      {String? where, List<Object?>? whereArgs}) async {
    late List<Column> fields = [];
    if (where != null) {
      fields = _parseWhereClause(where);
    }
    if (fields.isEmpty) {
      data[table]!.clear();
      Store.localStorage.setString(_join(table), jsonEncode(data[table]));
      return 0;
    }
    if (fields.isNotEmpty &&
        whereArgs != null &&
        fields.length != whereArgs.length) {
      throw "";
    }
    for (int j = 0; j < data[table]!.length; j++) {
      Row row = data[table]![j];
      bool selected = true;
      for (int i = 0; i < fields.length; i++) {
        var want = whereArgs![i];
        var column = fields[i];
        if (row[column] != want) {
          selected = false;
          break;
        }
      }
      if (selected) {
        data[table]!.removeAt(j);
      }
    }
    Store.localStorage.setString(_join(table), jsonEncode(data[table]));
    return 0;
  }

  @override
  Future execute(String sql, [List<Object?>? arguments]) async {
    String rawSql =
        sql.trim().replaceAll("\n", " ").replaceAll(RegExp("\\s{2,}"), " ");
    if (_createReg.hasMatch(rawSql)) {
      Iterable<Match> matches = _createReg.allMatches(rawSql);
      for (Match m in matches) {
        String? tbl = m.group(1) ?? m.group(2);
        if ((tbl != null && tbl.isNotEmpty)) {
          if (data[tbl] == null) {
            data[tbl] = [];
          }
          tbl = tbl.toLowerCase().trim();
          if (meta[tbl] == null) {
            meta[tbl] = HashMap();
          }
          String? localData = Store.localStorage.getString(_join(tbl));
          if (localData == null) {
            Store.localStorage.setString(_join(tbl), "[]");
          } else {
            List<dynamic> rows = jsonDecode(localData);
            for (var element in rows) {
              data[tbl]!.add(element as Row);
            }
          }
          int start = rawSql.indexOf("(");
          int end = rawSql.indexOf(")");
          if (start != -1 && end != -1) {
            for (String field in rawSql.substring(start + 1, end).split(",")) {
              Column col = field.trim().split(' ')[0].trim();
              if (meta[tbl]![col] == null) {
                meta[tbl]![col] = FieldMeta();
              }
              meta[tbl]![col]!.attr = 0;
              if (field.contains('AUTOINCREMENT')) {
                int attr = meta[tbl]![col]!.attr | fieldAttrAutoINCR;
                meta[tbl]![col]!.attr = attr;
              }
            }
          }
        }
      }
    } else if (_dropReg.hasMatch(sql)) {
      Iterable<Match> matches = _dropReg.allMatches(sql);
      for (Match m in matches) {
        String? tbl = m.group(1);
        if (tbl != null) {
          tbl = tbl.toLowerCase().trim();
          if (data[tbl] != null) {
            data[tbl]!.clear();
          }
          Store.localStorage.setString(_join(tbl), "");
        }
      }
    }
  }

  @override
  Future<int> insert(String table, Row values,
      {String? nullColumnHack, conflictAlgorithm}) async {
    if (data[table] == null) {
      data[table] = [];
    }
    values.forEach((column, value) {
      try {
        FieldMeta m = meta[table]![column]!;
        if (m.isIncr()) {
          if (value == null) {
            values[column] = m.incr();
          }
        }
      } catch (e) {
        print("unexpected null value in $table.$column");
      }
    });
    data[table]!.add(values);
    table = _join(table);
    var v = Store.localStorage.getString(table);
    if (v == null) {
      // throw "table isn't exist";
      return 0;
    }
    if (v.isEmpty) {
      Store.localStorage.setString(table, "[]");
    }
    if (v.isNotEmpty) {
      if (v == "[]") {
        Store.localStorage.setString(
            table, "${v.substring(0, v.length - 1)}${jsonEncode(values)}]");
      } else {
        Store.localStorage.setString(
            table, "${v.substring(0, v.length - 1)},${jsonEncode(values)}]");
      }
    }
    return 0;
  }

  @override
  Future<List<Row>> query(String table,
      {bool? distinct,
      List<String>? columns,
      String? where,
      List<Object?>? whereArgs,
      String? groupBy,
      String? having,
      String? orderBy,
      int? limit,
      int? offset}) async {
    if (where != null) {
      List<Column> fields = _parseWhereClause(where);
      if (whereArgs != null && fields.length != whereArgs.length) {
        throw "argument not matched";
      }
      List<Row> ret = [];
      for (int i = 0; i < data[table]!.length; i++) {
        Row row = data[table]![i];
        bool selected = true;
        for (int i = 0; i < fields.length; i++) {
          var want = whereArgs![i];
          var column = fields[i];
          if (row[column] != want) {
            selected = false;
            break;
          }
        }
        if (selected) {
          ret.add(row);
        }
      }
      return ret;
    }
    return data[table]!;
  }

  @override
  Future<int> update(String table, Row values,
      {String? where, List<Object?>? whereArgs, conflictAlgorithm}) async {
    List<String>? fields;
    if (where != null) {
      fields = _parseWhereClause(where);
    }
    if (fields != null &&
        whereArgs != null &&
        fields.length != whereArgs.length) {
      return 0;
    }
    for (int j = 0; j < data[table]!.length; j++) {
      Row row = data[table]![j];
      if (fields == null) {
        values.forEach((column, value) {
          data[table]![j][column] = value;
        });
      } else {
        bool selected = true;
        for (int i = 0; i < fields.length; i++) {
          var want = whereArgs![i];
          var column = fields[i];
          if (row[column] != want) {
            selected = false;
            break;
          }
        }
        if (selected) {
          values.forEach((column, value) {
            data[table]![j][column] = value;
          });
        }
      }
    }
    Store.localStorage.setString(_join(table), jsonEncode(data[table]));
    return 0;
  }
}

class User {
  int? id;
  String name;
  int age;
  String email;

  User({this.id, required this.name, required this.age, required this.email});

  User.fromMap(Map<String, dynamic> res)
      : id = res["id"],
        name = res["name"],
        age = res["age"],
        email = res["email"];

  Map<String, Object?> toMap() {
    return {'id': id, 'name': name, 'age': age, 'email': email};
  }
}

Future testWebDB() async {
  DB db = await openDB("user.db", 1);
  db.execute("""
            CREATE TABLE users (
              id INTEGER PRIMARY KEY AUTOINCREMENT, 
              name TEXT NOT NULL,
              age INTEGER NOT NULL, 
              email TEXT NOT NULL
            )
          """);
  User user = User(name: "666", age: 10, email: "");
  await db.insert("users", user.toMap());
  await db.insert("users", user.toMap());
  await db.insert("users", user.toMap());

  db.update("users", {"email": "gmail.com"},
      where: "name = ? and id = ?", whereArgs: [user.name, 1]);
  List<Row> queryResult = await db.query('users');
  print(queryResult);

  db.delete("users", where: "id = ?", whereArgs: [1]);
  // db.delete("users");
  queryResult = await db.query('users');
  print(queryResult);
  queryResult = await db.query('users', where: "id = ?", whereArgs: [2]);
  print(queryResult);
  // print(db.data);
  // print(sessionStorage._data);
  // db.execute("DROP TABLE users");
  // print(db.data);
  // print(sessionStorage._data);
}

Future<DB> openDB(String path, int? version) async {
  if (kIsWeb) {
    return WebDB("/web_db/$path");
  }
  String root = await getDatabasesPath();
  return AppDB(await openDatabase(join(root, path), version: version));
}

class DBProvider {
  static late DB db;
  static const String name = "todo.db";

  static Future init() async {
    db = await openDB(name, 1);
    await db.execute("""
            CREATE TABLE IF NOT EXISTS task (
              id INTEGER PRIMARY KEY AUTOINCREMENT, 
              name TEXT NOT NULL,
              desc TEXT NOT NULL,
              startAt INTEGER NOT NULL, 
              endAt INTEGER NOT NULL
            )""");
    await db.execute("""
            CREATE TABLE IF NOT EXISTS topic (
              id INTEGER PRIMARY KEY AUTOINCREMENT, 
              user INTEGER NOT NULL,
              name TEXT NOT NULL,
              desc TEXT NOT NULL
            )""");
    await db.execute("""
            CREATE TABLE IF NOT EXISTS post (
              id INTEGER PRIMARY KEY AUTOINCREMENT, 
              uid INTEGER NOT NULL,
              content TEXT NOT NULL,
              created_at INTEGER NOT NULL, 
              deleted_at INTEGER NOT NULL,
              image TEXT NOT NULL
            )""");
    // int now = DateTime.now().toUtc().microsecondsSinceEpoch;
    // Task task = Task("task1", "task", now, (now * 1.25) as int);
    //
    // await db.insert("task", task.toMap());
    // await db.insert("task", task.toMap());
    // await db.insert("task", task.toMap());
    //
    // await db.update("task", {"desc": "task2"},
    //     where: "name = ? and id = ?", whereArgs: [task.name, 2]);
    // List<Row> queryResult = await db.query('task');
    // print(queryResult);
    //
    // await db.delete("task", where: "id = ?", whereArgs: [1]);
    // // db.delete("users");
    // queryResult = await db.query('task');
    // print(queryResult);
    // queryResult = await db.query('task');
    // print(queryResult);
    // print(7);
    // List<Task> users = [];
    // queryResult = await db.query('task', where: "id = ?", whereArgs: [2]);
    // for (var res in queryResult) {
    //   print(res);
    //   users.add(Task.fromMap(res));
    // }
    // print(users);
    // queryResult = await db.query('users', where: "id = ?", whereArgs: [2]);
    // print(queryResult);
    // queryResult = await db.query('users', where: "id = ?", whereArgs: [2]);
    // print(queryResult.isEmpty);
    // print(queryResult);
  }
}
