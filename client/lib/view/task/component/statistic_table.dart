// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_todo/router/provider.dart';
import 'package:my_todo/theme/color.dart';
import 'dart:math' as math;
import 'package:my_todo/theme/provider.dart';

class StatisticTableModel {
  int completed;
  int timeout;
  int running;

  int periodTotalCount;
  int periodFinishedCount;
  int scheduleTotalCount;
  int scheduleFinishedCount;
  int generalTotalCount;
  int generalFinishedCount;

  StatisticTableModel({
    required this.completed,
    required this.timeout,
    required this.running,
    required this.periodTotalCount,
    required this.periodFinishedCount,
    required this.scheduleTotalCount,
    required this.scheduleFinishedCount,
    required this.generalTotalCount,
    required this.generalFinishedCount,
  });
}

class StatisticTable extends StatelessWidget {
  final AnimationController? animationController;
  final Animation<double>? animation;
  final StatisticTableModel data;

  const StatisticTable({
    super.key,
    this.animationController,
    this.animation,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: animation!,
          child: Transform(
            transform: Matrix4.translationValues(
              0.0,
              30 * (1.0 - animation!.value),
              0.0,
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                left: 24,
                right: 24,
                top: 16,
                bottom: 18,
              ),
              child: GestureDetector(
                onTap: RouterProvider.toStatistic,
                child: Container(
                  decoration: BoxDecoration(
                    color: ThemeProvider.contrastColor(
                      context,
                      dark: HexColor.fromInt(0x1c1c1e),
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8.0),
                      bottomLeft: Radius.circular(8.0),
                      bottomRight: Radius.circular(8.0),
                      topRight: Radius.circular(68.0),
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: StatisticTableTheme.grey.withOpacity(0.2),
                        offset: const Offset(1.1, 1.1),
                        blurRadius: 10.0,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _header(context),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 24,
                          right: 24,
                          top: 8,
                          bottom: 8,
                        ),
                        child: Container(
                          height: 2,
                          decoration: const BoxDecoration(
                            color: StatisticTableTheme.background,
                            borderRadius: BorderRadius.all(
                              Radius.circular(4.0),
                            ),
                          ),
                        ),
                      ),
                      _bottom(context),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _headerSideBar(
    BuildContext context, {
    required String title,
    required IconData icon,
    required int value,
  }) {
    return Row(
      children: [
        Container(
          height: 48,
          width: 2,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColorLight.withOpacity(0.8),
            borderRadius: const BorderRadius.all(Radius.circular(4.0)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 2),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: StatisticTableTheme.fontName,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    letterSpacing: -0.1,
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: Icon(
                      icon,
                      size: 20,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 3),
                    child: Text(
                      '${(value * animation!.value).toInt()}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: StatisticTableTheme.fontName,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  // Padding(
                  //   padding:
                  //       const EdgeInsets.only(left: 8, bottom: 3),
                  //   child: Text(
                  //     'left',
                  //     textAlign: TextAlign.center,
                  //     style: TextStyle(
                  //       fontFamily: StatisticTableTheme.fontName,
                  //       fontWeight: FontWeight.w600,
                  //       fontSize: 12,
                  //       letterSpacing: -0.2,
                  //       color: Theme.of(context)
                  //           .colorScheme
                  //           .onSecondary,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, top: 4),
              child: Column(
                children: [
                  _headerSideBar(
                    context,
                    title: 'task_finished'.tr,
                    icon: Icons.data_usage,
                    value: data.completed,
                  ),
                  const SizedBox(height: 8),
                  _headerSideBar(
                    context,
                    title: 'task_timeout'.tr,
                    icon: Icons.alarm,
                    value: data.timeout,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: ThemeProvider.contrastColor(
                          context,
                          light: Theme.of(context).colorScheme.tertiary,
                          dark: HexColor.fromInt(0x1c1c1e),
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(100.0),
                        ),
                        border: Border.all(
                          width: 4,
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '${(data.running * animation!.value).toInt()}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: StatisticTableTheme.fontName,
                              fontWeight: FontWeight.normal,
                              fontSize: 24,
                              letterSpacing: 0.0,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          Text(
                            'task_ongoing'.tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: StatisticTableTheme.fontName,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 0.0,
                              color: Theme.of(context).colorScheme.onSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: CustomPaint(
                      painter: CurvePainter(
                        colors: [
                          Theme.of(context).primaryColorLight,
                          Theme.of(context).primaryColor,
                          Theme.of(context).primaryColorDark,
                        ],
                        angle: 140 + (360 - 140) * (1.0 - animation!.value),
                      ),
                      child: const SizedBox(width: 108, height: 108),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomSection(
    BuildContext context, {
    required String title,
    required int wip,
    required int left,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: StatisticTableTheme.fontName,
            fontWeight: FontWeight.w500,
            fontSize: 16,
            letterSpacing: -0.2,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Container(
            height: 4,
            width: 70,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.2),
              borderRadius: const BorderRadius.all(Radius.circular(4.0)),
            ),
            child: Row(
              children: [
                Container(
                  width: (wip % 70 * animation!.value),
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.5),
                      ],
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            '$left ${"task_left".tr}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: StatisticTableTheme.fontName,
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _bottom(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 8, bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: _bottomSection(
              context,
              title: 'task_day'.tr,
              // color: '#87A0E5',
              wip: data.periodTotalCount - data.periodFinishedCount,
              left: data.periodTotalCount - data.periodFinishedCount,
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _bottomSection(
                  context,
                  title: 'task_month'.tr,
                  // color: '#F56E98',
                  wip: data.generalTotalCount - data.generalFinishedCount,
                  left: data.generalTotalCount - data.generalFinishedCount,
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _bottomSection(
                  context,
                  title: 'task_year'.tr,
                  // color: '#F1B440',
                  wip: data.scheduleTotalCount - data.scheduleFinishedCount,
                  left: data.scheduleTotalCount - data.scheduleFinishedCount,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CurvePainter extends CustomPainter {
  final double? angle;
  final List<Color>? colors;

  CurvePainter({this.colors, this.angle = 140});

  @override
  void paint(Canvas canvas, Size size) {
    List<Color> colorsList = [];
    if (colors != null) {
      colorsList = colors ?? [];
    } else {
      colorsList.addAll([Colors.white, Colors.white]);
    }

    final shadowPaint =
        Paint()
          ..color = Colors.black.withOpacity(0.4)
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke
          ..strokeWidth = 14;
    final shadowPaintCenter = Offset(size.width / 2, size.height / 2);
    final shdowPaintRadius =
        math.min(size.width / 2, size.height / 2) - (14 / 2);
    canvas.drawArc(
      Rect.fromCircle(center: shadowPaintCenter, radius: shdowPaintRadius),
      degreeToRadians(278),
      degreeToRadians(360 - (365 - angle!)),
      false,
      shadowPaint,
    );

    shadowPaint.color = Colors.grey.withOpacity(0.3);
    shadowPaint.strokeWidth = 16;
    canvas.drawArc(
      Rect.fromCircle(center: shadowPaintCenter, radius: shdowPaintRadius),
      degreeToRadians(278),
      degreeToRadians(360 - (365 - angle!)),
      false,
      shadowPaint,
    );

    shadowPaint.color = Colors.grey.withOpacity(0.2);
    shadowPaint.strokeWidth = 20;
    canvas.drawArc(
      Rect.fromCircle(center: shadowPaintCenter, radius: shdowPaintRadius),
      degreeToRadians(278),
      degreeToRadians(360 - (365 - angle!)),
      false,
      shadowPaint,
    );

    shadowPaint.color = Colors.grey.withOpacity(0.1);
    shadowPaint.strokeWidth = 22;
    canvas.drawArc(
      Rect.fromCircle(center: shadowPaintCenter, radius: shdowPaintRadius),
      degreeToRadians(278),
      degreeToRadians(360 - (365 - angle!)),
      false,
      shadowPaint,
    );

    final rect = Rect.fromLTWH(0.0, 0.0, size.width, size.width);
    final gradient = SweepGradient(
      startAngle: degreeToRadians(268),
      endAngle: degreeToRadians(270.0 + 360),
      tileMode: TileMode.repeated,
      colors: colorsList,
    );
    final paint =
        Paint()
          ..shader = gradient.createShader(rect)
          ..strokeCap =
              StrokeCap
                  .round // StrokeCap.round is not recommended.
          ..style = PaintingStyle.stroke
          ..strokeWidth = 14;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2) - (14 / 2);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      degreeToRadians(278),
      degreeToRadians(360 - (365 - angle!)),
      false,
      paint,
    );

    const gradient1 = SweepGradient(
      tileMode: TileMode.repeated,
      colors: [Colors.white, Colors.white],
    );

    var cPaint = Paint();
    cPaint.shader = gradient1.createShader(rect);
    cPaint.color = Colors.white;
    cPaint.strokeWidth = 14 / 2;
    canvas.save();

    final centerToCircle = size.width / 2;
    canvas.save();

    canvas.translate(centerToCircle, centerToCircle);
    canvas.rotate(degreeToRadians(angle! + 2));

    canvas.save();
    canvas.translate(0.0, -centerToCircle + 14 / 2);
    canvas.drawCircle(const Offset(0, 0), 14 / 5, cPaint);

    canvas.restore();
    canvas.restore();
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  double degreeToRadians(double degree) {
    return (math.pi / 180) * degree;
  }
}
