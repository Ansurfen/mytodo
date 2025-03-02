import 'package:get/get.dart';
import 'package:infinite_calendar_view/infinite_calendar_view.dart';
import 'package:my_todo/abc/data.dart';
import 'package:my_todo/abc/enumerations.dart';

class TopicController extends GetxController with GetTickerProviderStateMixin {
  EventsController eventsController = EventsController();
  var calendarMode = CalendarView.day3Draggable;
  var darkMode = false;

  @override
  void onInit() {
    super.onInit();
    eventsController.updateCalendarData((calendarData) {
      calendarData.addEvents(events);
      calendarData.addEvents(fullDayEvents);
    });
  }
}
