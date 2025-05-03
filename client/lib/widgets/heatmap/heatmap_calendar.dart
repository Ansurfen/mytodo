import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:my_todo/widgets/heatmap/heatmap.dart';

class TodoHeatMapCalendar extends StatefulWidget {
  final Map<DateTime, int> heatMap;
  const TodoHeatMapCalendar({super.key, required this.heatMap});

  @override
  State<StatefulWidget> createState() => _HeatMapCalendarExample();
}

class _HeatMapCalendarExample extends State<TodoHeatMapCalendar> {
  final TextEditingController dateController = TextEditingController();
  final TextEditingController heatLevelController = TextEditingController();

  bool isOpacityMode = true;

  @override
  void dispose() {
    super.dispose();
    dateController.dispose();
    heatLevelController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          margin: const EdgeInsets.all(20),
          child: Padding(
            padding: const EdgeInsets.all(20),

            // HeatMapCalendar
            child: HeatMapCalendar(
              flexible: true,
              datasets: widget.heatMap,
              colorMode: isOpacityMode ? ColorMode.opacity : ColorMode.color,
              colorsets: shuffleAndMapColors(context),
            ),
          ),
        ),

        // ColorMode/OpacityMode Switch.
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Color Mode'),
            CupertinoSwitch(
              value: isOpacityMode,
              activeColor: Theme.of(context).primaryColor,
              onChanged: (value) {
                setState(() {
                  isOpacityMode = value;
                });
              },
            ),
            const Text('Opacity Mode'),
          ],
        ),
      ],
    );
  }
}
