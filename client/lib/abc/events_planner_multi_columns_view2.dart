import 'package:my_todo/theme/provider.dart';

import 'extension.dart';
import 'utils.dart';
import 'package:flutter/material.dart';
import 'package:infinite_calendar_view/infinite_calendar_view.dart';
import 'package:random_avatar/random_avatar.dart';
import 'package:table_calendar/table_calendar.dart';

class EventsPlannerMultiColumnSchedulerView extends StatefulWidget {
  const EventsPlannerMultiColumnSchedulerView({
    super.key,
    required this.controller,
  });

  final EventsController controller;

  @override
  State<EventsPlannerMultiColumnSchedulerView> createState() =>
      _EventsPlannerMultiColumnSchedulerViewState();
}

class _EventsPlannerMultiColumnSchedulerViewState
    extends State<EventsPlannerMultiColumnSchedulerView> {
  GlobalKey<EventsPlannerState> oneDayViewKey = GlobalKey<EventsPlannerState>();
  late double heightPerMinute;
  late double initialVerticalScrollOffset;
  late DateTime selectedDay;

  @override
  void initState() {
    super.initState();
    selectedDay = widget.controller.focusedDay;
    heightPerMinute = 1.0;
    initialVerticalScrollOffset = heightPerMinute * 7 * 60;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 20),
        tableCalendar(),
        Divider(),
        Expanded(
          child: EventsPlanner(
            key: oneDayViewKey,
            controller: widget.controller,
            daysShowed: 1,
            heightPerMinute: heightPerMinute,
            initialVerticalScrollOffset: initialVerticalScrollOffset,
            daySeparationWidth: 10,

            // event cell
            dayParam: DayParam(
              dayEventBuilder:
                  (event, height, width, heightPerMinute) =>
                      EventWidget(widget.controller, event, height, width),
              onSlotTap:
                  (columnIndex, exactDateTime, roundDateTime) =>
                      showSnack(context, "Slot Tap column = ${columnIndex}"),
              todayColor: Theme.of(context).colorScheme.surface,
            ),

            fullDayParam: FullDayParam(
              fullDayEventsBarDecoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  bottom: BorderSide(color: Colors.black12),
                ),
              ),
            ),

            // header
            daysHeaderParam: DaysHeaderParam(
              daysHeaderVisibility: false,
              daysHeaderHeight: 70,
              daysHeaderColor: Theme.of(context).colorScheme.surface,
            ),

            // personalize columns
            columnsParam: ColumnsParam(
              columns: 3,
              columnsWidthRatio: [1 / 3, 1 / 3, 1 / 3],
              columnHeaderBuilder: (day, isToday, columIndex, columnWidth) {
                return Avatar(columnWidth: columnWidth, columIndex: columIndex);
              },
            ),

            // personalize offTimes per column
            offTimesParam: OffTimesParam(
              offTimesAllDaysPainter: (
                column,
                day,
                isToday,
                heightPerMinute,
                ranges,
                color,
              ) {
                var offTimesDefaultColor = ThemeProvider.contrastColor(
                  context,
                  light: Theme.of(context).colorScheme.surface.lighten(0.03),
                  dark: const Color(0xFFF4F4F4),
                );
                return OffSetAllDaysPainter(
                  isToday,
                  paintToday: true,
                  heightPerMinute,
                  column == 0 ? ranges : getHalfTimeRange(),
                  offTimesDefaultColor,
                );
              },
            ),
            onDayChange: (newDay) => setState(() => selectedDay = newDay),
          ),
        ),
      ],
    );
  }

  TableCalendar tableCalendar() {
    return TableCalendar(
      firstDay: selectedDay.subtract(Duration(days: 365)),
      lastDay: selectedDay.add(Duration(days: 365)),
      focusedDay: selectedDay,
      calendarFormat: CalendarFormat.week,
      selectedDayPredicate: (day) => isSameDay(selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          this.selectedDay = selectedDay;
        });
        widget.controller.updateFocusedDay(selectedDay);
        oneDayViewKey.currentState?.jumpToDate(selectedDay);
      },
      headerVisible: false,
      weekNumbersVisible: true,
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
      calendarStyle: CalendarStyle(
        outsideDaysVisible: true,
        markerSize: 7,
        todayDecoration: BoxDecoration(
          color: Theme.of(context).primaryColorDark,
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  List<OffTimeRange> getHalfTimeRange() => [
    OffTimeRange(TimeOfDay(hour: 0, minute: 0), TimeOfDay(hour: 9, minute: 0)),
    OffTimeRange(
      TimeOfDay(hour: 13, minute: 0),
      TimeOfDay(hour: 24, minute: 0),
    ),
  ];
}

class Avatar extends StatelessWidget {
  const Avatar({
    super.key,
    required this.columnWidth,
    required this.columIndex,
  });

  final double columnWidth;
  final int columIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: columnWidth,
      child: Column(
        children: [
          RandomAvatar(
            columIndex == 0
                ? 'Suzy'
                : columIndex == 1
                ? 'Jose'
                : 'Michelle',
            trBackground: false,
            height: 35,
            width: 35,
          ),
          Text(
            columIndex == 0
                ? 'Suzy'
                : columIndex == 1
                ? 'Jose'
                : 'Michelle',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class EventWidget extends StatelessWidget {
  const EventWidget(this.controller, this.event, this.height, this.width);

  final EventsController controller;
  final Event event;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return DraggableEventWidget(
      event: event,
      height: height,
      width: width,
      onDragEnd: (columnIndex, exactStart, exactEnd, roundStart, roundEnd) {
        controller.updateCalendarData(
          (data) => data.updateEvent(
            oldEvent: event,
            newEvent: event.copyWith(
              columnIndex: columnIndex,
              startTime: roundStart,
              endTime: roundEnd,
            ),
          ),
        );
      },
      child: DefaultDayEvent(
        height: height,
        width: width,
        color: event.color.darken(0.12),
        eventMargin: EdgeInsets.all(2),
        roundBorderRadius: 5,
        onTap: () => showSnack(context, "Tap ${event.title}"),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Text(
                getSlotHourText(event.startTime, event.endTime!),
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: TextStyle(fontSize: 11, color: Colors.black54),
              ),
            ),
            Flexible(
              child: Text(
                event.title ?? "",
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                maxLines: 2,
              ),
            ),
            Flexible(
              child: Text(
                event.description ?? "",
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: TextStyle(fontSize: 11, color: Colors.black87),
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getSlotHourText(DateTime start, DateTime end) {
    return "${start.hour.toString().padLeft(2, '0')}:${start.hour.toString().padLeft(2, '0')} - ${end.hour.toString().padLeft(2, '0')}:${end.hour.toString().padLeft(2, '0')}";
  }
}
