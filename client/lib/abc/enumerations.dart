import 'package:flutter/material.dart';

enum CalendarView {
  agenda("calendar_view_agenda", Icons.list),
  day("calendar_view_day", Icons.calendar_view_day_outlined),
  day3("calendar_view_day3", Icons.view_column),
  day3Draggable("calendar_view_day3Draggable", Icons.view_column),
  month("calendar_view_month", Icons.calendar_month),
  multiColumn2("calendar_view_multiColumn2", Icons.view_column_outlined),
  multiColumn1("calendar_view_multiColumn1", Icons.view_column_outlined),
  day7("calendar_view_day7", Icons.calendar_view_week);

  const CalendarView(this.text, this.icon);

  final String text;
  final IconData icon;
}

enum ToolBoxView {
  add("add", Icons.add),
  invite("invite", Icons.share),
  member("member", Icons.group),
  exit("exit", Icons.exit_to_app);

  const ToolBoxView(this.text, this.icon);

  final String text;
  final IconData icon;
}
