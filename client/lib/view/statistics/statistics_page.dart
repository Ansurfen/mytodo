import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_todo/component/scaffold.dart';
import 'package:my_todo/view/statistics/statistics_controller.dart';
import 'package:my_todo/widgets/heatmap/heatmap.dart';
import 'package:my_todo/widgets/heatmap/heatmap_calendar.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  final StatisticsController controller = Get.find<StatisticsController>();

  @override
  Widget build(BuildContext context) {
    return todoScaffold(
      context,
      appBar: AppBar(
        elevation: 0,
        title: Text("statistics".tr),
        leading: IconButton(
          onPressed: Get.back,
          icon: Icon(Icons.arrow_back_ios),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "heatmap".tr,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () {
                      controller.isCalendar.value =
                          !controller.isCalendar.value;
                    },
                    icon: Icon(Icons.switch_left),
                  ),
                ],
              ),
            ),
            Obx(
              () =>
                  controller.isCalendar.value
                      ? TodoHeatMap(heatMap: controller.heatMap)
                      : TodoHeatMapCalendar(heatMap: controller.heatMap),
            ),
          ],
        ),
      ),
    );
  }
}
