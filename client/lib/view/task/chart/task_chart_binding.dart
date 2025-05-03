import 'package:get/get.dart';
import 'package:my_todo/view/task/chart/task_chart_controller.dart';

class TaskChartBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TaskChartController>(() => TaskChartController());
  }
}