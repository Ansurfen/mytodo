import 'package:flutter/material.dart';
import 'package:infinite_calendar_view/infinite_calendar_view.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class EventsListView extends StatefulWidget {
  const EventsListView({super.key, required this.controller});

  final EventsController controller;

  @override
  State<EventsListView> createState() => _EventsListViewState();
}

class _EventsListViewState extends State<EventsListView> {
  GlobalKey<EventsListState> listViewKey = GlobalKey<EventsListState>();
  late DateTime selectedDay;

  @override
  void initState() {
    super.initState();
    selectedDay = widget.controller.focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8.0),
        tableCalendar(),
        const SizedBox(height: 4.0),
        Divider(color: Theme.of(context).colorScheme.outlineVariant, height: 2),
        Expanded(
          child: EventsList(
            todayHeaderColor: Theme.of(context).primaryColorDark,
            key: listViewKey,
            controller: widget.controller,
            dayEventsBuilder: (day, events) {
              return DefaultDayEvents(
                events: events,
                nullEventsWidget: DefaultDayEvents.defaultEmptyEventsWidget,
                eventBuilder: (event) => DefaultDetailEvent(event: event),
              );
            },
            onDayChange: (firstDay) {
              setState(() {
                selectedDay = firstDay;
              });
            },
            dayHeaderBuilder:
                (day, isToday, events) => DefaultHeader(
                  dayText: DateFormat.MMMMEEEEd().format(day).toUpperCase(),
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
        listViewKey.currentState?.jumpToDate(selectedDay);
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
