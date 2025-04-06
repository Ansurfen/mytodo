import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_calendar_view/infinite_calendar_view.dart';
import 'package:my_todo/abc/enumerations.dart';
import 'package:my_todo/abc/extension.dart';
import 'package:my_todo/api/topic.dart';
import 'package:my_todo/model/entity/task.dart';
import 'package:my_todo/utils/guard.dart';

class TopicController extends GetxController with GetTickerProviderStateMixin {
  EventsController eventsController = EventsController();
  var calendarMode = CalendarView.day3Draggable;
  var darkMode = false;
  List<Event> events = <Event>[];

  @override
  void onInit() {
    super.onInit();
    topicCalendarRequest(id: int.parse(Get.parameters["id"]!)).then((v) {
      for (var e in v) {
        events.add(taskToEvent(Task.fromJson(e)));
      }
      eventsController.updateCalendarData((calendarData) {
        calendarData.addEvents(events);
      });
    });
  }
}

final colors = [
  Colors.red,
  Colors.blue,
  Colors.yellow,
  Colors.orange,
  Colors.green,
  Colors.brown,
  Colors.purple,
  Colors.pink,
  Colors.cyanAccent,
  Colors.brown,
];

Event taskToEvent(Task task) {
  final random = Random();

  final color = colors[random.nextInt(colors.length)];

  final duration = 1;
  final endTime = task.startAt.add(Duration(hours: duration.toInt()));

  return Event(
    title: task.name,
    description: task.description,
    startTime: task.startAt,
    endTime: endTime,
    color: color.pastel,
    textColor: color.onPastel,
    data: task.id,
  );
}
