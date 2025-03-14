// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'dart:async';

import 'package:get/get.dart';
import 'package:my_todo/utils/guide.dart';
import 'package:my_todo/view/home/component/home_drawer.dart';
import 'package:my_todo/utils/guard.dart';

import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';

class HomeDrawerController extends GetxController
    with GetTickerProviderStateMixin {
  late ScrollController scrollController;
  late AnimationController iconAnimationController;
  late AnimationController animationController;
  final double drawerWidth = 250;

  Rx<double> scrollOffset = 0.0.obs;

  late Function(bool)? drawerIsOpen;

  @override
  void onInit() {
    super.onInit();
    animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    iconAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 0),
    );
    iconAnimationController.animateTo(
      1.0,
      duration: const Duration(milliseconds: 0),
      curve: Curves.fastOutSlowIn,
    );
    scrollController = ScrollController(initialScrollOffset: drawerWidth);
    scrollController.addListener(() {
      if (scrollController.offset <= 0) {
        if (scrollOffset.value != 1.0) {
          scrollOffset.value = 1.0;
          if (drawerIsOpen != null) {
            drawerIsOpen!(true);
          }
        }
        iconAnimationController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 0),
          curve: Curves.fastOutSlowIn,
        );
      } else if (scrollController.offset > 0 &&
          scrollController.offset < drawerWidth.floor()) {
        iconAnimationController.animateTo(
          (scrollController.offset * 100 / (drawerWidth)) / 100,
          duration: const Duration(milliseconds: 0),
          curve: Curves.fastOutSlowIn,
        );
      } else {
        if (scrollOffset.value != 0.0) {
          scrollOffset.value = 0.0;
          if (drawerIsOpen != null) {
            drawerIsOpen!(false);
          }
        }
        iconAnimationController.animateTo(
          1.0,
          duration: const Duration(milliseconds: 0),
          curve: Curves.fastOutSlowIn,
        );
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => getInitState());
  }

  Future<bool> getInitState() async {
    scrollController.jumpTo(drawerWidth);
    return true;
  }
}

class DrawerUserController extends StatefulWidget {
  const DrawerUserController({
    super.key,
    this.drawerWidth = 250,
    this.onDrawerCall,
    this.screenView,
    this.animatedIconData = AnimatedIcons.arrow_menu,
    this.menuView,
    this.drawerIsOpen,
    this.screenIndex,
  });

  final double drawerWidth;
  final Function(DrawerIndex)? onDrawerCall;
  final Widget? screenView;
  final Function(bool)? drawerIsOpen;
  final AnimatedIconData? animatedIconData;
  final Widget? menuView;
  final DrawerIndex? screenIndex;

  @override
  State<DrawerUserController> createState() => _DrawerUserControllerState();
}

class _DrawerUserControllerState extends State<DrawerUserController>
    with TickerProviderStateMixin {
  HomeDrawerController controller = Get.find<HomeDrawerController>();

  @override
  void initState() {
    super.initState();
    controller.drawerIsOpen = widget.drawerIsOpen;
  }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isLightMode = brightness == Brightness.light;
    ThemeData themeData = Theme.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body: SingleChildScrollView(
        controller: controller.scrollController,
        scrollDirection: Axis.horizontal,
        physics: const PageScrollPhysics(parent: ClampingScrollPhysics()),
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width + widget.drawerWidth,
          //we use with as screen width and add drawerWidth (from navigation_home_screen)
          child: Row(
            children: [
              SizedBox(
                width: widget.drawerWidth,
                //we divided first drawer Width with HomeDrawer and second full-screen Width with all home screen, we called screen View
                height: MediaQuery.of(context).size.height,
                child: AnimatedBuilder(
                  animation: controller.iconAnimationController,
                  builder: (BuildContext context, Widget? child) {
                    return Transform(
                      //transform we use for the stable drawer  we, not need to move with scroll view
                      transform: Matrix4.translationValues(
                        controller.scrollController.offset,
                        0.0,
                        0.0,
                      ),
                      child: HomeDrawer(
                        screenIndex: widget.screenIndex ?? DrawerIndex.nav,
                        iconAnimationController:
                            controller.iconAnimationController,
                        callBackIndex: (DrawerIndex indexType) {
                          onDrawerClick();
                          if (widget.onDrawerCall != null) {
                            widget.onDrawerCall!(indexType);
                          }
                        },
                        callExit: Guard.logOutAndGo,
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                //full-screen Width with widget.screenView
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        blurRadius: 24,
                      ),
                    ],
                  ),
                  child: Obx(
                    () => Stack(
                      children: [
                        //this IgnorePointer we use as touch(user Interface) widget.screen View, for example scrolloffset == 1 means drawer is close we just allow touching all widget.screen View
                        IgnorePointer(
                          ignoring: controller.scrollOffset.value == 1 || false,
                          child: widget.screenView,
                        ),
                        //alternative touch(user Interface) for widget.screen, for example, drawer is close we need to tap on a few home screen area and close the drawer
                        if (controller.scrollOffset.value == 1.0)
                          InkWell(
                            onTap: () {
                              onDrawerClick();
                            },
                          ),
                        Padding(
                          padding: EdgeInsets.only(
                            top: MediaQuery.of(context).padding.top + 8,
                            left: 8,
                          ),
                          child: SizedBox(
                            width: AppBar().preferredSize.height - 8,
                            height: AppBar().preferredSize.height - 8,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(
                                  AppBar().preferredSize.height,
                                ),
                                child: Center(
                                  // if you use your own menu view UI you add form initialization
                                  child: Showcase(
                                    key: Guide.one,
                                    description: 'guide_1'.tr,
                                    onBarrierClick: () {
                                      ShowCaseWidget.of(
                                        context,
                                      ).hideFloatingActionWidgetForKeys([
                                        Guide.one,
                                      ]);
                                    },
                                    tooltipActionConfig:
                                        const TooltipActionConfig(
                                          alignment: MainAxisAlignment.end,
                                          position:
                                              TooltipActionPosition.outside,
                                          gapBetweenContentAndAction: 10,
                                        ),
                                    child:
                                        widget.menuView ??
                                        AnimatedIcon(
                                          color:
                                              themeData.brightness ==
                                                      Brightness.light
                                                  ? Theme.of(
                                                    context,
                                                  ).colorScheme.onPrimary
                                                  : themeData.primaryColor,
                                          icon:
                                              widget.animatedIconData ??
                                              AnimatedIcons.arrow_menu,
                                          progress:
                                              controller
                                                  .iconAnimationController,
                                        ),
                                  ),
                                ),
                                onTap: () {
                                  FocusScope.of(
                                    context,
                                  ).requestFocus(FocusNode());
                                  onDrawerClick();
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onDrawerClick() {
    //if scrollController.offset != 0.0 then we set to closed the drawer(with animation to offset zero position) if is not 1 then open the drawer
    if (controller.scrollController.offset != 0.0) {
      controller.scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.fastOutSlowIn,
      );
    } else {
      controller.scrollController.animateTo(
        widget.drawerWidth,
        duration: const Duration(milliseconds: 400),
        curve: Curves.fastOutSlowIn,
      );
    }
  }
}
