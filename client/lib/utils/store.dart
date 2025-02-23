// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'dart:collection';
import 'dart:convert';

import 'package:universal_html/html.dart' as html;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef Storage = SharedPreferences;

class SessionStorage implements Storage {
  late final Map<String, String> _data;

  SessionStorage() : _data = kIsWeb ? html.window.sessionStorage : HashMap();

  @override
  Future<bool> clear() async {
    _data.clear();
    return true;
  }

  @override
  Future<bool> commit() async {
    return true;
  }

  @override
  bool containsKey(String key) {
    return _data.containsKey(key);
  }

  @override
  Object? get(String key) {
    try {
      return jsonDecode(_data[key]!);
    } catch (e) {
      return null;
    }
  }

  @override
  bool? getBool(String key) {
    try {
      return jsonDecode(_data[key]!);
    } catch (e) {
      return null;
    }
  }

  @override
  double? getDouble(String key) {
    try {
      return jsonDecode(_data[key]!);
    } catch (e) {
      return null;
    }
  }

  @override
  int? getInt(String key) {
    try {
      return jsonDecode(_data[key]!);
    } catch (e) {
      return null;
    }
  }

  @override
  Set<String> getKeys() {
    return _data.keys.toSet();
  }

  @override
  String? getString(String key) {
    try {
      return jsonDecode(_data[key]!);
    } catch (e) {
      return null;
    }
  }

  @override
  List<String>? getStringList(String key) {
    try {
      return jsonDecode(_data[key]!);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> reload() {
    // TODO: implement reload
    throw UnimplementedError();
  }

  @override
  Future<bool> remove(String key) async {
    _data.remove(key);
    return true;
  }

  @override
  Future<bool> setBool(String key, bool value) {
    _data[key] = jsonEncode(value);
    return Future.value(true);
  }

  @override
  Future<bool> setDouble(String key, double value) {
    _data[key] = jsonEncode(value);
    return Future.value(true);
  }

  @override
  Future<bool> setInt(String key, int value) {
    _data[key] = jsonEncode(value);
    return Future.value(true);
  }

  @override
  Future<bool> setString(String key, String value) {
    _data[key] = jsonEncode(value);
    return Future.value(true);
  }

  @override
  Future<bool> setStringList(String key, List<String> value) {
    _data[key] = jsonEncode(value);
    return Future.value(true);
  }
}

class Store {
  static late Storage localStorage;
  static late SessionStorage sessionStorage;

  Store();

  static Future<void> init() async {
    sessionStorage = SessionStorage();
    localStorage = await SharedPreferences.getInstance();
  }
}
