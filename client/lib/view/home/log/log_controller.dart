// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:my_todo/utils/file.dart';
import 'dart:io';
import 'package:universal_html/html.dart' as html;
import 'package:my_todo/utils/io/dir.dart';
import 'package:my_todo/utils/permission.dart';
import 'package:permission_handler/permission_handler.dart';

class LogController extends GetxController {
  Rx<String> content = "".obs;

  @override
  void onInit() {
    super.onInit();
    Future.delayed(const Duration(seconds: 0), reload);
  }

  Future reload() async {
    final dir = await getApplicationCacheDirectory();
    late File file;
    if (!kIsWeb) {
      file = File("${dir.path}/logs.txt");
    } else {
      file = RWFile("${dir.path}/logs.txt");
    }
    content.value = await file.readAsString();
  }

  Future download(BuildContext context) async {
    String filename =
        "todo_log_${DateFormat("yyyy_MM_dd_HH_mm_ss").format(DateTime.now()).toString()}.txt";
    if (kIsWeb) {
      final file = html.Blob([content], 'text/plain');
      var url = html.Url.createObjectUrl(file);
      final anchor = html.AnchorElement(href: url);
      anchor.download = filename;
      final event = html.MouseEvent('click',
          view: html.window, canBubble: true, cancelable: true);
      anchor.dispatchEvent(event);
      html.Url.revokeObjectUrl(url);
    } else {
      String? result = await FilePicker.platform.getDirectoryPath();
      if (result != null) {
        File file = File("$result/$filename");
        if (context.mounted) {
          grantPermission(context, Permission.storage).then((ok) {
            if (ok) {
              file.create(recursive: true).then((value) {
                file.writeAsString(content.value);
              });
            }
          });
        }
      }
    }
  }
}
