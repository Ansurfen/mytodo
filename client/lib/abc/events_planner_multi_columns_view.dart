import 'data.dart';
import 'package:flutter/material.dart';
import 'package:infinite_calendar_view/infinite_calendar_view.dart';
import 'package:intl/intl.dart';

class EventsPlannerMultiColumnView extends StatelessWidget {
  const EventsPlannerMultiColumnView({super.key});

  @override
  Widget build(BuildContext context) {
    var controller =
        EventsController()..updateCalendarData((calendarData) {
          calendarData.addEvents(reservationsEvents);
        });

    var heightPerMinute = 1.0;
    var initialVerticalScrollOffset = heightPerMinute * 7 * 60;

    return EventsPlanner(
      controller: controller,
      daysShowed: 2,
      heightPerMinute: heightPerMinute,
      initialVerticalScrollOffset: initialVerticalScrollOffset,
      daySeparationWidth: 10,
      columnsParam: ColumnsParam(
        columns: 3,
        columnsWidthRatio: [1 / 3, 1 / 3, 1 / 3],
        columnHeaderBuilder: (day, isToday, columIndex, columnWidth) {
          return DefaultColumnHeader(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            columnText: ["Tennis", "Foot", "Bad"].elementAt(columIndex),
            columnWidth: columnWidth,
          );
        },
      ),
      fullDayParam: FullDayParam(fullDayEventsBarVisibility: false),
      daysHeaderParam: DaysHeaderParam(
        daysHeaderHeight: 80,
        dayHeaderBuilder: (day, isToday) {
          return DefaultDayHeader(
            dayText: DateFormat("E d").format(day),
            isToday: isToday,
          );
        },
      ),
      dayParam: DayParam(
        dayEventBuilder: (event, height, width, heightPerMinute) {
          return DefaultDayEvent(
            height: height,
            width: width,
            color: event.color,
            textColor: event.textColor,
            title: event.title,
            description: getSlotHourText(event.startTime, event.endTime!),
          );
        },
      ),
    );
  }

  String getSlotHourText(DateTime start, DateTime end) {
    return start.hour.toString().padLeft(2, '0') +
        ":" +
        start.hour.toString().padLeft(2, '0') +
        "\n" +
        end.hour.toString().padLeft(2, '0') +
        ":" +
        end.hour.toString().padLeft(2, '0');
  }
}
