// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_todo/api/task.dart';
import 'package:my_todo/model/dto/task.dart';
import 'package:my_todo/model/entity/task.dart';
import 'package:my_todo/router/provider.dart';
import 'package:my_todo/utils/dialog.dart';
import 'package:my_todo/utils/net.dart';
import 'package:my_todo/utils/picker.dart';
import 'package:my_todo/view/task/snapshot/task_card.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class TaskInfoController extends GetxController {
  late final int id;
  InfoTaskDto? _task;
  Rx<List<TaskForm>> forms = Rx([]);
  late TaskForm selectedTask;
  late List<ValueChanged<dynamic>> onTaps;
  TextEditingController textAreaController = TextEditingController();
  Rx<String> qrCode = "".obs;
  WebSocketChannel? qrChannel;
  List<TFile> images = [];
  List<ConditionItem> conds = [];

  @override
  void onInit() {
    super.onInit();
    var data = Get.parameters;
    // TODO 根据id 查询出条件
    conds = Get.arguments as List<ConditionItem>;
    return;
    id = int.parse(data['id']!);
    onTaps = [
      (v) {
        commitTask(
          CommitTaskRequest(id, TaskCondType.hand.index, ""),
        ).then((value) => null);
      },
      (v) {},
      (v) {
        RouterProvider.viewMapLocate()?.then((res) {
          commitTask(
            CommitTaskRequest(id, TaskCondType.locale.index, res),
          ).then((res) {
            for (var form in forms.value) {
              if (form.type == TaskCondType.locale) {
                form.param.value = res.param;
                break;
              }
            }
          });
        });
      },
      (v) {
        commitTask(
          CommitTaskRequest(
            id,
            TaskCondType.file.index,
            "",
            files: (v as List).map((e) => e as TFile).toList(),
          ),
        ).then((res) {});
      },
      (v) {
        commitTask(
          CommitTaskRequest(
            id,
            TaskCondType.image.index,
            "",
            images: (v as List).map((e) => e as TFile).toList(),
          ),
        ).then((res) {}).onError((error, stackTrace) {
          showError(error.toString());
        });
      },
      (v) {
        commitTask(
          CommitTaskRequest(id, TaskCondType.content.index, v),
        ).then((res) {}).onError((error, stackTrace) {
          showError(error.toString());
        });
      },
      (v) {},
    ];
    Future.delayed(Duration.zero, () {
      infoTask(InfoTaskRequest(id))
          .then((res) {
            _task = res.task;
            for (var cond in res.task.conds) {
              var opt = TaskForm.option(id)[cond.type];
              if (cond.type == TaskCondType.locale.index) {
                var res = cond.gotParams[0].split(",");
                if (res.length == 3) {
                  opt.param.value = res[2];
                  opt.isCompleted = true;
                }
              } else {
                if (cond.gotParams.isNotEmpty) {
                  opt.param.value = cond.gotParams[0];
                  opt.isCompleted = true;
                }
              }
              opt.wantCond = cond.wantParams;
              forms.value.add(opt);
            }
            if (forms.value.isNotEmpty) {
              forms.value[0].selected = true;
              selectedTask = forms.value[0];
            }
          })
          .onError((error, stackTrace) {
            showError(error.toString());
          });
    });
  }

  @override
  void dispose() {
    if (qrChannel != null) {
      qrChannel!.sink.close();
    }
    super.dispose();
  }

  void qrListen(String key) {
    qrChannel = WS.listen(
      "/event/qr",
      onInit: key,
      callback: (v) {
        qrCode.value = v;
      },
    );
  }

  InfoTaskDto get task {
    return _task ?? InfoTaskDto("", "", DateTime.now(), DateTime.now(), []);
  }

  String get condDesc {
    for (var form in forms.value) {
      if (form.selected) {
        return form.desc;
      }
    }
    return "???";
  }

  String get commitText {
    for (var form in forms.value) {
      if (form.selected) {
        return form.isCompleted ? "重新编辑" : "提交任务";
      }
    }
    return "???";
  }

  int get completedNumber {
    int count = 0;
    for (var form in forms.value) {
      if (form.isCompleted) {
        count++;
      }
    }
    return count;
  }

  ValueChanged<dynamic> get commitOnTap {
    for (var form in forms.value) {
      if (form.selected) {
        return onTaps[form.type.index];
      }
    }
    return (v) {};
  }

  void commit() {
    switch (selectedTask.type) {
      case TaskCondType.hand:
      case TaskCondType.timer:
      case TaskCondType.locale:
      case TaskCondType.file:
      case TaskCondType.content:
      case TaskCondType.image:
        break;
      case TaskCondType.qr:
    }
  }
}

class TaskForm {
  bool isCompleted = false;
  bool selected = false;
  bool committed = false;
  late String text;
  late String desc;
  TaskCondType type;
  List<String>? wantCond;
  Rx<String> param = "".obs;
  ValueChanged<dynamic>? onTap;

  TaskForm(this.type, this.text, this.desc, {this.onTap});

  static List<TaskForm> option(int id) {
    var list = [
      TaskForm(
        TaskCondType.hand,
        "task_cond_hand".tr,
        "task_cond_hand_more".tr,
        onTap: (v) {
          commitTask(
            CommitTaskRequest(id, TaskCondType.hand.index, ""),
          ).then((value) => null);
        },
      )..selected = true,
      TaskForm(
        TaskCondType.timer,
        "task_cond_sign_timeout".tr,
        "task_cond_sign_timeout_more".tr,
      ),
      TaskForm(
        TaskCondType.locale,
        "task_cond_locale".tr,
        "task_cond_locale_more".tr,
        onTap: (v) {
          RouterProvider.viewMapLocate()?.then((res) {
            commitTask(
              CommitTaskRequest(id, TaskCondType.locale.index, res),
            ).then((res) {
              // for (var form in forms.value) {
              //   if (form.type == TaskCondType.locale) {
              //     form.param.value = res.param;
              //     break;
              //   }
              // }
            });
          });
        },
      ),
      TaskForm(
        TaskCondType.file,
        "task_cond_file_upload".tr,
        "task_cond_file_upload_more".tr,
      ),
      TaskForm(
        TaskCondType.image,
        "task_cond_image_upload".tr,
        "task_cond_image_upload_more".tr,
      ),
      TaskForm(
        TaskCondType.content,
        "task_cond_text_content".tr,
        "task_cond_text_content_more".tr,
      ),
      TaskForm(
        TaskCondType.qr,
        "task_cond_qr_scan".tr,
        "task_cond_qr_scan_more".tr,
      ),
    ];
    return list;
  }
}
