// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'dart:io' as io;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:my_todo/api/topic.dart';
import 'package:my_todo/model/entity/task.dart';
import 'package:my_todo/model/entity/topic.dart';
import 'package:my_todo/view/map/select/place.dart';
import 'package:path/path.dart' as path;

class AddController extends GetxController
    with GetSingleTickerProviderStateMixin {
  bool sync = false;
  List<Topic> topics = [];
  Rx<String> selectedTopic = "".obs;
  late TabController tabController;

  Rx<List<Place>> pos = Rx([]);

  bool taskCondClick = false;
  bool taskCondQR = false;
  Rx<bool> taskCondFile = false.obs;
  Rx<bool> taskCondText = false.obs;

  TextEditingController topicName = TextEditingController();
  TextEditingController topicDesc = TextEditingController();
  RxList<String> topicTags = <String>[].obs;
  bool topicIsPublic = false;

  _postController post = _postController();

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 3, vsync: this);

    Future.delayed(Duration.zero, () async {
      topicGetSelectableRequest().then((v) {
        topics = v;
      });
    });
  }

  void confirm() {
    // List<TaskCondition> conds = [];

    // createTask(
    //       CreateTaskRequest(
    //         selectedTopic!,
    //         nameController.text,
    //         descController.text,
    //         DateTime.parse(departureController.text),
    //         DateTime.parse(arrivalController.text),
    //         conds,
    //       ),
    //     )
    //     .then((value) => EasyLoading.showSuccess("Creates task successfully."))
    //     .onError((error, stackTrace) {});
  }

  void switchToTab(int index) {
    tabController.animateTo(index);
  }

  void save() {
    switch (tabController.index) {
      case 0:
      case 1:
        topicNewRequest(
          isPublic: topicIsPublic,
          name: topicName.text,
          tags: topicTags,
          description: topicDesc.text,
        ).then((v) {
          topicIsPublic = false;
          topicName.clear();
          topicDesc.clear();
          topicTags.clear();
        });
      case 2:
    }
  }
}

class _postController {
  final QuillController controller = () {
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

  final FocusNode editorFocusNode = FocusNode();
  final ScrollController editorScrollController = ScrollController();
  final TextEditingController textEditingController = TextEditingController(
    text: "untitled".tr,
  );
}
