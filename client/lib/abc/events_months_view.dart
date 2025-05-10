import 'package:get/get.dart';

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
        onTap: () => showSnack(context, "Tap : ${event.title}"),
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
