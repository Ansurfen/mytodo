import 'package:get/get.dart';
import 'task_edit_controller.dart';

class TaskEditBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => TaskEditController());
  }
}
