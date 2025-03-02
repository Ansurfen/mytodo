import 'package:flutter/material.dart';
import 'package:infinite_calendar_view/src/controller/events_controller.dart';
import 'package:intl/intl.dart';

import 'enumerations.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.eventsController,
    this.onChangeDarkMode,
    this.onChangeCalendarView,
  });

  final EventsController eventsController;
  final void Function(bool darkMode)? onChangeDarkMode;
  final void Function(CalendarView calendarMode)? onChangeCalendarView;

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(60);
}

class _CustomAppBarState extends State<CustomAppBar> {
  var calendarMode = CalendarView.day3;
  var darkMode = false;
  var appBarText = "";

  @override
  void initState() {
    super.initState();
    widget.eventsController.onFocusedDayChange = (day) {
      setState(() {
        appBarText = DateFormat("MMM yyyy").format(day);
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    var color =
        darkMode ? Colors.white : Theme.of(context).colorScheme.onPrimary;
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Infinite Calendar View",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: color,
                ),
          ),
          Text(
            appBarText,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: color,
                ),
          ),
        ],
      ),
      scrolledUnderElevation: 0.0,
      toolbarOpacity: 1,
      elevation: 0,
      centerTitle: false,
      leading: Icon(
        Icons.rocket_launch,
        color: color,
      ),
      actions: [
        // change dark mode
        IconButton(
          onPressed: () => setState(() {
            darkMode = !darkMode;
            widget.onChangeDarkMode?.call(darkMode);
          }),
          icon: Icon(
            Icons.dark_mode,
            color: color,
          ),
        ),

        // change calendar mode
        PopupMenuButton(
          icon: Icon(calendarMode.icon),
          iconColor: color,
          onSelected: (value) => setState(() {
            calendarMode = value;
            widget.onChangeCalendarView?.call(value);
          }),
          itemBuilder: (BuildContext context) {
            return CalendarView.values.map((mode) {
              return PopupMenuItem(
                value: mode,
                child: ListTile(
                  leading: Icon(mode.icon),
                  title: Text(mode.text),
                ),
              );
            }).toList();
          },
        ),
      ],
    );
  }
}
