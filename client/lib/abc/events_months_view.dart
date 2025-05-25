import 'package:get/get.dart';
import 'package:my_todo/api/task.dart';
import 'package:my_todo/view/task/snapshot/task_card.dart';
import 'utils.dart';
import 'package:flutter/material.dart';
import 'package:infinite_calendar_view/infinite_calendar_view.dart';

class EventsMonthsView extends StatelessWidget {
  const EventsMonthsView({super.key, required this.controller});

  final EventsController controller;

  @override
  Widget build(BuildContext context) {
    return EventsMonths(
      controller: controller,
      automaticAdjustScrollToStartOfMonth: true,
      weekParam: WeekParam(
        headerDayText: (dayOfWeek) {
          switch (dayOfWeek) {
            case 1:
              return "day_1".tr;
            case 2:
              return "day_2".tr;
            case 3:
              return "day_3".tr;
            case 4:
              return "day_4".tr;
            case 5:
              return "day_5".tr;
            case 6:
              return "day_6".tr;
            case 7:
              return "day_7".tr;
            default:
              return "";
          }
        },
      ),
      daysParam: DaysParam(
        dayHeaderBuilder: (day) {
          var isStartOfMonth = day.day == 1;
          var colorScheme = Theme.of(context).colorScheme;
          return DefaultMonthDayHeader(
            textColor:
                isStartOfMonth ? colorScheme.onSurface : colorScheme.outline,
            text:
                isStartOfMonth
                    ? "${"month_${day.month}".tr} 1"
                    : day.day.toString(),
            isToday: DateUtils.isSameDay(day, DateTime.now()),
          );
        },
        // custom builder : add drag and drop
        dayEventBuilder: (event, width, height) {
          return DraggableMonthEvent(
            child: getCustomEvent(context, width, height, event),
            onDragEnd: (DateTime day) {
              controller.updateCalendarData((data) => move(data, event, day));
            },
          );
        },
      ),
    );
  }

  SizedBox getCustomEvent(
    BuildContext context,
    double? width,
    double? height,
    Event event,
  ) {
    return SizedBox(
      width: width,
      height: height,
      child: DefaultMonthDayEvent(
        event: event,
        onTap: () async {
          try {
            final taskId = int.parse(event.data.toString());
            final response = await taskDetailRequest(taskId);
            if (response != null) {
              final task = response['task'];
              final conditions = response['conditions'] as List;
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(task['name'] ?? ''),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${"description".tr}: ${task['description'] ?? ''}"),
                      const SizedBox(height: 8),
                      Text("${"start_at".tr}: ${task['start_at']}"),
                      const SizedBox(height: 8),
                      Text("${"end_at".tr}: ${task['end_at']}"),
                      const SizedBox(height: 16),
                      Text("${"conditions".tr}:"),
                      ...conditions.map((condition) {
                        String typeStr;
                        switch (condition['type']) {
                          case 0:
                            typeStr = 'click';
                            break;
                          case 1:
                            typeStr = 'file';
                            break;
                          case 2:
                            typeStr = 'image';
                            break;
                          case 3:
                            typeStr = 'qr';
                            break;
                          case 4:
                            typeStr = 'locale';
                            break;
                          case 5:
                            typeStr = 'text';
                            break;
                          case 6:
                            typeStr = 'timer';
                            break;
                          default:
                            typeStr = 'unknown';
                        }
                        return Padding(
                          padding: const EdgeInsets.only(left: 16, top: 4),
                          child: Text("• ${ConditionType.fromString(typeStr).toString()}"),
                        );
                      }).toList(),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text("close".tr),
                    ),
                  ],
                ),
              );
            }
          } catch (e) {
            showSnack(context, "error_loading_task".tr);
          }
        },
      ),
    );
  }

  move(CalendarData data, Event event, DateTime newDay) {
    data.moveEvent(
      event,
      newDay.copyWith(
        hour: event.effectiveStartTime!.hour,
        minute: event.effectiveStartTime!.minute,
      ),
    );
  }
}
