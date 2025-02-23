// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_todo/view/home/component/home_drawer.dart';
import 'package:my_todo/view/home/component/home_drawer_controller.dart';
import 'package:my_todo/view/home/home_controller.dart';

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
          body: DrawerUserController(
            screenIndex: controller.drawerIndex,
            drawerWidth: MediaQuery.of(context).size.width * 0.75,
            onDrawerCall: (DrawerIndex drawerIndexData) {
              changeIndex(drawerIndexData);
            },
            screenView: controller.currentSubPage(),
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
