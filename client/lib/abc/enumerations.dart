import 'package:flutter/material.dart';

enum CalendarView {
  agenda("List", Icons.list),
  day("One Day", Icons.calendar_view_day_outlined),
  day3("Three days", Icons.view_column),
  day3Draggable("Three days - Draggable events", Icons.view_column),
  month("Month", Icons.calendar_month),
  multi_column2("Multi columns 1", Icons.view_column_outlined),
  multi_column1("Multi columns 2", Icons.view_column_outlined),
  day7("Seven days (web or tablet)", Icons.calendar_view_week);

  const CalendarView(this.text, this.icon);

  final String text;
  final IconData icon;
}

enum ToolBoxView {
  add("add", Icons.add),
  invite("invite", Icons.share),
  member("member", Icons.group);

  const ToolBoxView(this.text, this.icon);

  final String text;
  final IconData icon;
}
