// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.

import 'package:flutter/services.dart';

class TodoClipboard {
  static Future<void> set(String data) async {
    return Clipboard.setData(ClipboardData(text: data));
  }

  static Future<String?> get(String format) async {
    final ClipboardData? data = await Clipboard.getData(format);
    return data?.text;
  }
}
