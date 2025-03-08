// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'dart:async';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:my_todo/component/animate/fade_out_slow_in_container.dart';
import 'package:my_todo/component/container/empty_container.dart';
import 'package:my_todo/component/scaffold.dart';
import 'package:my_todo/component/title/title_view.dart';
import 'package:my_todo/mock/provider.dart';
import 'package:my_todo/mock/statistic.dart';
import 'package:my_todo/model/dto/topic.dart';
import 'package:my_todo/router/provider.dart';
import 'package:my_todo/theme/animate.dart';
import 'package:my_todo/theme/color.dart';
import 'package:my_todo/theme/provider.dart';
import 'package:my_todo/utils/guard.dart';
import 'package:my_todo/utils/guide.dart';
import 'package:my_todo/view/add/add_task_page.dart';
import 'package:my_todo/view/home/nav/component/app_bar.dart';
import 'package:my_todo/view/task/snapshot/task_card.dart';
import 'package:my_todo/view/task/snapshot/task_controller.dart';
import 'package:my_todo/view/task/snapshot/task_skeleton.dart';
import 'package:my_todo/view/task/component/statistic_table.dart';
import 'package:my_todo/utils/dialog.dart';
import 'package:my_todo/component/refresh.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:oktoast/oktoast.dart';
import 'package:showcaseview/showcaseview.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<StatefulWidget> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage>
    with AutomaticKeepAliveClientMixin {
  TaskController controller = Get.find<TaskController>();
  EasyRefreshController easyRefreshController = EasyRefreshController();
  Rx<bool> filterFinish = false.obs,
      filterTimeout = false.obs,
      filterRunning = false.obs;

  @override
  void initState() {
    super.initState();
    Guide.start(context);
    DateTime selectedDate = DateTime.now();
    startDateController.text = DateFormat('MM/dd/yyyy').format(selectedDate);
    endDateController.text = DateFormat('MM/dd/yyyy').format(selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return todoScaffold(
      context,
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(top: 5, left: 40),
          child: Text(
            "MyTodo".tr,
            style: const TextStyle(fontSize: 20, fontFamily: 'Pacifico'),
          ),
        ),
        actions: [
          Showcase(
            key: Guide.four,
            description: 'Tap to notification',
            tooltipActionConfig: const TooltipActionConfig(
              alignment: MainAxisAlignment.spaceBetween,
              actionGap: 16,
              position: TooltipActionPosition.outside,
              gapBetweenContentAndAction: 16,
            ),
            tooltipActions: [
              TooltipActionButton(
                type: TooltipDefaultActionType.previous,
                name: 'showcase_back'.tr,
                onTap: () {
                  // Write your code on button tap
                  ShowCaseWidget.of(context).previous();
                },
                backgroundColor: lighten(Theme.of(context).primaryColorLight),
                textStyle: TextStyle(color: Theme.of(context).primaryColor),
              ),
              TooltipActionButton(
                type: TooltipDefaultActionType.skip,
                name: 'showcase_close'.tr,
                textStyle: TextStyle(color: Colors.white),
                tailIcon: ActionButtonIcon(
                  icon: Icon(Icons.close, color: Colors.white, size: 15),
                ),
              ),
            ],
            child: notificationWidget(context),
          ),
          Showcase(
            key: Guide.two,
            description: 'Tap to settings',
            disposeOnTap: true,
            onTargetClick: () {
              RouterProvider.viewSetting()?.then(
                (_) => {
                  ShowCaseWidget.of(
                    context,
                  ).startShowCase([Guide.three, Guide.four]),
                },
              );
            },
            tooltipActionConfig: const TooltipActionConfig(
              alignment: MainAxisAlignment.spaceBetween,
              actionGap: 16,
              position: TooltipActionPosition.outside,
              gapBetweenContentAndAction: 16,
            ),
            tooltipActions: [
              TooltipActionButton(
                type: TooltipDefaultActionType.previous,
                name: 'showcase_back'.tr,
                onTap: () {
                  // Write your code on button tap
                  ShowCaseWidget.of(context).previous();
                },
                backgroundColor: lighten(Theme.of(context).primaryColorLight),
                textStyle: TextStyle(color: Theme.of(context).primaryColor),
              ),
              TooltipActionButton(
                type: TooltipDefaultActionType.skip,
                name: 'showcase_close'.tr,
                textStyle: TextStyle(color: Colors.white),
                tailIcon: ActionButtonIcon(
                  icon: Icon(Icons.close, color: Colors.white, size: 15),
                ),
              ),
            ],
            child: settingWidget(),
          ),
          multiWidget(context),
        ],
      ),
      body: FutureBuilder<bool>(
        future: controller.getData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Future.delayed(const Duration(milliseconds: 50), () {
              controller.animationController.forward();
            });
            return _taskList(context);
          }
          return const TaskSkeletonPage();
        },
      ),
    );
  }

  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  final TextEditingController startTimeController = TextEditingController();
  final TextEditingController endTimeController = TextEditingController();
  Widget _taskList(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    var opacity = TodoAnimateStyle.fadeOutOpacity(
      controller.animationController,
    );
    return refreshContainer(
      context: context,
      controller: easyRefreshController,
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 0), () {
          controller.refreshTask();
        });
      },
      onLoad: () async {
        await Future.delayed(const Duration(seconds: 0), () {
          controller.loadTask();
        });
      },
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                InkWell(
                  onTap: () {
                    RouterProvider.toStatistic();
                  },
                  child: StatisticTable(
                    data: statisticTableData,
                    animation: opacity,
                    animationController: controller.animationController,
                  ),
                ),
                FadeAnimatedBuilder(
                  animation: controller.animationController,
                  opacity: opacity,
                  child: TitleView(
                    onTap: () {
                      controller.showMask.value = true;
                    },
                    iconSize: 25,
                    icon: Icons.filter_alt,
                    titleTxt: 'task'.tr,
                  ),
                ),
                FadeAnimatedBuilder(
                  animation: controller.animationController,
                  opacity: opacity,
                  child: Obx(
                    () => EmptyContainer(
                      height: MediaQuery.sizeOf(context).height / 2.5,
                      icon: Icons.rss_feed,
                      desc: "no_task".tr,
                      what: "what_is_task".tr,
                      render: controller.tasks.value.isNotEmpty,
                      alignment: Alignment.topCenter,
                      padding: EdgeInsets.only(top: size.height * 0.2),
                      onTap: () {
                        showTipDialog(context, content: "what_is_task".tr);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: ListView.separated(
                          separatorBuilder: (context, index) {
                            return Container(height: 5);
                          },
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: controller.tasks.value.length,
                          itemBuilder: (ctx, idx) {
                            var task =
                                controller.tasks.value[controller
                                    .tasks
                                    .value
                                    .keys
                                    .elementAt(idx)];
                            if (task != null) {
                              final ValueKey<ExpansionTileCardState> k =
                                  ValueKey(ExpansionTileCardState());
                              return TaskCard(
                                key: k,
                                title: task.name,
                                msg: task.desc,
                                model: GetTopicDto(
                                  1,
                                  DateTime.now(),
                                  DateTime.now(),
                                  "",
                                  "",
                                  "6666",
                                  animalMammal[Mock.number(
                                    max: animalMammal.length - 1,
                                  )],
                                ),
                              );
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Obx(
            () =>
                controller.showMask.value
                    ? Stack(
                      children: [
                        GestureDetector(
                          onTap: () {
                            controller.showMask.value = false;
                          },
                          child: Container(
                            height: MediaQuery.of(context).size.height,
                            color: Colors.black.withOpacity(0.4),
                          ),
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height / 3,
                          decoration: BoxDecoration(
                            color: ThemeProvider.contrastColor(
                              context,
                              light: Colors.white,
                              dark: Colors.black,
                            ),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SearchTextField(),
                                Container(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          right: 8.0,
                                        ), // 右边添加间隔
                                        child: TextField(
                                          controller: startDateController,
                                          readOnly: true,
                                          onTap: () async {
                                            DateTime? dateTime =
                                                await todoSelectDate(
                                                  context,
                                                  initialDate: DateFormat(
                                                    'MM/dd/yyyy',
                                                  ).parse(
                                                    startDateController.text,
                                                  ),
                                                );
                                            if (dateTime != null) {
                                              // 检查选择的日期是否晚于结束日期
                                              DateTime? endDate = DateFormat(
                                                'MM/dd/yyyy',
                                              ).parse(endDateController.text);
                                              if (dateTime.isAtSameMomentAs(
                                                    endDate,
                                                  ) ||
                                                  dateTime.isBefore(endDate)) {
                                                // 如果选择的startDate比endDate早，更新startDateController
                                                startDateController
                                                    .text = DateFormat(
                                                  'MM/dd/yyyy',
                                                ).format(dateTime);
                                              } else {
                                                showToast(
                                                  "Start Date cannot be later than End Date.",
                                                );
                                              }
                                            }
                                          },
                                          decoration: InputDecoration(
                                            labelStyle: TextStyle(
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).primaryColor,
                                            ),
                                            floatingLabelStyle: TextStyle(
                                              color: Colors.grey,
                                            ),
                                            labelText: "start_date".tr,
                                            floatingLabelBehavior:
                                                FloatingLabelBehavior.auto,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: BorderSide(
                                                color: Colors.grey,
                                                width: 1.5,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: BorderSide(
                                                color: Colors.grey,
                                                width: 1.5,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: BorderSide(
                                                color: Colors.grey,
                                                width: 2,
                                              ),
                                            ),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                  vertical: 8.0,
                                                  horizontal: 12.0,
                                                ), // 缩小内边距
                                          ),
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          left: 8.0,
                                        ), // 左边添加间隔
                                        child: TextField(
                                          controller: endDateController,
                                          readOnly: true,
                                          onTap: () async {
                                            DateTime? dateTime =
                                                await todoSelectDate(
                                                  context,
                                                  initialDate: DateFormat(
                                                    'MM/dd/yyyy',
                                                  ).parse(
                                                    endDateController.text,
                                                  ),
                                                );
                                            if (dateTime != null) {
                                              // 检查选择的日期是否早于开始日期
                                              DateTime? startDate = DateFormat(
                                                'MM/dd/yyyy',
                                              ).parse(startDateController.text);
                                              if (dateTime.isAtSameMomentAs(
                                                    startDate,
                                                  ) ||
                                                  dateTime.isAfter(startDate)) {
                                                // 如果选择的endDate比startDate晚，更新endDateController
                                                endDateController
                                                    .text = DateFormat(
                                                  'MM/dd/yyyy',
                                                ).format(dateTime);
                                              } else {
                                                // 如果endDate比startDate早，提示用户
                                                showToast(
                                                  "End Date cannot be earlier than Start Date.",
                                                );
                                              }
                                            }
                                          },
                                          decoration: InputDecoration(
                                            labelText: "end_date".tr,
                                            labelStyle: TextStyle(
                                              color: Colors.grey,
                                            ),
                                            floatingLabelStyle: TextStyle(
                                              color: Colors.grey,
                                            ),
                                            floatingLabelBehavior:
                                                FloatingLabelBehavior.auto,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: BorderSide(
                                                color: Colors.grey,
                                                width: 1.5,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: BorderSide(
                                                color: Colors.grey,
                                                width: 1.5,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: BorderSide(
                                                color: Colors.grey,
                                                width: 2,
                                              ),
                                            ),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                  vertical: 8.0,
                                                  horizontal: 12.0,
                                                ), // 缩小内边距
                                          ),
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          right: 8.0,
                                        ), // 在 TextField 之间添加间隔
                                        child: TextField(
                                          controller: startTimeController,
                                          readOnly: true,
                                          onTap: () async {
                                            TimeOfDay? time =
                                                await todoSelectTime(context);
                                            // TODO check valid
                                            if (time != null) {
                                              startTimeController.text = time
                                                  .format(context);
                                            }
                                          },
                                          decoration: InputDecoration(
                                            hintText: "start_time".tr,
                                            hintStyle: TextStyle(
                                              color: Colors.grey,
                                            ),
                                            floatingLabelStyle: TextStyle(
                                              color: Colors.grey,
                                            ),
                                            floatingLabelBehavior:
                                                FloatingLabelBehavior.auto,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: BorderSide(
                                                color: Colors.grey,
                                                width: 1.5,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: BorderSide(
                                                color: Colors.grey,
                                                width: 1.5,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: BorderSide(
                                                color: Colors.grey,
                                                width: 2,
                                              ),
                                            ),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                  vertical: 8.0,
                                                  horizontal: 12.0,
                                                ), // 调整内边距
                                          ),
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          left: 8.0,
                                        ), // 添加左间隔
                                        child: TextField(
                                          controller: endTimeController,
                                          readOnly: true,
                                          onTap: () async {
                                            TimeOfDay? time =
                                                await todoSelectTime(context);
                                            if (time != null) {
                                              endTimeController.text = time
                                                  .format(context);
                                            }
                                          },
                                          decoration: InputDecoration(
                                            hintText: "end_time".tr,
                                            hintStyle: TextStyle(
                                              color: Colors.grey,
                                            ),
                                            floatingLabelStyle: TextStyle(
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).primaryColor,
                                            ),
                                            floatingLabelBehavior:
                                                FloatingLabelBehavior.auto,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: BorderSide(
                                                color: Colors.grey,
                                                width: 1.5,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: BorderSide(
                                                color: Colors.grey,
                                                width: 1.5,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: BorderSide(
                                                color: Colors.grey,
                                                width: 2,
                                              ),
                                            ),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                  vertical: 8.0,
                                                  horizontal: 12.0,
                                                ), // 调整内边距
                                          ),
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(height: 10),
                                Text(
                                  "filter_status".tr,
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Container(height: 5),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Obx(
                                      () => InkWell(
                                        onTap: () {
                                          filterRunning.value =
                                              !filterRunning.value;
                                        },
                                        child: Row(
                                          children: [
                                            filterRunning.value
                                                ? Icon(
                                                  Icons.check_box,
                                                  color:
                                                      Theme.of(
                                                        context,
                                                      ).primaryColor,
                                                )
                                                : Icon(
                                                  Icons.check_box_outline_blank,
                                                  color: Colors.grey,
                                                ),
                                            Text(
                                              "filter_running".tr,
                                              style: TextStyle(
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Obx(
                                      () => InkWell(
                                        onTap: () {
                                          filterFinish.value =
                                              !filterFinish.value;
                                        },
                                        child: Row(
                                          children: [
                                            filterFinish.value
                                                ? Icon(
                                                  Icons.check_box,
                                                  color:
                                                      Theme.of(
                                                        context,
                                                      ).primaryColor,
                                                )
                                                : Icon(
                                                  Icons.check_box_outline_blank,
                                                  color: Colors.grey,
                                                ),
                                            Text(
                                              "filter_finish".tr,
                                              style: TextStyle(
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Obx(
                                      () => InkWell(
                                        onTap: () {
                                          filterTimeout.value =
                                              !filterTimeout.value;
                                        },
                                        child: Row(
                                          children: [
                                            filterTimeout.value
                                                ? Icon(
                                                  Icons.check_box,
                                                  color:
                                                      Theme.of(
                                                        context,
                                                      ).primaryColor,
                                                )
                                                : Icon(
                                                  Icons.check_box_outline_blank,
                                                  color: Colors.grey,
                                                ),
                                            Text(
                                              "filter_timeout".tr,
                                              style: TextStyle(
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                    : Container(),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

Future<DateTime?> todoSelectDate(
  BuildContext context, {
  DateTime? initialDate,
  DateTime? firstDate,
}) async {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  return showDatePicker(
    context: context,
    initialDate: initialDate ?? DateTime.now(),
    firstDate: firstDate ?? DateTime.now(),
    lastDate: DateTime(2100),
    builder: (context, child) {
      return Theme(
        data: ThemeData(
          brightness: isDarkMode ? Brightness.dark : Brightness.light,
          dialogTheme: DialogTheme(
            backgroundColor: isDarkMode ? Colors.black : Colors.white,
          ),
          colorScheme:
              isDarkMode
                  ? ColorScheme.dark(
                    primary: Theme.of(context).primaryColor, // 选中颜色（暗色模式）
                    onSurface: Colors.white, // 文本颜色
                  )
                  : ColorScheme.light(
                    primary: Theme.of(context).primaryColor, // 选中颜色（亮色模式）
                    onSurface: Colors.black, // 文本颜色
                  ),
          textTheme: TextTheme(
            bodyMedium: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black, // 文本颜色
            ),
          ),
        ),
        child: child!,
      );
    },
  );
}

Future<TimeOfDay?> todoSelectTime(
  BuildContext context, {
  TimeOfDay? initialTime,
}) async {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;
  return showTimePicker(
    context: context,
    initialTime: initialTime ?? TimeOfDay.now(),
    builder: (context, child) {
      return Theme(
        data: ThemeData(
          brightness: isDarkMode ? Brightness.dark : Brightness.light,
          dialogTheme: DialogTheme(
            backgroundColor: isDarkMode ? Colors.black : Colors.white,
          ),
          colorScheme:
              isDarkMode
                  ? ColorScheme.dark(
                    primary: Theme.of(context).primaryColor, // 选中颜色（暗色模式）
                    onSurface: Colors.white, // 文本颜色
                  )
                  : ColorScheme.light(
                    primary: Theme.of(context).primaryColor, // 选中颜色（亮色模式）
                    onSurface: Colors.black, // 文本颜色
                  ),
          textTheme: TextTheme(
            bodyMedium: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black, // 文本颜色
            ),
          ),
        ),
        child: child!,
      );
    },
  );
}

class SearchTextField extends StatefulWidget {
  const SearchTextField({super.key});

  @override
  _SearchTextFieldState createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<SearchTextField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      style: TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: "search".tr,
        filled: true,
        fillColor: ThemeProvider.contrastColor(
          context,
          light: Colors.grey[200]!,
          dark: CupertinoColors.darkBackgroundGray,
        ),
        prefixIcon: Icon(Icons.search, color: Colors.grey, size: 18),
        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
