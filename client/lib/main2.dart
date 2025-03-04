import 'package:flutter/material.dart';
import 'package:my_todo/widgets/barchart/bar_chart_sample1.dart';
import 'package:my_todo/widgets/barchart/bar_chart_sample2.dart';
import 'package:my_todo/widgets/barchart/bar_chart_sample3.dart';
import 'package:my_todo/widgets/barchart/bar_chart_sample4.dart';
import 'package:my_todo/widgets/barchart/bar_chart_sample5.dart';
import 'package:my_todo/widgets/barchart/bar_chart_sample6.dart';
import 'package:my_todo/widgets/barchart/bar_chart_sample7.dart';
import 'package:my_todo/widgets/barchart/bar_chart_sample8.dart';
import 'package:my_todo/widgets/chart_holder.dart';
import 'package:my_todo/widgets/chart_sample.dart';
import 'package:my_todo/widgets/resources/app_dimens.dart';
import 'pages/heatmap_calendar_example.dart';
import 'pages/heatmap_example.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Heatmap Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => const MyHomePage(),
        '/heatmap_calendar':
            (context) => Scaffold(
              backgroundColor: Colors.transparent,
              body: ListView.builder(
                itemCount: 8,
                padding: const EdgeInsets.only(
                  left: AppDimens.chartSamplesSpace,
                  right: AppDimens.chartSamplesSpace,
                  top: AppDimens.chartSamplesSpace,
                  bottom: AppDimens.chartSamplesSpace + 68,
                ),
                itemBuilder: (BuildContext context, int index) {
                  return ChartHolder(
                    chartSample: BarChartSample(index, (c) => samples[index]),
                  );
                },
              ),
            ),
        '/heatmap': (context) => const HeatMapExample(),
      },
    );
  }
}

var samples = [
  BarChartSample1(),
  BarChartSample2(),
  BarChartSample3(),
  BarChartSample4(),
  BarChartSample5(),
  BarChartSample6(),
  BarChartSample7(),
  BarChartSample8(),
];

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter heatmap example')),
      body: SafeArea(
        child: ListView(
          children: <Widget>[
            ListTile(
              title: const Text('Heatmap calendar'),
              onTap: () => Navigator.of(context).pushNamed('/heatmap_calendar'),
            ),
            ListTile(
              title: const Text('Heatmap'),
              onTap: () => Navigator.of(context).pushNamed('/heatmap'),
            ),
          ],
        ),
      ),
    );
  }
}
