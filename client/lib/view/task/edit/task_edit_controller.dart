import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:my_todo/api/task.dart';
import 'package:my_todo/utils/guard.dart';
import 'package:my_todo/model/entity/task.dart';

class TaskEditController extends GetxController {
  late int taskId;

  // 任务基本信息
  final RxString taskName = ''.obs;
  final RxString taskDesc = ''.obs;
  final RxString taskIcon = ''.obs;
  final ValueNotifier<DateTime> taskStart = ValueNotifier(DateTime.now());
  final ValueNotifier<DateTime> taskEnd = ValueNotifier(
    DateTime.now().add(const Duration(days: 1)),
  );

  // 任务条件
  final RxBool taskCondClick = false.obs;
  final RxBool taskCondQR = false.obs;
  final RxBool taskCondFile = false.obs;
  final RxBool taskCondText = false.obs;
  final RxList<Map<String, dynamic>> localeItems = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    taskId = int.parse(Get.parameters['id']!);
    _loadTaskData();
  }

  void _loadTaskData() async {
    try {
      final response = await taskDetailRequest(taskId);
      if (response != null) {
        // 更新任务基本信息
        final task = response['task'];
        taskName.value = task['name'];
        taskDesc.value = task['description'];
        taskIcon.value = task['icon'];
        taskStart.value = DateTime.parse(task['start_at']);
        taskEnd.value = DateTime.parse(task['end_at']);

        // 更新任务条件
        final conditions = response['conditions'];
        for (var condition in conditions) {
          switch (condition['type']) {
            case 0: // click
              taskCondClick.value = true;
              break;
            case 1: // file
              taskCondFile.value = true;
              break;
            case 3:
              taskCondQR.value = true;
              break;
            case 4: // locate
              taskCondText.value = true;
              if (condition['param'] != null) {
                final param = condition['param'];
                localeItems.clear();
                param.forEach((key, value) {
                  localeItems.add({
                    'latitude': value['latitude'],
                    'longitude': value['longitude'],
                    'radius': value['radius'],
                  });
                });
              }
              break;
            case 5: // text
              taskCondText.value = true;
              break;
          }
        }
      }
    } catch (e) {
      Guard.log.e('Failed to load task data: $e');
    }
  }

  void saveTaskData() async {
    try {
      List<TaskCondition> conditions = [];

      if (taskCondClick.value) {
        conditions.add(TaskCondition(type: "click", param: {}));
      }

      if (taskCondQR.value) {
        conditions.add(TaskCondition(type: "qr", param: {}));
      }

      if (taskCondFile.value) {
        conditions.add(TaskCondition(type: "file", param: {}));
      }

      if (taskCondText.value) {
        conditions.add(TaskCondition(type: "text", param: {}));
      }

      if (localeItems.isNotEmpty) {
        var i = 0;
        Map<String, dynamic> params = {};
        for (var e in localeItems) {
          params[i.toString()] = {
            "latitude": e['latitude'],
            "longitude": e['longitude'],
            "radius": e['radius'],
          };
          i++;
        }
        conditions.add(TaskCondition(type: 'locate', param: params));
      }

      final response = await taskEditRequest(
        id: taskId,
        name: taskName.value,
        description: taskDesc.value,
        icon: taskIcon.value,
        startAt: taskStart.value,
        endAt: taskEnd.value,
        conditions: conditions,
      );

      if (response != null) {
        Get.snackbar("success".tr, "success to edit");
        Get.back();
      }
    } catch (e) {
      Guard.log.e('Failed to save task data: $e');
      Get.snackbar("error".tr, "failed to edit");
    }
  }
}
