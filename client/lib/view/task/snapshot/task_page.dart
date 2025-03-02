// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'dart:async';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_todo/component/animate/fade_out_slow_in_container.dart';
import 'package:my_todo/component/container/empty_container.dart';
import 'package:my_todo/component/scaffold.dart';
import 'package:my_todo/component/title/title_view.dart';
import 'package:my_todo/mock/statistic.dart';
import 'package:my_todo/model/dto/topic.dart';
import 'package:my_todo/router/provider.dart';
import 'package:my_todo/theme/animate.dart';
import 'package:my_todo/theme/color.dart';
import 'package:my_todo/utils/guide.dart';
import 'package:my_todo/view/home/nav/component/app_bar.dart';
import 'package:my_todo/view/task/snapshot/task_card.dart';
import 'package:my_todo/view/task/snapshot/task_controller.dart';
import 'package:my_todo/view/task/snapshot/task_skeleton.dart';
import 'package:my_todo/view/task/component/statistic_table.dart';
import 'package:my_todo/utils/dialog.dart';
import 'package:my_todo/component/refresh.dart';
import 'package:easy_refresh/easy_refresh.dart';
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

  @override
  void initState() {
    super.initState();
    Guide.start(context);
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
                StatisticTable(
                  data: statisticTableData,
                  animation: opacity,
                  animationController: controller.animationController,
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
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                            ),
                          ),
                          child: Column(children: [Container()]),
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

List<String> taskTypes = ["已完成", "进行中", "未开始"];
// TODO：time picker, topic, task type
