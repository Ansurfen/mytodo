import 'package:get/get.dart';
import 'package:my_todo/api/task.dart';

class StatisticsController extends GetxController {
  RxMap<DateTime, int> heatMap = <DateTime, int>{}.obs;
  final Rx<bool> isCalendar = false.obs;

  @override
  void onInit() {
    super.onInit();
    Future.delayed(Duration.zero, () {
      taskHeatMap().then((v) {
        final map = v.cast<String, int>();
        heatMap.value = map.map(
          (key, value) => MapEntry(DateTime.parse(key), value),
        ); 
        heatMap.refresh();
      });
    });
  }
}
