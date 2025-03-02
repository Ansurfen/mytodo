import 'dart:math';

import 'extension.dart';
import 'package:flutter/material.dart';
import 'package:infinite_calendar_view/infinite_calendar_view.dart';

DateTime get _now => DateTime.now();
List<Event> events = [
  ...generateRandomEvents(500),
  ...generateMultiDaysEvents(),
];
List<Event> multiColumnEvents = [
  ...generateRandomEvents(500, columnIndex: 0),
  ...generateRandomEvents(500, columnIndex: 1),
  ...generateRandomEvents(500, columnIndex: 2),
];

List<Event> generateMultiDaysEvents() {
  return [
    Event(
      title: "Sprint",
      description: "Sprint description",
      startTime: _now.add(Duration(days: 40, hours: -5)),
      endTime: _now.add(Duration(days: 42, hours: 3)),
      color: Colors.red.pastel,
      textColor: Colors.red.onPastel,
    ),
    Event(
      title: "Training",
      description: "Training description",
      startTime: DateTime(_now.year, _now.month, _now.day + 16, 9),
      endTime: DateTime(_now.year, _now.month, _now.day + 18, 8),
      color: Colors.green.pastel,
      textColor: Colors.green.onPastel,
    ),
    Event(
      title: "Validation",
      description: "Validation description",
      startTime: DateTime(_now.year, _now.month, _now.day + 12, 8),
      endTime: DateTime(_now.year, _now.month, _now.day + 14, 8),
      color: Colors.blue.pastel,
      textColor: Colors.blue.onPastel,
    ),
    Event(
      title: "Qualification",
      description: "Qualification description",
      startTime: DateTime(_now.year, _now.month, _now.day + 7, 9),
      endTime: DateTime(_now.year, _now.month, _now.day + 15, 9),
      color: Colors.orange.pastel,
      textColor: Colors.orange.onPastel,
    ),
  ];
}

List<Event> generateRandomEvents(int count, {int columnIndex = 0}) {
  final random = Random();
  final colors = [
    Colors.red,
    Colors.blue,
    Colors.yellow,
    Colors.orange,
    Colors.green,
    Colors.brown,
    Colors.purple,
    Colors.pink,
    Colors.cyanAccent,
    Colors.brown
  ];
  final titles = [
    "Project meeting",
    "Team brainstorming",
    "Client presentation",
    "Weekly sync",
    "Development session",
    "Design review",
    "Lunch meeting",
    "Stand-up",
    "Workshop",
    "Demo",
    "Product planning",
    "One-on-one",
    "Strategy session",
    "Goal review",
    "Budget discussion",
    "Quarterly update",
    "Marketing campaign planning",
    "Engineering sync",
    "HR review",
    "Sales strategy meeting",
    "Research update",
    "Performance review",
    "Sprint planning",
    "Retrospective",
    "Innovation day",
    "Recruitment meeting",
    "Customer feedback review",
    "UX research session",
    "Product launch",
    "Operations check-in",
    "Team-building activity",
    "Legal briefing",
    "Finance review",
    "Security audit",
    "Onboarding session",
    "Tech talk",
    "Town hall",
    "Press release planning",
    "Product roadmap review",
    "Data analytics review",
    "Executive briefing",
    "Industry trends review",
    "Company update",
    "Customer success sync",
    "PR strategy meeting",
    "Leadership meeting",
    "Investor relations update",
    "Product demo",
    "Webinar planning",
    "End-of-year celebration"
  ];

  return List.generate(count, (index) {
    // Random title and description
    final title = titles[random.nextInt(titles.length)];
    final description = "Today is the $title, make sure to attend and prepare.";

    // Random start time (current day, random hour between 8 and 18)
    final startHour = 8 + random.nextInt(10);
    final startMinute = random.nextInt(60);
    final startTime = DateTime(
        _now.year,
        _now.month,
        _now.day + random.nextInt(150) - 75,
        startHour.toInt(),
        startMinute.toInt());

    // Random duration (1-3 hours)
    final duration = 1 + random.nextInt(2);
    final endTime = startTime.add(Duration(hours: duration.toInt()));

    // Random color
    final color = colors[random.nextInt(colors.length)];

    return Event(
      title: title,
      description: description,
      startTime: startTime,
      endTime: endTime,
      color: color.pastel,
      textColor: color.onPastel,
      columnIndex: columnIndex,
    );
  });
}

List<Event> fullDayEvents = [
  Event(
    title: "Holiday",
    color: Colors.grey.pastel,
    textColor: Colors.grey.onPastel,
    startTime: _now.withoutTime,
    endTime: _now.withoutTime.add(Duration(days: 7)),
    isFullDay: true,
  ),
];

List<Event> reservationsEvents = generateReservationRandomEvents(2000);

List<Event> generateReservationRandomEvents(int count) {
  final random = Random();
  final colors = [
    Colors.yellow,
    Colors.green,
    Colors.blue,
  ];
  final titles = [
    "Jackson",
    "Paul",
    "Pitt",
    "Picard",
    "Grand",
    "Doe",
    "Williams",
    "Bell",
    "Smith",
    "Jones",
    "Brown",
    "David",
    "Miller",
    "Kante",
    "Moore",
    "Dupont",
    "Muller",
    "Durant",
    "Hanks",
    "Adams",
    "Madison",
    "Monroe",
    "Lincoln",
    "Grant",
    "Arthur",
  ];

  var list = List.generate(count, (index) {
    final column = random.nextInt(colors.length);
    // Random title and description
    final title = titles[random.nextInt(titles.length)];
    final description = "";

    // Random start time (current day, random hour between 8 and 18)
    final startHour = 8 + random.nextInt(10);
    final startMinute = 0;
    final startTime = DateTime(
        _now.year,
        _now.month,
        _now.day + random.nextInt(60) - 30,
        startHour.toInt(),
        startMinute.toInt());

    // Random duration (1-3 hours)
    final duration = 1;
    final endTime = startTime.add(Duration(hours: duration.toInt()));

    // Random color
    final color = colors[column];

    return Event(
      columnIndex: column,
      title: title,
      description: description,
      startTime: startTime,
      endTime: endTime,
      color: color.pastel,
      textColor: color.onPastel,
    );
  });

  return list.distinctBy((e) => e.startTime).toList();
}
