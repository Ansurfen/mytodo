import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:my_todo/theme/color.dart';
import 'package:my_todo/utils/guard.dart';

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
                  colorsets: shuffleAndMapColors(context),
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

Map<int, Color> shuffleAndMapColors(BuildContext context) {
  List<Color> colors = [
    HexColor.fromInt(0x00a1e5),
    HexColor.fromInt(0x04b9ae),
    HexColor.fromInt(0x8866e9),
    HexColor.fromInt(0xd251a6),
    HexColor.fromInt(0xff7b52),
    HexColor.fromInt(0xf94162),
    Colors.yellow,
  ];

  // 获取 primary 颜色
  Color primaryColor = Theme.of(context).primaryColor;

  // 洗牌颜色数组
  colors.shuffle(Random());

  // 找到 primaryColor 的索引
  int primaryIndex = colors.indexWhere(
    (color) => color.toString() == primaryColor.toString(),
  );
  if (primaryIndex == -1) {
    throw Exception("primaryColor 不在颜色列表中！");
  }

  // 确保 primaryColor 处于 key = 1 的位置
  if (primaryIndex != 0) {
    Color temp = colors[0];
    colors[0] = colors[primaryIndex];
    colors[primaryIndex] = temp;
  }

  // 生成符合要求的 Map
  List<int> keys = [1, 3, 5, 7, 9, 11, 13];
  Map<int, Color> colorMap = {
    for (int i = 0; i < colors.length; i++) keys[i]: colors[i],
  };

  return colorMap;
}
