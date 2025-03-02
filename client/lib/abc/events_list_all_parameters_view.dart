import 'package:flutter/material.dart';
import 'package:infinite_calendar_view/infinite_calendar_view.dart';
import 'package:intl/intl.dart';

class EventsListView extends StatelessWidget {
  const EventsListView({
    super.key,
    required this.controller,
  });

  final EventsController controller;

  @override
  Widget build(BuildContext context) {
    return EventsList(
      controller: controller,
      initialDate: DateTime.now(),
      maxPreviousDays: 365,
      maxNextDays: 365,
      onDayChange: (day) {},
      todayHeaderColor: const Color(0xFFf4f9fd),
      verticalScrollPhysics: const BouncingScrollPhysics(
        decelerationRate: ScrollDecelerationRate.fast,
      ),
      dayEventsBuilder: (day, events) {
        return DefaultDayEvents(
          events: events,
          eventBuilder: (event) => DefaultDetailEvent(event: event),
          nullEventsWidget: DefaultDayEvents.defaultEmptyEventsWidget,
          eventSeparator: DefaultDayEvents.defaultEventSeparator,
          emptyEventsWidget: DefaultDayEvents.defaultEmptyEventsWidget,
        );
      },
      dayHeaderBuilder: (day, isToday, events) => DefaultHeader(
        dayText: DateFormat.MMMMEEEEd().format(day).toUpperCase(),
      ),
    );
  }
}
