import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_todo/component/scaffold.dart';
import 'package:my_todo/widgets/heatmap/heatmap.dart';
import 'package:my_todo/widgets/heatmap/heatmap_calendar.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  final Rx<bool> isCalendar = false.obs;

  List<Widget> dailyMap = [TodoHeatMap(), TodoHeatMapCalendar()];

  @override
  Widget build(BuildContext context) {
    return todoScaffold(
      context,
      appBar: AppBar(
        elevation: 0,
        title: Text("statistics".tr),
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            IconButton(
              onPressed: () {
                isCalendar.value = !isCalendar.value;
              },
              icon: Icon(Icons.switch_left),
            ),
            // TODO 数据共享 设置的模式共享
            Obx(() => isCalendar.value ? dailyMap[0] : dailyMap[1]),
          ],
        ),
      ),
    );
  }
}
