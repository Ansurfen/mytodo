// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_todo/view/home/nav/navigator_controller.dart';

import 'component/bottom_bar.dart';

class NavigatorPage extends GetView<NavigatorController> {
  const NavigatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.tertiary,
      child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              PageView(
                physics: const NeverScrollableScrollPhysics(),
                controller: controller.pageController,
                children: NavigatorController.pages,
              ),
              bottomBar(),
            ],
          )),
    );
  }

  Widget bottomBar() {
    return Column(
      children: [
        const Expanded(
          child: SizedBox(),
        ),
        BottomBarView(
          tabIconsList: controller.tabIconsList,
          changeIndex: controller.switchPage,
        ),
      ],
    );
  }
}
