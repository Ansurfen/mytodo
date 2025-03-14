// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:my_todo/utils/guard.dart';
import 'package:my_todo/utils/guide.dart';
import 'package:my_todo/view/home/component/home_drawer.dart';
import 'package:my_todo/view/home/component/home_drawer_controller.dart';
import 'package:my_todo/view/home/home_controller.dart';
import 'package:showcaseview/showcaseview.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TodoDrawerController controller = Get.find<TodoDrawerController>();

  @override
  void initState() {
    controller.drawerIndex ??= DrawerIndex.nav;
    super.initState();
    if (!Get.isRegistered<HomeDrawerController>()) {
      Get.lazyPut(() => HomeDrawerController());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Scaffold(
          backgroundColor: const Color(0xFF213333),
          body: ShowCaseWidget(
            onStart: (index, key) {
              Guard.log.i('onStart: $index, $key');
            },
            onComplete: (index, key) {
              Guard.log.i('onComplete: $index, $key');
              if (index == 4) {
                SystemChrome.setSystemUIOverlayStyle(
                  SystemUiOverlayStyle.light.copyWith(
                    statusBarIconBrightness: Brightness.dark,
                    statusBarColor: Colors.white,
                  ),
                );
              }
            },
            blurValue: 1,
            globalFloatingActionWidget:
                (showcaseContext) => FloatingActionWidget(
                  left: 16,
                  bottom: 16,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: ShowCaseWidget.of(showcaseContext).dismiss,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      child: Text(
                        'skip'.tr,
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                    ),
                  ),
                ),
            autoPlayDelay: const Duration(seconds: 3),
            builder:
                (context) => DrawerUserController(
                  screenIndex: controller.drawerIndex,
                  drawerWidth: MediaQuery.of(context).size.width * 0.75,
                  onDrawerCall: (DrawerIndex drawerIndexData) {
                    changeIndex(drawerIndexData);
                  },
                  screenView: controller.currentSubPage(),
                ),
            globalTooltipActionConfig: const TooltipActionConfig(
              position: TooltipActionPosition.inside,
              alignment: MainAxisAlignment.spaceBetween,
              actionGap: 20,
            ),
            globalTooltipActions: [
              // Here we don't need previous action for the first showcase widget
              // so we hide this action for the first showcase widget
              TooltipActionButton(
                type: TooltipDefaultActionType.previous,
                textStyle: const TextStyle(color: Colors.white),
                hideActionWidgetForShowcase: [Guide.one],
              ),
              // Here we don't need next action for the last showcase widget so we
              // hide this action for the last showcase widget
              // TooltipActionButton(
              //   type: TooltipDefaultActionType.next,
              //   textStyle: const TextStyle(color: Colors.white),
              //   hideActionWidgetForShowcase: [_lastShowcaseWidget],
              // ),
            ],
          ),
        ),
      ),
    );
  }

  void changeIndex(DrawerIndex drawerIndexData) {
    if (controller.drawerIndex != drawerIndexData) {
      controller.drawerIndex = drawerIndexData;
      setState(() {
        controller.subPage = controller.currentSubPage();
      });
    }
  }
}
