import 'package:flutter/cupertino.dart';
import 'package:my_todo/utils/chart/app_helper.dart';
import 'package:my_todo/utils/chart/urls.dart';

abstract class ChartSample {
  final int number;
  final WidgetBuilder builder;
  ChartType get type;
  String get name => '${type.displayName} Sample $number';
  String get url => Urls.getChartSourceCodeUrl(type, number);
  ChartSample(this.number, this.builder);
}

class LineChartSample extends ChartSample {
  LineChartSample(super.number, super.builder);
  @override
  ChartType get type => ChartType.line;
}

class BarChartSample extends ChartSample {
  BarChartSample(super.number, super.builder);
  @override
  ChartType get type => ChartType.bar;
}

class PieChartSample extends ChartSample {
  PieChartSample(super.number, super.builder);
  @override
  ChartType get type => ChartType.pie;
}

class ScatterChartSample extends ChartSample {
  ScatterChartSample(super.number, super.builder);
  @override
  ChartType get type => ChartType.scatter;
}

class RadarChartSample extends ChartSample {
  RadarChartSample(super.number, super.builder);
  @override
  ChartType get type => ChartType.radar;
}
