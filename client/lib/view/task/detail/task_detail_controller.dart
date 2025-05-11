// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'dart:io' as io;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:my_todo/api/task.dart';
import 'package:my_todo/model/topic.dart';
import 'package:my_todo/utils/net.dart';
import 'package:my_todo/utils/picker.dart';
import 'package:my_todo/view/task/snapshot/task_card.dart';
import 'package:path/path.dart' as path;
import 'package:web_socket_channel/web_socket_channel.dart';

class TaskInfoController extends GetxController {
  late final int id;
  TextEditingController textAreaController = TextEditingController();
  Rx<String> qrCode = "".obs;

  List<TFile> images = [];
  late TaskCardModel model;
  QuillController? quillController;
  Rx<TopicRole> role = TopicRole.member.obs;

  @override
  void onInit() {
    super.onInit();
    model = Get.arguments as TaskCardModel;
    taskPermissionRequest(model.id).then((v) {
      role.value = v;
    });
  }

  void initTextService() {
    quillController = () {
      return QuillController.basic(
        config: QuillControllerConfig(
          clipboardConfig: QuillClipboardConfig(
            enableExternalRichPaste: true,
            onImagePaste: (imageBytes) async {
              if (kIsWeb) {
                // Dart IO is unsupported on the web.
                return null;
              }
              // Save the image somewhere and return the image URL that will be
              // stored in the Quill Delta JSON (the document).
              final newFileName =
                  'image-file-${DateTime.now().toIso8601String()}.png';
              final newPath = path.join(
                io.Directory.systemTemp.path,
                newFileName,
              );
              final file = await io.File(
                newPath,
              ).writeAsBytes(imageBytes, flush: true);
              return file.path;
            },
          ),
        ),
      );
    }();
  }
}
