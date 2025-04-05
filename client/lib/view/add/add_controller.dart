// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'dart:io' as io;
import 'package:board_datetime_picker/board_datetime_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:my_todo/api/post.dart';
import 'package:my_todo/api/task.dart';
import 'package:my_todo/api/topic.dart';
import 'package:my_todo/mock/provider.dart';
import 'package:my_todo/model/entity/task.dart';
import 'package:my_todo/model/entity/topic.dart';
import 'package:my_todo/view/add/add_task_page.dart';
import 'package:path/path.dart' as path;

class AddController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late TabController tabController;

  _postController post = _postController();

  // topic
  Rx<String> topicIcon = "".obs;
  TextEditingController topicName = TextEditingController();
  TextEditingController topicDesc = TextEditingController();
  RxList<String> topicTags = <String>[].obs;
  bool topicIsPublic = false;

  // task
  List<Topic> topics = [];
  Rx<int> selectedTopicID = (-1).obs;
  Rx<String> taskIcon = "".obs;
  TextEditingController taskName = TextEditingController();
  TextEditingController taskDesc = TextEditingController();
  bool taskCondClick = false;
  bool taskCondQR = false;
  Rx<bool> taskCondFile = false.obs;
  Rx<bool> taskCondText = false.obs;
  final BoardMultiDateTimeController boardMultiDateTimeController =
      BoardMultiDateTimeController();
  final ValueNotifier<DateTime> taskStart = ValueNotifier(DateTime.now());
  final ValueNotifier<DateTime> taskEnd = ValueNotifier(
    DateTime.now().add(const Duration(days: 7)),
  );
  RxList<LocaleItem> localeItems = <LocaleItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 3, vsync: this);

    Future.delayed(Duration.zero, () async {
      topicGetSelectableRequest().then((v) {
        topics = v;
      });
    });
    taskIcon.value = animalMammal[Mock.number(max: animalMammal.length - 1)];
    topicIcon.value = animalMammal[Mock.number(max: animalMammal.length - 1)];
  }

  void switchToTab(int index) {
    tabController.animateTo(index);
  }

  void save() {
    switch (tabController.index) {
      case 0:
        List<TaskCondition> conditions = [];

        if (taskCondClick) {
          conditions.add(TaskCondition(type: "click", param: {}));
        }

        if (taskCondQR) {
          conditions.add(TaskCondition(type: "qr", param: {}));
        }

        if (taskCondFile.value) {
          conditions.add(TaskCondition(type: "file", param: {}));
        }

        if (taskCondText.value) {
          conditions.add(TaskCondition(type: "text", param: {}));
        }

        if (localeItems.isNotEmpty) {
          for (var e in localeItems) {
            conditions.add(
              TaskCondition(
                type: "locate",
                param: {
                  "latitude": e.lat,
                  "longitude": e.lng,
                  "radius": e.radius,
                },
              ),
            );
          }
        }

        taskNewRequest(
          id: topics[selectedTopicID.value].id,
          icon: taskIcon.value,
          name: taskName.text,
          description: taskDesc.text,
          startAt: taskStart.value,
          endAt: taskEnd.value,
          conditions: conditions,
        );
      case 1:
        topicNewRequest(
          icon: topicIcon.value,
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
    Get.back();

    Get.snackbar("success".tr, "success to create");
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

  Future<void> create() async {
    var delta = controller.document.toDelta();
    List<String> files = [];
    List<int> indexs = [];
    List<String> types = [];
    int index = 0;
    for (var op in delta.toList()) {
      if (op.isInsert) {
        if (op.data is String) {
        } else if (op.data is Map) {
          Map<String, dynamic> data = op.data as Map<String, dynamic>;
          if (data.containsKey("image")) {
            files.add(data["image"]);
            indexs.add(index);
            types.add("image");
          } else if (data.containsKey("video")) {
            files.add(data["video"]);
            indexs.add(index);
            types.add("video");
          }
        }
      }
      index++;
    }
    return postNewRequest(
      title: textEditingController.text,
      text: delta.toJson(),
      files: files,
      indexs: indexs,
      types: types,
    );
  }
}
