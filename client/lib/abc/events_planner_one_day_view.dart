import 'package:flutter/material.dart';
import 'package:infinite_calendar_view/infinite_calendar_view.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class EventsPlannerOneDayView extends StatefulWidget {
  const EventsPlannerOneDayView({super.key, required this.controller});

  final EventsController controller;

  @override
  State<EventsPlannerOneDayView> createState() =>
      _EventsPlannerOneDayViewState();
}

class _EventsPlannerOneDayViewState extends State<EventsPlannerOneDayView> {
  GlobalKey<EventsPlannerState> oneDayViewKey = GlobalKey<EventsPlannerState>();
  late DateTime selectedDay;

  @override
  void initState() {
    super.initState();
    selectedDay = widget.controller.focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    var heightPerMinute = 1.0;
    var initialVerticalScrollOffset = heightPerMinute * 7 * 60;

    return Column(
      children: [
        const SizedBox(height: 8.0),
        tableCalendar(),
        const SizedBox(height: 4.0),
        Divider(color: Theme.of(context).colorScheme.outlineVariant, height: 2),
        Expanded(
          child: EventsPlanner(
            key: oneDayViewKey,
            controller: widget.controller,
            daysShowed: 1,
            heightPerMinute: heightPerMinute,
            initialVerticalScrollOffset: initialVerticalScrollOffset,
            horizontalScrollPhysics: PageScrollPhysics(),
            daysHeaderParam: DaysHeaderParam(
              daysHeaderVisibility: false,
              dayHeaderTextBuilder: (day) => DateFormat("E d").format(day),
            ),
            onDayChange: (firstDay) {
              setState(() {
                selectedDay = firstDay;
              });
            },
            dayParam: DayParam(
              dayEventBuilder: (event, height, width, heightPerMinute) {
                return DefaultDayEvent(
                  height: height,
                  width: width,
                  title: event.title,
                  description: event.description,
                  color: event.color,
                  textColor: event.textColor,
                  onTap: () => print("tap ${event.uniqueId}"),
                  onTapDown: (details) {
                    print("tapdown ${event.uniqueId}");
                    print("${event.title}");
                  },
                );
              },
            ),
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
}
