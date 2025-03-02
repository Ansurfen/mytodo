import 'package:flutter/material.dart';
import 'package:infinite_calendar_view/infinite_calendar_view.dart';
import 'package:intl/intl.dart';

class EventsPlannerAllParamView extends StatelessWidget {
  const EventsPlannerAllParamView({super.key, required this.controller});

  final EventsController controller;

  @override
  Widget build(BuildContext context) {
    return EventsPlanner(
      key: GlobalKey<EventsPlannerState>(),
      controller: controller,
      daysShowed: 3,
      initialDate: DateTime.now(),
      maxNextDays: 365,
      maxPreviousDays: 365,
      heightPerMinute: 1.0,
      initialVerticalScrollOffset: 1.0 * 7 * 60,
      daySeparationWidth: 3,
      onDayChange: (firstDay) {},
      onVerticalScrollChange: (offset) {},
      automaticAdjustHorizontalScrollToDay: true,
      onAutomaticAdjustHorizontalScroll: (day) {},
      horizontalScrollPhysics: const BouncingScrollPhysics(
        decelerationRate: ScrollDecelerationRate.fast,
      ),
      dayEventsArranger: SideEventArranger(paddingLeft: 0, paddingRight: 0),
      daysHeaderParam: DaysHeaderParam(
        daysHeaderVisibility: true,
        daysHeaderHeight: 40.0,
        daysHeaderColor: Theme.of(context).appBarTheme.backgroundColor,
        dayHeaderBuilder: (day, isToday) {
          return DefaultDayHeader(
            dayText: DateFormat("E d").format(day),
            isToday: isToday,
            foregroundColor: Colors.white,
          );
        },
      ),
      offTimesParam: OffTimesParam(
        offTimesAllDaysRanges: [
          OffTimeRange(
            TimeOfDay(hour: 0, minute: 0),
            TimeOfDay(hour: 7, minute: 0),
          ),
          OffTimeRange(
            TimeOfDay(hour: 18, minute: 0),
            TimeOfDay(hour: 24, minute: 0),
          ),
        ],
        offTimesDayRanges: {
          DateTime(2024, 10, 8): [
            OffTimeRange(
              TimeOfDay(hour: 8, minute: 0),
              TimeOfDay(hour: 18, minute: 0),
            ),
          ],
        },
        offTimesColor: Color(0xFFF4F4F4),
        offTimesAllDaysPainter: (
          column,
          day,
          isToday,
          heightPerMinute,
          ranges,
          color,
        ) {
          return OffSetAllDaysPainter(
            isToday,
            heightPerMinute,
            [],
            Color(0xFFF4F4F4),
          );
        },
        offTimesDayPainter: (
          column,
          day,
          isToday,
          heightPerMinute,
          ranges,
          color,
        ) {
          return OffSetAllDaysPainter(
            isToday,
            heightPerMinute,
            [],
            Color(0xFFF4F4F4),
          );
        },
      ),
      dayParam: DayParam(
        todayColor: Colors.black12,
        dayTopPadding: 10,
        dayBottomPadding: 15,
        onSlotMinutesRound: 15,
        onSlotTap: (columnIndex, exactDateTime, roundDateTime) {},
        onSlotLongTap: (columnIndex, exactDateTime, roundDateTime) {},
        onSlotDoubleTap: (columnIndex, exactDateTime, roundDateTime) {},
        onDayBuild: (day) {},
        dayEventBuilder: (event, height, width, heightPerMinute) {
          return DefaultDayEvent(
            height: height,
            width: width,
            title: event.title,
            description: event.description,
          );
        },
        dayCustomPainter:
            (heightPerMinute, isToday) => LinesPainter(
              heightPerMinute: heightPerMinute,
              isToday: isToday,
              lineColor: Colors.black12,
            ),
      ),
      fullDayParam: FullDayParam(
        fullDayEventsBarVisibility: true,
        fullDayEventsBarLeftText: 'All day',
        fullDayEventsBarLeftWidget: Text('All day'),
        fullDayEventsBarHeight: 40,
        fullDayEventsBarDecoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.black12)),
        ),
      ),
      timesIndicatorsParam: TimesIndicatorsParam(
        timesIndicatorsWidth: 60.0,
        timesIndicatorsHorizontalPadding: 4.0,
        timesIndicatorsCustomPainter:
            (heightPerMinute) => HoursPainter(
              heightPerMinute: 1.0,
              showCurrentHour: true,
              hourColor: Colors.black12,
              halfHourColor: Colors.black12,
              quarterHourColor: Colors.black12,
              currentHourIndicatorColor: Colors.black12,
              halfHourMinHeightPerMinute: 1.3,
              quarterHourMinHeightPerMinute: 2,
            ),
      ),
      currentHourIndicatorParam: CurrentHourIndicatorParam(
        currentHourIndicatorHourVisibility: true,
        currentHourIndicatorLineVisibility: true,
        currentHourIndicatorColor: Theme.of(context).primaryColor,
        currentHourIndicatorCustomPainter:
            (heightPerMinute, isToday) => TimeIndicatorPainter(
              heightPerMinute,
              isToday,
              Theme.of(context).primaryColor,
            ),
      ),
      pinchToZoomParam: PinchToZoomParameters(
        pinchToZoom: true,
        onZoomChange: (heightPerMinute) {},
        pinchToZoomMinHeightPerMinute: 0.5,
        pinchToZoomMaxHeightPerMinute: 2.5,
        pinchToZoomSpeed: 1,
      ),
    );
  }
}
