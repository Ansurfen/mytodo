import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:infinite_calendar_view/infinite_calendar_view.dart';
import 'package:my_todo/abc/enumerations.dart';
import 'package:my_todo/abc/events_list_view.dart';
import 'package:my_todo/abc/events_months_view.dart';
import 'package:my_todo/abc/events_planner_draggable_events_view.dart';
import 'package:my_todo/abc/events_planner_multi_columns_view.dart';
import 'package:my_todo/abc/events_planner_multi_columns_view2.dart';
import 'package:my_todo/abc/events_planner_one_day_view.dart';
import 'package:my_todo/abc/events_planner_three_days_view.dart';
import 'package:my_todo/api/topic.dart';
import 'package:my_todo/component/scaffold.dart';
import 'package:my_todo/mock/provider.dart';
import 'package:my_todo/model/user.dart';
import 'package:my_todo/router/provider.dart';
import 'package:my_todo/theme/provider.dart';
import 'package:my_todo/view/topic/detail/topic_controller.dart';

class TopicPage extends StatefulWidget {
  const TopicPage({super.key});

  @override
  State<TopicPage> createState() => _TopicPageState();
}

class _TopicPageState extends State<TopicPage> {
  TopicController controller = Get.find<TopicController>();
  var calendarMode = CalendarView.day3;
  @override
  Widget build(BuildContext context) {
    bool darkMode = ThemeProvider.isDarkByContext(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primaryColor: Theme.of(context).primaryColor,
        appBarTheme: AppBarTheme(
          backgroundColor: Theme.of(context).primaryColor,
        ),
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.light,
          seedColor: Theme.of(context).primaryColor,
          primary: Theme.of(context).primaryColor,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        appBarTheme: AppBarTheme(backgroundColor: Color(0xff2F2F2F)),
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: Theme.of(context).primaryColor,
        ),
      ),
      home: todoScaffold(
        context,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          title: Text(
            controller.model.name,
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
          ),
          actions: [
            IconButton(
              onPressed: () {
                RouterProvider.viewChatConversation(
                  Chatsnapshot(
                    icon: "",
                    unreaded: 0,
                    lastAt: DateTime.now(),
                    lastMsg: "",
                    name: controller.model.name,
                    id: controller.id,
                    isOnline: false,
                    isTopic: true,
                    lastSenderName: '',
                    lastMsgId: 0,
                  ),
                );
              },
              icon: Icon(
                Icons.wechat,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            PopupMenuButton(
              icon: Icon(
                calendarMode.icon,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              onSelected:
                  (value) => setState(() {
                    calendarMode = value;
                    controller.calendarMode = value;
                  }),
              color: Theme.of(context).colorScheme.primary,
              itemBuilder: (BuildContext context) {
                return CalendarView.values.map((mode) {
                  return PopupMenuItem(
                    value: mode,
                    child: ListTile(
                      leading: Icon(
                        mode.icon,
                        color: darkMode ? Colors.white : Colors.black,
                      ),
                      title: Text(
                        mode.text,
                        style: TextStyle(
                          color: darkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  );
                }).toList();
              },
            ),
            PopupMenuButton(
              icon: Icon(
                Icons.more_vert,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              color: Theme.of(context).colorScheme.primary,
              itemBuilder: (BuildContext context) {
                return ToolBoxView.values.map((mode) {
                  return PopupMenuItem(
                    value: mode,
                    child: ListTile(
                      onTap: () {
                        if (mode == ToolBoxView.exit) {
                          topicExitRequest(topicId: controller.id).then((_) {
                            Get.back();
                            Get.snackbar(
                              "success".tr,
                              "exit_topic_success".tr,
                            );
                          });
                        }
                      },
                      leading: Icon(
                        mode.icon,
                        color: darkMode ? Colors.white : Colors.black,
                      ),
                      title: Text(
                        mode.text,
                        style: TextStyle(
                          color: darkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  );
                }).toList();
              },
            ),
          ],
        ),
        body: CalendarViewWidget(
          calendarMode: controller.calendarMode,
          controller: controller.eventsController,
          darkMode: controller.darkMode,
        ),
      ),
    );
  }
}

class CalendarViewWidget extends StatelessWidget {
  const CalendarViewWidget({
    super.key,
    required this.calendarMode,
    required this.controller,
    required this.darkMode,
  });

  final CalendarView calendarMode;
  final EventsController controller;
  final bool darkMode;

  @override
  Widget build(BuildContext context) {
    return switch (calendarMode) {
      CalendarView.agenda => EventsListView(controller: controller),
      CalendarView.day => EventsPlannerOneDayView(
        key: UniqueKey(),
        controller: controller,
      ),
      CalendarView.day3 => EventsPlannerTreeDaysView(
        key: UniqueKey(),
        controller: controller,
      ),
      CalendarView.day3Draggable => EventsPlannerDraggableEventsView(
        key: UniqueKey(),
        controller: controller,
        daysShowed: 3,
        isDarkMode: darkMode,
      ),
      CalendarView.day7 => EventsPlannerDraggableEventsView(
        key: UniqueKey(),
        controller: controller,
        daysShowed: 7,
        isDarkMode: darkMode,
      ),
      CalendarView.multiColumn2 => EventsPlannerMultiColumnView(
        key: UniqueKey(),
        controller: controller,
      ),
      CalendarView.multiColumn1 => EventsPlannerMultiColumnSchedulerView(
        key: UniqueKey(),
        controller: controller,
      ),
      CalendarView.month => EventsMonthsView(controller: controller),
    };
  }
}
