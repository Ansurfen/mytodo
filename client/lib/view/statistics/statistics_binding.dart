import 'package:get/get.dart';
import 'package:my_todo/view/statistics/statistics_controller.dart';

class StatisticsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => StatisticsController());
  }
}
