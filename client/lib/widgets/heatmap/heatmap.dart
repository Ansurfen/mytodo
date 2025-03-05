import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';

class TodoHeatMap extends StatefulWidget {
  const TodoHeatMap({super.key});

  @override
  State<StatefulWidget> createState() => _HeatMapExample();
}

class _HeatMapExample extends State<TodoHeatMap> {
  final TextEditingController dateController = TextEditingController();
  final TextEditingController heatLevelController = TextEditingController();

  bool isOpacityMode = true;

  Map<DateTime, int> heatMapDatasets = {};

  @override
  void dispose() {
    super.dispose();
    dateController.dispose();
    heatLevelController.dispose();
  }

  @override
  void initState() {
    heatMapDatasets[DateTime.parse("20250301")] = 10;
    heatMapDatasets[DateTime.parse("20250302")] = 1;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          margin: const EdgeInsets.all(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                HeatMap(
                  scrollable: true,
                  colorMode:
                      isOpacityMode ? ColorMode.opacity : ColorMode.color,
                  datasets: heatMapDatasets,
                  colorsets: const {
                    1: Colors.red,
                    3: Colors.orange,
                    5: Colors.yellow,
                    7: Colors.green,
                    9: Colors.blue,
                    11: Colors.indigo,
                    13: Colors.purple,
                  },
                  onClick: (value) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(value.toString())));
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text('Color Mode'),
                    CupertinoSwitch(
                      value: isOpacityMode,
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
            ),
          ),
        ),
      ],
    );
  }
}
